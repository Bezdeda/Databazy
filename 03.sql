-- Active: 1790517270206@@127.0.0.1@5432@retail
CREATE DATABASE retail;

CREATE TABLE retail_sales (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(10,2),
    customer_id INTEGER,
    country VARCHAR(100)
);

SELECT *
FROM retail_sales;

SELECT invoice_no, stock_code, quantity, invoice_date, COUNT(*)
FROM retail_sales
WHERE customer_id = 12346
GROUP BY invoice_no, stock_code, quantity, invoice_date
HAVING COUNT(*) > 1;

TRUNCATE TABLE retail_sales;

SELECT COUNT(*)
FROM retail_sales;

SELECT
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    quantity * unit_price AS revenue,
    SUM(quantity * unit_price) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    ) AS revenue_last_14_days
FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY customer_id, invoice_date;

SELECT
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(AVG(quantity) OVER (
        PARTITION BY stock_code, country
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
    ), 2) AS avg_quantity_7_days
FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;

WITH orders AS (
    SELECT DISTINCT
        customer_id,
        invoice_no,
        invoice_date::DATE AS invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
),
next_orders AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        LEAD(invoice_date) OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date, invoice_no
        ) AS next_invoice_date
    FROM orders
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    next_invoice_date - invoice_date AS days_to_next_invoice
FROM next_orders
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

WITH prices AS (
    SELECT
        stock_code,
        invoice_no,
        invoice_date,
        LAG(unit_price) OVER (
            PARTITION BY stock_code
            ORDER BY invoice_date
        ) AS previous_price,
        unit_price AS current_price
    FROM retail_sales
)
SELECT
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    current_price - previous_price AS price_difference
FROM prices
WHERE previous_price IS NOT NULL
AND current_price <> previous_price
ORDER BY invoice_date;

WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_amount,
    NTILE(4) OVER (
        ORDER BY total_amount DESC
    ) AS sales_quartile
FROM customer_sales
ORDER BY total_amount DESC;
SELECT COUNT(DISTINCT customer_id)
FROM retail_sales
WHERE customer_id IS NOT NULL;

WITH monthly_sales AS (
    SELECT
        country,
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    GROUP BY country, DATE_TRUNC('month', invoice_date)
)
SELECT
    country,
    month,
    total_amount,
    NTILE(4) OVER (
        PARTITION BY country
        ORDER BY total_amount DESC
    ) AS sales_quartile
FROM monthly_sales
ORDER BY country, month;