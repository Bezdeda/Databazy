-- Active: 1790517270206@@127.0.0.1@5432@datacraftinglab_db
CREATE DATABASE datacraftinglab_db;

CREATE TABLE flourmills_sales (
    sales_id INTEGER PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INTEGER,
    quantity_sold INTEGER,
    unit_price NUMERIC(10,2),
    discount_rate INTEGER,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INTEGER,
    production_date DATE,
    total_amount NUMERIC(10,2)
);

SELECT *
FROM flourmills_sales;


SELECT product_name, total_amount
FROM flourmills_sales
WHERE total_amount > (
    SELECT AVG(total_amount)
    FROM flourmills_sales
);

SELECT sales_id, sale_date, region, product_category
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
);

SELECT
    product_name,
    total_amount,
    (
        SELECT AVG(total_amount)
        FROM flourmills_sales
    ) AS avg_amount
FROM flourmills_sales;

SELECT
    product_name,
    total_amount,
    total_amount / (
        SELECT SUM(total_amount)
        FROM flourmills_sales
    ) AS amount_share
FROM flourmills_sales;

SELECT month, monthly_sales
FROM (
    SELECT
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_amount) AS monthly_sales
    FROM flourmills_sales
    GROUP BY EXTRACT(MONTH FROM sale_date)
) AS monthly_summary
ORDER BY monthly_sales DESC;

SELECT product_category, total_sales
FROM (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
) AS category_summary
WHERE total_sales > 50000000
ORDER BY total_sales DESC;

SELECT
    f1.product_name,
    f1.product_category,
    f1.total_amount
FROM flourmills_sales AS f1
WHERE f1.total_amount > (
    SELECT AVG(f2.Stotal_amount)
    FROM flourmills_sales AS f2
    WHERE f2.product_category = f1.product_category
);

SELECT
    f1.product_name,
    f1.region,
    f1.total_amount,
    (
        SELECT MIN(f2.total_amount)
        FROM flourmills_sales AS f2
        WHERE f2.region = f1.region
    ) AS region_min_amount
FROM flourmills_sales AS f1;

SELECT
    f1.product_name,
    f1.sale_date
FROM flourmills_sales AS f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS f2
    WHERE f2.product_name = f1.product_name
    GROUP BY f2.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM f2.sale_date)) > 1
);

SELECT
    f1.product_name,
    f1.product_category,
    f1.total_amount
FROM flourmills_sales AS f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS f2
    WHERE f2.product_category = f1.product_category
      AND f2.total_amount > 200000
);

SELECT DISTINCT f1.product_category
FROM flourmills_sales AS f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS f2
    WHERE f2.product_category = f1.product_category
    GROUP BY f2.product_category
    HAVING COUNT(DISTINCT f2.region) > 3
);

SELECT
    f1.product_name,
    f1.region,
    f1.sale_date
FROM flourmills_sales AS f1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales AS f2
    WHERE f2.region = f1.region
      AND EXTRACT(YEAR FROM f2.sale_date) = 2024
);