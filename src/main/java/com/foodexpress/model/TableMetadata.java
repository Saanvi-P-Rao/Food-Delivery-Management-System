package com.foodexpress.model;

import java.util.ArrayList;
import java.util.List;

public class TableMetadata {
    private String tableName;
    private String tableType;
    private long recordCount;
    private List<ColumnInfo> columns = new ArrayList<>();
    private List<ForeignKeyInfo> foreignKeys = new ArrayList<>();
    private List<IndexInfo> indexes = new ArrayList<>();

    public static class ColumnInfo {
        private String name;
        private String dataType;
        private String columnType;
        private boolean nullable;
        private boolean primaryKey;
        private boolean foreignKey;
        private boolean unique;
        private String defaultValue;
        private String extra;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDataType() { return dataType; }
        public void setDataType(String dataType) { this.dataType = dataType; }
        public String getColumnType() { return columnType; }
        public void setColumnType(String columnType) { this.columnType = columnType; }
        public boolean isNullable() { return nullable; }
        public void setNullable(boolean nullable) { this.nullable = nullable; }
        public boolean isPrimaryKey() { return primaryKey; }
        public void setPrimaryKey(boolean primaryKey) { this.primaryKey = primaryKey; }
        public boolean isForeignKey() { return foreignKey; }
        public void setForeignKey(boolean foreignKey) { this.foreignKey = foreignKey; }
        public boolean isUnique() { return unique; }
        public void setUnique(boolean unique) { this.unique = unique; }
        public String getDefaultValue() { return defaultValue; }
        public void setDefaultValue(String defaultValue) { this.defaultValue = defaultValue; }
        public String getExtra() { return extra; }
        public void setExtra(String extra) { this.extra = extra; }
    }

    public static class ForeignKeyInfo {
        private String constraintName;
        private String columnName;
        private String referencedTable;
        private String referencedColumn;
        private String updateRule;
        private String deleteRule;

        public String getConstraintName() { return constraintName; }
        public void setConstraintName(String constraintName) { this.constraintName = constraintName; }
        public String getColumnName() { return columnName; }
        public void setColumnName(String columnName) { this.columnName = columnName; }
        public String getReferencedTable() { return referencedTable; }
        public void setReferencedTable(String referencedTable) { this.referencedTable = referencedTable; }
        public String getReferencedColumn() { return referencedColumn; }
        public void setReferencedColumn(String referencedColumn) { this.referencedColumn = referencedColumn; }
        public String getUpdateRule() { return updateRule; }
        public void setUpdateRule(String updateRule) { this.updateRule = updateRule; }
        public String getDeleteRule() { return deleteRule; }
        public void setDeleteRule(String deleteRule) { this.deleteRule = deleteRule; }
    }

    public static class IndexInfo {
        private String indexName;
        private String columnName;
        private boolean unique;
        private String indexType;

        public String getIndexName() { return indexName; }
        public void setIndexName(String indexName) { this.indexName = indexName; }
        public String getColumnName() { return columnName; }
        public void setColumnName(String columnName) { this.columnName = columnName; }
        public boolean isUnique() { return unique; }
        public void setUnique(boolean unique) { this.unique = unique; }
        public String getIndexType() { return indexType; }
        public void setIndexType(String indexType) { this.indexType = indexType; }
    }

    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    public String getTableType() { return tableType; }
    public void setTableType(String tableType) { this.tableType = tableType; }
    public long getRecordCount() { return recordCount; }
    public void setRecordCount(long recordCount) { this.recordCount = recordCount; }
    public List<ColumnInfo> getColumns() { return columns; }
    public void setColumns(List<ColumnInfo> columns) { this.columns = columns; }
    public List<ForeignKeyInfo> getForeignKeys() { return foreignKeys; }
    public void setForeignKeys(List<ForeignKeyInfo> foreignKeys) { this.foreignKeys = foreignKeys; }
    public List<IndexInfo> getIndexes() { return indexes; }
    public void setIndexes(List<IndexInfo> indexes) { this.indexes = indexes; }
}
