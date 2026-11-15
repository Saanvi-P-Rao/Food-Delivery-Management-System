package com.foodexpress.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Restaurant {
    private int restaurantId;
    private String name;
    private String email;
    private String phone;
    private String passwordHash;
    private String cuisineType;
    private String description;
    private String address;
    private String city;
    private BigDecimal rating;
    private int deliveryTimeMins;
    private String imageUrl;
    private boolean active;
    private Timestamp createdAt;
    private int foodItemCount;

    public Restaurant() {}

    public int getRestaurantId() { return restaurantId; }
    public void setRestaurantId(int restaurantId) { this.restaurantId = restaurantId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getCuisineType() { return cuisineType; }
    public void setCuisineType(String cuisineType) { this.cuisineType = cuisineType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { this.rating = rating; }
    public int getDeliveryTimeMins() { return deliveryTimeMins; }
    public void setDeliveryTimeMins(int deliveryTimeMins) { this.deliveryTimeMins = deliveryTimeMins; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public int getFoodItemCount() { return foodItemCount; }
    public void setFoodItemCount(int foodItemCount) { this.foodItemCount = foodItemCount; }
}
