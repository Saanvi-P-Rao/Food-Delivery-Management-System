package com.foodexpress.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Structured request payload from the Visual SQL Query Builder.
 */
public class VisualQueryRequest {

    private String table;
    private List<SelectColumn> columns = new ArrayList<>();
    private List<FilterCondition> filters = new ArrayList<>();
    private List<String> groupBy = new ArrayList<>();
    private List<SortRule> orderBy = new ArrayList<>();
    private Integer limit = 100;
    private Integer offset = 0;

    public String getTable() { return table; }
    public void setTable(String table) { this.table = table; }

    public List<SelectColumn> getColumns() { return columns; }
    public void setColumns(List<SelectColumn> columns) { this.columns = columns != null ? columns : new ArrayList<>(); }

    public List<FilterCondition> getFilters() { return filters; }
    public void setFilters(List<FilterCondition> filters) { this.filters = filters != null ? filters : new ArrayList<>(); }

    public List<String> getGroupBy() { return groupBy; }
    public void setGroupBy(List<String> groupBy) { this.groupBy = groupBy != null ? groupBy : new ArrayList<>(); }

    public List<SortRule> getOrderBy() { return orderBy; }
    public void setOrderBy(List<SortRule> orderBy) { this.orderBy = orderBy != null ? orderBy : new ArrayList<>(); }

    public Integer getLimit() { return limit; }
    public void setLimit(Integer limit) { this.limit = limit; }

    public Integer getOffset() { return offset; }
    public void setOffset(Integer offset) { this.offset = offset; }

    public static class SelectColumn {
        private String column;
        private String aggregate; // "", COUNT, SUM, AVG, MIN, MAX
        private String alias;

        public String getColumn() { return column; }
        public void setColumn(String column) { this.column = column; }
        public String getAggregate() { return aggregate; }
        public void setAggregate(String aggregate) { this.aggregate = aggregate; }
        public String getAlias() { return alias; }
        public void setAlias(String alias) { this.alias = alias; }
    }

    public static class FilterCondition {
        private String connector = "AND"; // AND, OR
        private String column;
        private String operator = "=";
        private String value;
        private String value2; // used for BETWEEN

        public String getConnector() { return connector; }
        public void setConnector(String connector) { this.connector = connector; }
        public String getColumn() { return column; }
        public void setColumn(String column) { this.column = column; }
        public String getOperator() { return operator; }
        public void setOperator(String operator) { this.operator = operator; }
        public String getValue() { return value; }
        public void setValue(String value) { this.value = value; }
        public String getValue2() { return value2; }
        public void setValue2(String value2) { this.value2 = value2; }
    }

    public static class SortRule {
        private String column;
        private String direction = "ASC"; // ASC, DESC

        public String getColumn() { return column; }
        public void setColumn(String column) { this.column = column; }
        public String getDirection() { return direction; }
        public void setDirection(String direction) { this.direction = direction; }
    }
}
