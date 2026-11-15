package com.foodexpress.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class DashboardStats {
    private int totalUsers;
    private int totalRestaurants;
    private int totalFoodItems;
    private int totalOrders;
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private int pendingOrders;
    private int completedOrders;
    private int cancelledOrders;
    private List<Payment> recentPayments = new ArrayList<>();
    private List<Order> recentOrders = new ArrayList<>();

    public DashboardStats() {}

    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }
    public int getTotalRestaurants() { return totalRestaurants; }
    public void setTotalRestaurants(int totalRestaurants) { this.totalRestaurants = totalRestaurants; }
    public int getTotalFoodItems() { return totalFoodItems; }
    public void setTotalFoodItems(int totalFoodItems) { this.totalFoodItems = totalFoodItems; }
    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }
    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
    public int getPendingOrders() { return pendingOrders; }
    public void setPendingOrders(int pendingOrders) { this.pendingOrders = pendingOrders; }
    public int getCompletedOrders() { return completedOrders; }
    public void setCompletedOrders(int completedOrders) { this.completedOrders = completedOrders; }
    public int getCancelledOrders() { return cancelledOrders; }
    public void setCancelledOrders(int cancelledOrders) { this.cancelledOrders = cancelledOrders; }
    public List<Payment> getRecentPayments() { return recentPayments; }
    public void setRecentPayments(List<Payment> recentPayments) { this.recentPayments = recentPayments; }
    public List<Order> getRecentOrders() { return recentOrders; }
    public void setRecentOrders(List<Order> recentOrders) { this.recentOrders = recentOrders; }
}
