package com.foodexpress.service;

import com.foodexpress.model.VisualQueryRequest;
import com.foodexpress.model.VisualQueryRequest.FilterCondition;
import com.foodexpress.model.VisualQueryRequest.SelectColumn;
import com.foodexpress.model.VisualQueryRequest.SortRule;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Validates and builds safe MySQL SELECT statements from VisualQueryRequest payloads.
 */
public class VisualQueryBuilder {

    private static final Set<String> ALLOWED_AGGREGATES = Set.of("COUNT", "SUM", "AVG", "MIN", "MAX");
    private static final Set<String> ALLOWED_OPERATORS = Set.of(
        "=", "!=", ">", ">=", "<", "<=", "LIKE", "NOT LIKE", "IN", "NOT IN", "BETWEEN", "IS NULL", "IS NOT NULL"
    );
    private static final Pattern NUMERIC_PATTERN = Pattern.compile("^-?\\d+(\\.\\d+)?$");
    private static final Pattern SAFE_ALIAS_PATTERN = Pattern.compile("^[a-zA-Z0-9_ ]{1,60}$");

    /**
     * Builds a validated SQL SELECT statement using the provided table-to-columns schema map.
     *
     * @param req       structured visual query request
     * @param schemaMap map of canonical tableName -> set/list of canonical column names (case-insensitive lookup)
     * @return generated SQL string
     */
    public String buildSql(VisualQueryRequest req, Map<String, List<String>> schemaMap) {
        if (req == null || req.getTable() == null || req.getTable().isBlank()) {
            throw new IllegalArgumentException("Please select a database table.");
        }

        String canonicalTable = findCanonicalKey(schemaMap.keySet(), req.getTable().trim());
        if (canonicalTable == null) {
            throw new IllegalArgumentException("Selected table '" + req.getTable() + "' does not exist in food_delivery_db.");
        }

        List<String> validColumns = schemaMap.get(canonicalTable);
        if (validColumns == null || validColumns.isEmpty()) {
            throw new IllegalArgumentException("No columns found for table '" + canonicalTable + "'.");
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");

        // 1. SELECT columns / aggregates
        List<SelectColumn> selectCols = req.getColumns();
        if (selectCols == null || selectCols.isEmpty()) {
            sql.append("*");
        } else {
            List<String> projections = new ArrayList<>();
            for (SelectColumn sc : selectCols) {
                if (sc == null || sc.getColumn() == null || sc.getColumn().isBlank()) continue;
                String rawCol = sc.getColumn().trim();
                String agg = sc.getAggregate() == null ? "" : sc.getAggregate().trim().toUpperCase(Locale.ROOT);

                String expr;
                if (!agg.isEmpty()) {
                    if (!ALLOWED_AGGREGATES.contains(agg)) {
                        throw new IllegalArgumentException("Unsupported aggregate function: " + agg);
                    }
                    if ("*".equals(rawCol) && "COUNT".equals(agg)) {
                        expr = "COUNT(*)";
                    } else {
                        String col = requireValidColumn(validColumns, rawCol);
                        expr = agg + "(`" + col + "`)";
                    }
                } else {
                    if ("*".equals(rawCol)) {
                        expr = "*";
                    } else {
                        String col = requireValidColumn(validColumns, rawCol);
                        expr = "`" + col + "`";
                    }
                }

                if (sc.getAlias() != null && !sc.getAlias().isBlank()) {
                    String alias = sc.getAlias().trim();
                    if (!SAFE_ALIAS_PATTERN.matcher(alias).matches()) {
                        throw new IllegalArgumentException("Invalid column alias: " + alias);
                    }
                    expr += " AS `" + alias + "`";
                }
                projections.add(expr);
            }
            if (projections.isEmpty()) {
                sql.append("*");
            } else {
                sql.append(String.join(", ", projections));
            }
        }

        // 2. FROM
        sql.append("\nFROM `").append(canonicalTable).append("`");

        // 3. WHERE conditions (AND / OR)
        List<FilterCondition> filters = req.getFilters();
        if (filters != null && !filters.isEmpty()) {
            List<String> clauses = new ArrayList<>();
            for (FilterCondition f : filters) {
                if (f == null || f.getColumn() == null || f.getColumn().isBlank()) continue;
                String col = requireValidColumn(validColumns, f.getColumn().trim());
                String op = f.getOperator() == null ? "=" : f.getOperator().trim().toUpperCase(Locale.ROOT);
                if (!ALLOWED_OPERATORS.contains(op)) {
                    throw new IllegalArgumentException("Unsupported comparison operator: " + op);
                }

                String predicate = buildPredicate(col, op, f.getValue(), f.getValue2());
                if (clauses.isEmpty()) {
                    clauses.add(predicate);
                } else {
                    String conn = f.getConnector() != null && "OR".equalsIgnoreCase(f.getConnector().trim()) ? "OR" : "AND";
                    clauses.add(conn + " " + predicate);
                }
            }
            if (!clauses.isEmpty()) {
                sql.append("\nWHERE ").append(String.join("\n  ", clauses));
            }
        }

        // 4. GROUP BY
        List<String> groupBy = req.getGroupBy();
        if (groupBy != null && !groupBy.isEmpty()) {
            List<String> grpCols = new ArrayList<>();
            for (String g : groupBy) {
                if (g == null || g.isBlank()) continue;
                String col = requireValidColumn(validColumns, g.trim());
                grpCols.add("`" + col + "`");
            }
            if (!grpCols.isEmpty()) {
                sql.append("\nGROUP BY ").append(String.join(", ", grpCols));
            }
        }

        // 5. ORDER BY
        List<SortRule> orderBy = req.getOrderBy();
        if (orderBy != null && !orderBy.isEmpty()) {
            List<String> sortParts = new ArrayList<>();
            for (SortRule s : orderBy) {
                if (s == null || s.getColumn() == null || s.getColumn().isBlank()) continue;
                String col = requireValidColumn(validColumns, s.getColumn().trim());
                String dir = "DESC".equalsIgnoreCase(s.getDirection()) ? "DESC" : "ASC";
                sortParts.add("`" + col + "` " + dir);
            }
            if (!sortParts.isEmpty()) {
                sql.append("\nORDER BY ").append(String.join(", ", sortParts));
            }
        }

        // 6. LIMIT & OFFSET
        int limit = req.getLimit() == null ? 100 : Math.max(1, Math.min(req.getLimit(), 1000));
        sql.append("\nLIMIT ").append(limit);
        if (req.getOffset() != null && req.getOffset() > 0) {
            sql.append(" OFFSET ").append(Math.min(req.getOffset(), 100_000));
        }

        return sql.toString();
    }

    private String buildPredicate(String col, String op, String val, String val2) {
        String quotedCol = "`" + col + "`";
        if ("IS NULL".equals(op) || "IS NOT NULL".equals(op)) {
            return quotedCol + " " + op;
        }
        if ("BETWEEN".equals(op)) {
            if (val == null || val.isBlank() || val2 == null || val2.isBlank()) {
                throw new IllegalArgumentException("BETWEEN operator requires both start and end values for column '" + col + "'.");
            }
            return quotedCol + " BETWEEN " + formatLiteral(val.trim()) + " AND " + formatLiteral(val2.trim());
        }
        if ("IN".equals(op) || "NOT IN".equals(op)) {
            if (val == null || val.isBlank()) {
                throw new IllegalArgumentException(op + " operator requires comma-separated values for column '" + col + "'.");
            }
            String[] parts = val.split(",");
            List<String> formatted = new ArrayList<>();
            for (String p : parts) {
                String t = p.trim();
                if (!t.isEmpty()) {
                    formatted.add(formatLiteral(t));
                }
            }
            if (formatted.isEmpty()) {
                throw new IllegalArgumentException(op + " operator requires at least one value.");
            }
            return quotedCol + " " + op + " (" + String.join(", ", formatted) + ")";
        }
        String safeVal = val == null ? "" : val.trim();
        return quotedCol + " " + op + " " + formatLiteral(safeVal);
    }

    private String formatLiteral(String raw) {
        if ("TRUE".equalsIgnoreCase(raw) || "FALSE".equalsIgnoreCase(raw)) {
            return raw.toUpperCase(Locale.ROOT);
        }
        if (NUMERIC_PATTERN.matcher(raw).matches()) {
            return raw;
        }
        return "'" + raw.replace("\\", "\\\\").replace("'", "''") + "'";
    }

    private String requireValidColumn(List<String> validColumns, String requested) {
        for (String c : validColumns) {
            if (c.equalsIgnoreCase(requested)) {
                return c;
            }
        }
        throw new IllegalArgumentException("Invalid column '" + requested + "' for selected table.");
    }

    private String findCanonicalKey(Set<String> keys, String target) {
        for (String k : keys) {
            if (k.equalsIgnoreCase(target)) {
                return k;
            }
        }
        return null;
    }
}
