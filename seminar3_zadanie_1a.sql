-- Active: 1790517270206@@127.0.0.1@5432@superstore@public

CREATE OR REPLACE VIEW high_value_customers AS
SELECT
    customers.customer_id,
    customers.customer_name,
    SUM(orders.sales) AS total_sales
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY
    customers.customer_id,
    customers.customer_name
HAVING SUM(orders.sales) > 2000;

SELECT *
FROM high_value_customers;

SELECT COUNT(*)
FROM high_value_customers;

CREATE OR REPLACE VIEW regional_monthly_sales AS
SELECT
    customers.region,
    DATE_TRUNC('month', orders.order_date) AS month,
    SUM(orders.sales) AS monthly_sales
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY
    customers.region,
    DATE_TRUNC('month', orders.order_date);

SELECT *
FROM regional_monthly_sales
WHERE region = 'West';