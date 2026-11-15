package com.foodexpress.model;

public class QueryHistoryEntry {
    private long id;
    private String sql;
    private String databaseName;
    private String statementType;
    private boolean success;
    private int rowsReturned;
    private int rowsAffected;
    private long executionTimeMs;
    private String errorMessage;
    private String executedBy;
    private String executedAt;
    private String source;

    public QueryHistoryEntry() {}

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public String getSql() { return sql; }
    public void setSql(String sql) { this.sql = sql; }
    public String getDatabaseName() { return databaseName; }
    public void setDatabaseName(String databaseName) { this.databaseName = databaseName; }
    public String getStatementType() { return statementType; }
    public void setStatementType(String statementType) { this.statementType = statementType; }
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public int getRowsReturned() { return rowsReturned; }
    public void setRowsReturned(int rowsReturned) { this.rowsReturned = rowsReturned; }
    public int getRowsAffected() { return rowsAffected; }
    public void setRowsAffected(int rowsAffected) { this.rowsAffected = rowsAffected; }
    public long getExecutionTimeMs() { return executionTimeMs; }
    public void setExecutionTimeMs(long executionTimeMs) { this.executionTimeMs = executionTimeMs; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public String getExecutedBy() { return executedBy; }
    public void setExecutedBy(String executedBy) { this.executedBy = executedBy; }
    public String getExecutedAt() { return executedAt; }
    public void setExecutedAt(String executedAt) { this.executedAt = executedAt; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
}
