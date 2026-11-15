package com.foodexpress.model;

import java.util.ArrayList;
import java.util.List;

public class QueryResult {
    private boolean success;
    private boolean hasResultSet;
    private String statementType;
    private String statusMessage;
    private String errorMessage;
    private String sqlState;
    private int errorCode;
    private long executionTimeMs;
    private int rowsReturned;
    private int rowsAffected;
    private boolean confirmationRequired;
    private String databaseName;
    private String source;
    private List<String> columns = new ArrayList<>();
    private List<String> columnTypes = new ArrayList<>();
    private List<List<Object>> rows = new ArrayList<>();

    public QueryResult() {}

    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public boolean isHasResultSet() { return hasResultSet; }
    public void setHasResultSet(boolean hasResultSet) { this.hasResultSet = hasResultSet; }
    public String getStatementType() { return statementType; }
    public void setStatementType(String statementType) { this.statementType = statementType; }
    public String getStatusMessage() { return statusMessage; }
    public void setStatusMessage(String statusMessage) { this.statusMessage = statusMessage; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public String getSqlState() { return sqlState; }
    public void setSqlState(String sqlState) { this.sqlState = sqlState; }
    public int getErrorCode() { return errorCode; }
    public void setErrorCode(int errorCode) { this.errorCode = errorCode; }
    public long getExecutionTimeMs() { return executionTimeMs; }
    public void setExecutionTimeMs(long executionTimeMs) { this.executionTimeMs = executionTimeMs; }
    public int getRowsReturned() { return rowsReturned; }
    public void setRowsReturned(int rowsReturned) { this.rowsReturned = rowsReturned; }
    public int getRowsAffected() { return rowsAffected; }
    public void setRowsAffected(int rowsAffected) { this.rowsAffected = rowsAffected; }
    public boolean isConfirmationRequired() { return confirmationRequired; }
    public void setConfirmationRequired(boolean confirmationRequired) { this.confirmationRequired = confirmationRequired; }
    public String getDatabaseName() { return databaseName; }
    public void setDatabaseName(String databaseName) { this.databaseName = databaseName; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public List<String> getColumns() { return columns; }
    public void setColumns(List<String> columns) { this.columns = columns; }
    public List<String> getColumnTypes() { return columnTypes; }
    public void setColumnTypes(List<String> columnTypes) { this.columnTypes = columnTypes; }
    public List<List<Object>> getRows() { return rows; }
    public void setRows(List<List<Object>> rows) { this.rows = rows; }
}
