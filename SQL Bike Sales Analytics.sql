--Find total number of products under each brand
SELECT b.brand_id, b.brand_name, COUNT(p.product_name) AS count
FROM brands as b
JOIN products p ON p.brand_id = b.brand_id
GROUP BY b.brand_id, b.brand_name
ORDER BY count DESC;


--Find average list price of products per category
SELECT c.category_id, c.category_name, AVG(p.list_price) AS avg_list_price
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY avg_list_price DESC;


--Find maximum and minimum list price of products in each category
SELECT c.category_id ,c.category_name, MAX(p.list_price) AS max_price, MIN(p.list_price) AS min_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id ,c.category_name;


--Label orders as 'On Time' or 'Late' based on shipping and required dates
SELECT order_id,
CASE
    WHEN shipped_date <= required_date THEN 'On Time'
    ELSE 'Late'
END AS shipping_status
FROM orders;


--Label products as 'Cheap', 'Moderate', 'Expensive' based on list_price
SELECT product_id, product_name, list_price,
CASE
    WHEN list_price < 800 THEN 'Cheap'
    WHEN list_price BETWEEN 800 AND 1600 THEN 'Moderate'
    ELSE 'Expensive'
END AS price_range
FROM products;


--Find customers who live in 'New York' city
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS full_name, city
FROM customers
WHERE city = 'New York';


--List all orders with customer names
SELECT o.order_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers AS c
JOIN orders as o
ON c.customer_id = o.customer_id
;



 --Find customers who have placed more than 2 orders
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name
FROM customers
WHERE customer_id IN (
	SELECT customer_id
	FROM orders
	GROUP BY customer_id
	HAVING COUNT(order_id) > 2
);


--List products that have not been sold yet
SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (
	SELECT product_id
	FROM order_items
);


--Find each store’s total sales using a CTE
WITH sales AS (
	SELECT s.store_id, s.store_name, oi.order_id, oi.list_price, oi.quantity, oi.discount
	FROM orders o
	JOIN order_items oi ON o.order_id = oi.order_id
	INNER JOIN stores s ON o.store_id = s.store_id
)

SELECT store_name, SUM(quantity * list_price * (1 - discount)) as total_sales
FROM sales
GROUP BY store_name
ORDER BY total_sales DESC
;


--Using a CTE, list customers who spent more than $15,000
WITH customer_spent AS (
	SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, oi.quantity, oi.discount, oi.list_price
	FROM customers c
	JOIN orders o ON o.customer_id = c.customer_id
	JOIN order_items oi ON oi.order_id = o.order_id
)

SELECT full_name, SUM(quantity * list_price * (1-discount)) AS spent
FROM customer_spent
GROUP BY full_name
HAVING SUM(quantity * list_price * (1-discount)) > 15000
;


--Find how many orders were placed in each year
SELECT EXTRACT(YEAR FROM order_date) AS order_year, COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_year
ORDER BY order_year
;



--Find the top 3 most expensive products in each category
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
WHERE price_rank <= 3
;


-- Running Total of Sales by Store
SELECT s.store_name, o.order_id, o.order_date,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) OVER (
    PARTITION BY s.store_id
    ORDER BY o.order_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores s ON o.store_id = s.store_id
ORDER BY s.store_name, o.order_date;
