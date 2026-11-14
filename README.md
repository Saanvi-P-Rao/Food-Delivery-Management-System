# FoodExpress Food-Delivery-Management-System
Mini DBMS Project 

A Java-based web application designed to simplify food ordering, restaurant management, and database administration. Built using **Java, JDBC, MySQL, JSP, and Servlets**, the system demonstrates real-time database connectivity and SQL operations.

## 🚀 Features

- **Customer Module:** Registration, login, restaurant browsing, cart, ordering and order history.
- **Restaurant Module:** Manage food items, prices, availability and customer orders.
- **Admin Dashboard:** Manage users, restaurants, food items, orders and payments.
- **SQL Query Console:** Execute SQL queries directly on MySQL using Java JDBC.
- **Database Explorer:** Explore tables, columns, relationships and records.
- **Dynamic Results:** Display query results with filtering, sorting and pagination.

## 🛠️ Technology Stack

| Component | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript, JSP |
| Backend | Java, Servlets |
| Database | MySQL 8.0 |
| Connectivity | JDBC |
| Build Tool | Maven |
| Server | Apache Tomcat |

## 🗄️ Database Design

The system consists of seven relational tables:

1. USER
2. RESTAURANT
3. ADMIN
4. FOOD_ITEMS
5. ORDERS
6. ORDER_ITEMS
7. PAYMENT

The database uses primary keys, foreign keys, relational constraints and transaction management to maintain data integrity.

## ⚡ SQL Query Execution

The Admin Dashboard provides an interactive SQL editor supporting:

- SELECT, INSERT, UPDATE and DELETE.
- WHERE, ORDER BY and GROUP BY.
- JOIN operations.
- Aggregate functions.
- Dynamic query result tables.
- Query history and CSV export.

All queries execute against the actual MySQL database through JDBC, subject to configured permissions and security restrictions.

## ⚙️ Installation

**1. Clone the repository**

```bash
git clone https://github.com/Saanvi-P-Rao/Food_Delivery_mgmt_system.git
```

**2. Create the database**

```sql
CREATE DATABASE food_delivery_db;
```

**3. Import the database schema and sample data** from the `database` directory.

**4. Configure MySQL credentials** in the application configuration.

**5. Build the project**

```bash
mvn clean package
```

**6. Deploy the WAR file** to Apache Tomcat and start the server.

## 🎯 Project Objective

To develop a database-driven food delivery application demonstrating Java programming, JDBC connectivity, relational database management, SQL query processing, and transaction handling.
