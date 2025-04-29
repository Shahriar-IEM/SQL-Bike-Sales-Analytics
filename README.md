# SQL-Bike-Sales-Analytics
### 🔍 Overview
This portfolio showcases real world SQL queries written over a custom designed **retail database schema** of 9 interconnected tables. The goal is to demonstrate **data analysis**, **query optimization**, and **business insight extraction** using key SQL concepts.

---

### 📁 Database Schema

The database includes the following tables:
- `categories`
- `products`
- `brands`
- `customers`
- `orders`
- `order_items`
- `stocks`
- `staff`
- `stores`

---

### 🧰 Tech Stack
- **Database**: PostgreSQL  
- **Tool Used**: pgAdmin / DBeaver / SQL Playground  
- **Query Language**: ANSI SQL

---

### 📊 Key Concepts Covered
| Concept               | Query Examples |
|-----------------------|----------------|
| `JOIN` operations     | Combine customer, order, and store data |
| `Aggregate functions` | Count, Sum, Avg, Max, Min |
| `CASE` statements     | Categorize orders & products |
| `WHERE`, `HAVING`     | Filtering raw and aggregated data |
| `Common Table Expressions (CTE)` | Modular query building |
| `Subqueries`          | Nested logic for filtering |
| `Window functions`    | Rank, partition, and analyze |
| `Timestamps & EXTRACT`| Time-based trend analysis |

---

### 📌 Sample Queries & Business Insights

<details>
<summary><strong>🛍️ 1. Total Products per Brand</strong></summary>

```sql
SELECT b.brand_id, b.brand_name, COUNT(p.product_name) AS count
FROM brands AS b
JOIN products p ON p.brand_id = b.brand_id
GROUP BY b.brand_id, b.brand_name
ORDER BY count DESC;
```

**Insight:** Helps the product team identify which brands have the widest assortment.
</details>

<details>
<summary><strong>🏷️ 2. Label Products by Price Range</strong></summary>

```sql
SELECT product_id, product_name, list_price,
CASE
    WHEN list_price < 800 THEN 'Cheap'
    WHEN list_price BETWEEN 800 AND 1600 THEN 'Moderate'
    ELSE 'Expensive'
END AS price_range
FROM products;
```

**Insight:** Useful for marketing segmentation and discount strategies.
</details>

<details>
<summary><strong>📦 3. Find Unsold Products</strong></summary>

```sql
SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (
    SELECT product_id
    FROM order_items
);
```

**Insight:** Helps inventory team identify stagnant stock.
</details>

<details>
<summary><strong>🏪 4. Total Sales per Store (Using CTE)</strong></summary>

```sql
WITH sales AS (
    SELECT s.store_id, s.store_name, oi.order_id, oi.list_price, oi.quantity, oi.discount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN stores s ON o.store_id = s.store_id
)
SELECT store_name, SUM(quantity * list_price * (1 - discount)) AS total_sales
FROM sales
GROUP BY store_name
ORDER BY total_sales DESC;
```

**Insight:** Helps regional managers track which store is performing best in revenue.
</details>

<details>
<summary><strong>📅 5. Orders by Year (Timestamp Extraction)</strong></summary>

```sql
SELECT EXTRACT(YEAR FROM order_date) AS order_year, COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_year
ORDER BY order_year;
```

**Insight:** Identifies order volume trends across years.
</details>

<details>
<summary><strong>🏆 6. Top 3 Expensive Products per Category (Window Function)</strong></summary>

```sql
WITH ranked_products AS (
	SELECT c.category_name, p.product_id, p.product_name, p.list_price,
	RANK () OVER (
		PARTITION BY p.category_id
		ORDER BY p.list_price DESC
	) AS price_rank
	FROM products AS p
	JOIN categories AS c ON p.category_id = c.category_id
)
SELECT product_name, category_name, list_price, price_rank
FROM ranked_products
WHERE price_rank <= 3;
```

**Insight:** Useful for merchandising top-tier products in each category.
</details>

---

### ✅ What I Learned

- Writing clean, modular SQL queries using CTEs and subqueries
- Analyzing business performance using time series data
- Creating reusable queries to derive insights for different departments (Sales, Marketing, Inventory)
- Mastering advanced SQL features like window functions and dynamic categorization

---

### 📄 How to Use

1. Clone the repository
2. Import the SQL schema and sample data
3. Run queries from the `queries.sql` file or notebooks
4. Analyze outputs and adapt for business insight

---
