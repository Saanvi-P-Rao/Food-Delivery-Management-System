package com.foodexpress.service;

import com.foodexpress.config.DBConnection;
import com.foodexpress.model.QueryResult;
import com.foodexpress.model.TableMetadata;
import java.sql.*;
import java.util.*;

/**
 * Retrieves live schema metadata via JDBC DatabaseMetaData and INFORMATION_SCHEMA.
 */
public class DatabaseMetadataService {

    public static final List<String> CORE_TABLES = List.of(
        "Users", "Restaurants", "Admin", "Food_Items", "Orders", "Order_Items", "Payments"
    );

    public List<TableMetadata> getAllTablesMetadata(boolean useSandbox) throws SQLException {
        String catalog = useSandbox ? DBConnection.getSandboxDatabaseName() : DBConnection.getDatabaseName();
        List<TableMetadata> tables = new ArrayList<>();

        try (Connection conn = DBConnection.getSqlConsoleConnection(useSandbox)) {
            DatabaseMetaData meta = conn.getMetaData();

            try (ResultSet rsTables = meta.getTables(catalog, null, "%", new String[]{"TABLE", "VIEW"})) {
                while (rsTables.next()) {
                    String tableName = rsTables.getString("TABLE_NAME");
                    String tableType = rsTables.getString("TABLE_TYPE");

                    TableMetadata tm = new TableMetadata();
                    tm.setTableName(tableName);
                    tm.setTableType(tableType);

                    Set<String> pkCols = new HashSet<>();
                    try (ResultSet rsPk = meta.getPrimaryKeys(catalog, null, tableName)) {
                        while (rsPk.next()) {
                            pkCols.add(rsPk.getString("COLUMN_NAME"));
                        }
                    }

                    Set<String> fkCols = new HashSet<>();
                    try (ResultSet rsFk = meta.getImportedKeys(catalog, null, tableName)) {
                        while (rsFk.next()) {
                            TableMetadata.ForeignKeyInfo fk = new TableMetadata.ForeignKeyInfo();
                            fk.setConstraintName(rsFk.getString("FK_NAME"));
                            fk.setColumnName(rsFk.getString("FKCOLUMN_NAME"));
                            fk.setReferencedTable(rsFk.getString("PKTABLE_NAME"));
                            fk.setReferencedColumn(rsFk.getString("PKCOLUMN_NAME"));
                            fk.setUpdateRule(ruleName(rsFk.getShort("UPDATE_RULE")));
                            fk.setDeleteRule(ruleName(rsFk.getShort("DELETE_RULE")));
                            tm.getForeignKeys().add(fk);
                            fkCols.add(fk.getColumnName());
                        }
                    }

                    Set<String> uniqueCols = new HashSet<>();
                    try (ResultSet rsIdx = meta.getIndexInfo(catalog, null, tableName, false, false)) {
                        while (rsIdx.next()) {
                            String indexName = rsIdx.getString("INDEX_NAME");
                            String colName = rsIdx.getString("COLUMN_NAME");
                            if (indexName == null || colName == null) continue;
                            boolean nonUnique = rsIdx.getBoolean("NON_UNIQUE");
                            TableMetadata.IndexInfo idx = new TableMetadata.IndexInfo();
                            idx.setIndexName(indexName);
                            idx.setColumnName(colName);
                            idx.setUnique(!nonUnique);
                            idx.setIndexType(rsIdx.getString("TYPE"));
                            tm.getIndexes().add(idx);
                            if (!nonUnique) {
                                uniqueCols.add(colName);
                            }
                        }
                    }

                    // Enrich columns with INFORMATION_SCHEMA for full COLUMN_TYPE & EXTRA
                    String colSql = "SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, EXTRA " +
                                    "FROM INFORMATION_SCHEMA.COLUMNS " +
                                    "WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION";
                    try (PreparedStatement ps = conn.prepareStatement(colSql)) {
                        ps.setString(1, catalog);
                        ps.setString(2, tableName);
                        try (ResultSet rsCol = ps.executeQuery()) {
                            while (rsCol.next()) {
                                TableMetadata.ColumnInfo col = new TableMetadata.ColumnInfo();
                                String colName = rsCol.getString("COLUMN_NAME");
                                col.setName(colName);
                                col.setDataType(rsCol.getString("DATA_TYPE").toUpperCase());
                                col.setColumnType(rsCol.getString("COLUMN_TYPE").toUpperCase());
                                col.setNullable("YES".equalsIgnoreCase(rsCol.getString("IS_NULLABLE")));
                                col.setPrimaryKey(pkCols.contains(colName));
                                col.setForeignKey(fkCols.contains(colName));
                                col.setUnique(uniqueCols.contains(colName));
                                col.setDefaultValue(rsCol.getString("COLUMN_DEFAULT"));
                                col.setExtra(rsCol.getString("EXTRA"));
                                tm.getColumns().add(col);
                            }
                        }
                    }

                    // Live record count
                    tm.setRecordCount(fetchExactCount(conn, tableName));
                    tables.add(tm);
                }
            }
        }
        return tables;
    }

    public List<TableMetadata.ColumnInfo> getTableColumns(String tableName) throws SQLException {
        if (tableName == null || tableName.isBlank()) {
            return List.of();
        }
        List<TableMetadata> all = getAllTablesMetadata(false);
        for (TableMetadata tm : all) {
            if (tm.getTableName().equalsIgnoreCase(tableName.trim())) {
                return tm.getColumns();
            }
        }
        return List.of();
    }

    public Map<String, List<String>> getSchemaColumnMap() throws SQLException {
        List<TableMetadata> all = getAllTablesMetadata(false);
        Map<String, List<String>> map = new LinkedHashMap<>();
        for (TableMetadata tm : all) {
            List<String> cols = new ArrayList<>();
            for (TableMetadata.ColumnInfo c : tm.getColumns()) {
                cols.add(c.getName());
            }
            map.put(tm.getTableName(), cols);
        }
        return map;
    }

    public String getMySqlVersion() {
        try (Connection conn = DBConnection.getConnection()) {
            return conn.getMetaData().getDatabaseProductVersion();
        } catch (SQLException e) {
            return null;
        }
    }

    public QueryResult previewTableRecords(String tableName, boolean useSandbox, int limit) throws SQLException {
        // Validate tableName against actual DatabaseMetaData to prevent SQL injection
        String catalog = useSandbox ? DBConnection.getSandboxDatabaseName() : DBConnection.getDatabaseName();
        String validatedTable = null;
        try (Connection conn = DBConnection.getSqlConsoleConnection(useSandbox)) {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getTables(catalog, null, "%", new String[]{"TABLE", "VIEW"})) {
                while (rs.next()) {
                    String name = rs.getString("TABLE_NAME");
                    if (name.equalsIgnoreCase(tableName)) {
                        validatedTable = name;
                        break;
                    }
                }
            }
        }
        if (validatedTable == null) {
            QueryResult err = new QueryResult();
            err.setSuccess(false);
            err.setErrorMessage("Table '" + tableName + "' does not exist in database '" + catalog + "'.");
            return err;
        }
        int safeLimit = Math.max(1, Math.min(limit, 500));
        SqlExecutionService sqlService = new SqlExecutionService();
        return sqlService.executeQuery("SELECT * FROM `" + validatedTable + "` LIMIT " + safeLimit, useSandbox, false, "explorer");
    }

    private long fetchExactCount(Connection conn, String tableName) {
        String safeName = tableName.replace("`", "");
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM `" + safeName + "`")) {
            return rs.next() ? rs.getLong(1) : 0L;
        } catch (SQLException e) {
            return 0L;
        }
    }

    private String ruleName(short rule) {
        return switch (rule) {
            case DatabaseMetaData.importedKeyCascade -> "CASCADE";
            case DatabaseMetaData.importedKeyRestrict, DatabaseMetaData.importedKeyNoAction -> "RESTRICT";
            case DatabaseMetaData.importedKeySetNull -> "SET NULL";
            default -> "NO ACTION";
        };
    }
}
