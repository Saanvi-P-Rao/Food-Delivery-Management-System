package com.foodexpress.model;

import java.math.BigDecimal;

public class CartItem {
    private int foodId;
    private int restaurantId;
    private String restaurantName;
    private String name;
    private BigDecimal price;
    private boolean veg;
    private String imageUrl;
    private int quantity;

    public CartItem() {}

    public CartItem(FoodItem food, int quantity) {
        this.foodId = food.getFoodId();
        this.restaurantId = food.getRestaurantId();
        this.restaurantName = food.getRestaurantName();
        this.name = food.getName();
        this.price = food.getPrice();
        this.veg = food.isVeg();
        this.imageUrl = food.getImageUrl();
        this.quantity = quantity;
    }

    public BigDecimal getSubtotal() {
        if (price == null) return BigDecimal.ZERO;
        return price.multiply(BigDecimal.valueOf(quantity));
    }

    public int getFoodId() { return foodId; }
    public void setFoodId(int foodId) { this.foodId = foodId; }
    public int getRestaurantId() { return restaurantId; }
    public void setRestaurantId(int restaurantId) { this.restaurantId = restaurantId; }
    public String getRestaurantName() { return restaurantName; }
    public void setRestaurantName(String restaurantName) { this.restaurantName = restaurantName; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public boolean isVeg() { return veg; }
    public void setVeg(boolean veg) { this.veg = veg; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
}
