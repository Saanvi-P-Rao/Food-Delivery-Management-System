-- ============================================================================
-- FoodExpress - Food Delivery Management System
-- MySQL 8.0+ Relational Database Schema (Non-destructive & Re-runnable)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS food_delivery_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Disposable sandbox database for unrestricted SQL experiments in the SQL Console
CREATE DATABASE IF NOT EXISTS food_delivery_sandbox
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE food_delivery_db;

-- ----------------------------------------------------------------------------
-- 1. USER
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Users` (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL,
    phone         VARCHAR(20)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    address       TEXT         NOT NULL,
    city          VARCHAR(60)  NOT NULL,
    pincode       VARCHAR(10)  NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT uq_user_phone UNIQUE (phone),
    INDEX idx_user_city (city)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. Restaurants
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Restaurants` (
    restaurant_id      INT AUTO_INCREMENT PRIMARY KEY,
    name               VARCHAR(120) NOT NULL,
    email              VARCHAR(120) NOT NULL,
    phone              VARCHAR(20)  NOT NULL,
    password_hash      VARCHAR(255) NOT NULL,
    cuisine_type       VARCHAR(80)  NOT NULL,
    description        TEXT,
    address            TEXT         NOT NULL,
    city               VARCHAR(60)  NOT NULL,
    rating             DECIMAL(3,2) NOT NULL DEFAULT 4.20,
    delivery_time_mins INT          NOT NULL DEFAULT 30,
    image_url          VARCHAR(500),
    is_active          BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_restaurant_email UNIQUE (email),
    CONSTRAINT chk_restaurant_rating CHECK (rating >= 0.00 AND rating <= 5.00),
    CONSTRAINT chk_restaurant_delivery CHECK (delivery_time_mins > 0),
    INDEX idx_restaurant_city_cuisine (city, cuisine_type),
    INDEX idx_restaurant_active (is_active)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. ADMIN
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Admin` (
    admin_id      INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(60)  NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(40)  NOT NULL DEFAULT 'SUPER_ADMIN',
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_admin_username UNIQUE (username),
    CONSTRAINT uq_admin_email UNIQUE (email)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. Food_Items
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Food_Items` (
    food_id       INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT           NOT NULL,
    name          VARCHAR(120)  NOT NULL,
    description   TEXT,
    category      VARCHAR(60)   NOT NULL,
    price         DECIMAL(10,2) NOT NULL,
    is_veg        BOOLEAN       NOT NULL DEFAULT TRUE,
    is_available  BOOLEAN       NOT NULL DEFAULT TRUE,
    image_url     VARCHAR(500),
    created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_food_restaurant FOREIGN KEY (restaurant_id)
        REFERENCES `Restaurants` (restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_food_price CHECK (price > 0),
    INDEX idx_food_restaurant (restaurant_id),
    INDEX idx_food_category (category),
    INDEX idx_food_veg_avail (is_veg, is_available)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. Orders
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Orders` (
    order_id             INT AUTO_INCREMENT PRIMARY KEY,
    user_id              INT           NOT NULL,
    restaurant_id        INT           NOT NULL,
    order_status         ENUM('PLACED','CONFIRMED','PREPARING','OUT_FOR_DELIVERY','DELIVERED','CANCELLED')
                         NOT NULL DEFAULT 'PLACED',
    total_amount         DECIMAL(10,2) NOT NULL,
    delivery_address     TEXT          NOT NULL,
    special_instructions VARCHAR(255),
    order_date           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
        REFERENCES `Users` (user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_orders_restaurant FOREIGN KEY (restaurant_id)
        REFERENCES `Restaurants` (restaurant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    INDEX idx_orders_user (user_id),
    INDEX idx_orders_restaurant (restaurant_id),
    INDEX idx_orders_status (order_status),
    INDEX idx_orders_date (order_date)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. Order_Items
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Order_Items` (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT           NOT NULL,
    food_id       INT           NOT NULL,
    quantity      INT           NOT NULL,
    item_price    DECIMAL(10,2) NOT NULL,
    subtotal      DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES `Orders` (order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_food FOREIGN KEY (food_id)
        REFERENCES `Food_Items` (food_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_order_items_qty CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price CHECK (item_price > 0),
    CONSTRAINT chk_order_items_subtotal CHECK (subtotal >= 0),
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_food (food_id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. Payments
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Payments` (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT           NOT NULL,
    payment_method  ENUM('UPI','CARD','NET_BANKING','COD','WALLET') NOT NULL,
    payment_status  ENUM('PENDING','SUCCESS','FAILED','REFUNDED')   NOT NULL DEFAULT 'SUCCESS',
    amount          DECIMAL(10,2) NOT NULL,
    transaction_ref VARCHAR(80)   NOT NULL,
    payment_date    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_payment_order UNIQUE (order_id),
    CONSTRAINT uq_payment_txn UNIQUE (transaction_ref),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
        REFERENCES `Orders` (order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_method (payment_method)
) ENGINE=InnoDB;
