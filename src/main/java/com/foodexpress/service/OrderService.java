package com.foodexpress.service;

import com.foodexpress.config.DBConnection;
import com.foodexpress.dao.OrderDAO;
import com.foodexpress.dao.OrderItemDAO;
import com.foodexpress.dao.PaymentDAO;
import com.foodexpress.model.CartItem;
import com.foodexpress.model.Order;
import com.foodexpress.model.OrderItem;
import com.foodexpress.model.Payment;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Handles transactional order placement across Orders, Order_Items, and Payments.
 */
public class OrderService {

    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderItemDAO orderItemDAO = new OrderItemDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    public Order placeOrder(int userId, List<CartItem> cartItems, String deliveryAddress,
                            String specialInstructions, String paymentMethod) throws SQLException {
        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalArgumentException("Your cart is empty.");
        }
        if (deliveryAddress == null || deliveryAddress.isBlank()) {
            throw new IllegalArgumentException("Delivery address is required.");
        }
        String normalizedMethod = normalizePaymentMethod(paymentMethod);

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Validate customer exists
            if (!customerExists(conn, userId)) {
                throw new IllegalArgumentException("Customer account not found.");
            }

            // 2. Validate each cart item against MySQL Food_Items, verify availability, and fetch actual prices
            int restaurantId = -1;
            BigDecimal totalAmount = BigDecimal.ZERO;
            List<OrderItem> verifiedItems = new ArrayList<>();

            String foodSql = "SELECT f.food_id, f.restaurant_id, f.name, f.price, f.is_available, f.is_veg, r.is_active " +
                             "FROM `Food_Items` f JOIN `Restaurants` r ON f.restaurant_id = r.restaurant_id " +
                             "WHERE f.food_id = ?";

            try (PreparedStatement ps = conn.prepareStatement(foodSql)) {
                for (CartItem cartItem : cartItems) {
                    if (cartItem.getQuantity() <= 0) {
                        throw new IllegalArgumentException("Invalid quantity for item: " + cartItem.getName());
                    }
                    ps.setInt(1, cartItem.getFoodId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new IllegalArgumentException("Food item #" + cartItem.getFoodId() + " no longer exists.");
                        }
                        if (!rs.getBoolean("is_active")) {
                            throw new IllegalArgumentException("Restaurant is currently inactive.");
                        }
                        if (!rs.getBoolean("is_available")) {
                            throw new IllegalArgumentException("'" + rs.getString("name") + "' is currently unavailable.");
                        }
                        int itemRestId = rs.getInt("restaurant_id");
                        if (restaurantId == -1) {
                            restaurantId = itemRestId;
                        } else if (restaurantId != itemRestId) {
                            throw new IllegalArgumentException("All items in a single order must belong to the same restaurant.");
                        }

                        BigDecimal actualPrice = rs.getBigDecimal("price");
                        BigDecimal subtotal = actualPrice.multiply(BigDecimal.valueOf(cartItem.getQuantity()));
                        totalAmount = totalAmount.add(subtotal);

                        OrderItem oi = new OrderItem();
                        oi.setFoodId(cartItem.getFoodId());
                        oi.setFoodName(rs.getString("name"));
                        oi.setVeg(rs.getBoolean("is_veg"));
                        oi.setQuantity(cartItem.getQuantity());
                        oi.setItemPrice(actualPrice);
                        oi.setSubtotal(subtotal);
                        verifiedItems.add(oi);
                    }
                }
            }

            // 3. Insert into Orders
            Order order = new Order();
            order.setUserId(userId);
            order.setRestaurantId(restaurantId);
            order.setOrderStatus("PLACED");
            order.setTotalAmount(totalAmount);
            order.setDeliveryAddress(deliveryAddress.trim());
            order.setSpecialInstructions(specialInstructions != null ? specialInstructions.trim() : null);

            int orderId = orderDAO.createWithConnection(conn, order);

            // 4. Insert into Order_Items with purchase-time prices & subtotals
            for (OrderItem oi : verifiedItems) {
                oi.setOrderId(orderId);
            }
            orderItemDAO.insertBatchWithConnection(conn, verifiedItems);
            order.setItems(verifiedItems);

            // 5. Insert academic payment simulation record into Payments
            Payment payment = new Payment();
            payment.setOrderId(orderId);
            payment.setPaymentMethod(normalizedMethod);
            payment.setPaymentStatus("COD".equals(normalizedMethod) ? "PENDING" : "SUCCESS");
            payment.setAmount(totalAmount);
            payment.setTransactionRef("TXN-FE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
            paymentDAO.insertWithConnection(conn, payment);
            order.setPayment(payment);

            // 6. Commit transaction
            conn.commit();
            return orderDAO.findById(orderId);
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            if (e instanceof SQLException) {
                throw (SQLException) e;
            }
            if (e instanceof RuntimeException) {
                throw (RuntimeException) e;
            }
            throw new SQLException("Order placement failed: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    private boolean customerExists(Connection conn, int userId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM `Users` WHERE user_id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String normalizePaymentMethod(String method) {
        if (method == null) return "UPI";
        String upper = method.trim().toUpperCase();
        return switch (upper) {
            case "UPI", "CARD", "NET_BANKING", "COD", "WALLET" -> upper;
            default -> "UPI";
        };
    }
}
