# SQL-CAPSTONE-PROJECT
 
#  SQL Capstone Project — Superstore Sales Analysis

This project is a comprehensive SQL-based analysis of a fictional superstore dataset. The goal is to clean and normalize raw data, design an efficient relational schema, and answer key business questions through advanced SQL queries.

---

## 📊 Dataset Overview

- **Source**: Sample-Superstore-Complete.csv (imported as `Store`)
- **Total Rows**: 9,994
- **Initial Observations**:
  - Contains 21 columns.
  - `Order Date` and `Ship Date` were stored as text and needed conversion.
  - `Postal_Code` had missing values.
  - Duplicate records were found based on combinations of `Order_ID`, `Customer_ID`, `Product_ID`, and `Sales`.

---

##  Project Structure

- **Database**: `Super_store`
- **Tables Created**:
  - `Customers`
  - `Products`
  - `Orders`
  - `Sales`

- **Normalization**:
  - Redundant and mixed columns from the original dataset were split into multiple normalized tables.
  - Surrogate keys were used where appropriate.
  - Duplicates were removed using CTEs and `ROW_NUMBER()`.

---

## 🧹 Data Cleaning

Key cleaning steps included:
- Handling missing postal codes.
- Converting date fields into `DATE` data type.
- Identifying and removing exact duplicate entries.
- Ensuring referential integrity between tables via proper `JOIN` conditions.

---

##  Business Questions Answered

###  Sales & Profitability
- Total sales and profit per region.
- Most profitable product and category.
- Top 5 customers by total purchase.

###  Customer Behavior
- Customers who placed the most orders.
- Customers who purchased across 3 or more categories.
- Customers who purchased "Technology" products.

###  Shipping & Logistics
- Average shipping duration by mode (for high-value orders).
- Orders by shipping mode.
- Region-wise best-performing shipping methods.

###   Inventory Optimization
- Most ordered category per region.
- Products ordered above average quantity.
- Revenue, quantity, and discount breakdown by category.

---

##   Advanced SQL Techniques Used

- `CTE` (Common Table Expressions)
- `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`
- Aggregations with `GROUP BY`, `HAVING`
- `JOIN` operations across multiple tables
- Window functions for filtering and ranking
- `DATEDIFF()` for calculating durations


