-- Vytvorenie tabuliek
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(10,2),
    profit DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Uloha 2
SELECT 
    orders.order_id,
    customers.customer_name,
    orders.sales
FROM orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id
WHERE orders.sales > 500
ORDER BY orders.sales DESC;

SELECT
    orders.order_id,
    customers.customer_name,
    products.category,
    orders.sales
FROM orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id
INNER JOIN products
    ON orders.product_id = products.product_id;

SELECT
    customers.region,
    COALESCE(SUM(orders.sales), 0) AS total_sales
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY customers.region
ORDER BY customers.region;

SELECT
    products.product_name,
    COALESCE(SUM(orders.sales), 0) AS total_sales
FROM products
LEFT JOIN orders
    ON products.product_id = orders.product_id
GROUP BY products.product_name
ORDER BY products.product_name;

SELECT
    customers.customer_name,
    orders.order_id,
    orders.sales
FROM customers
FULL OUTER JOIN orders
    ON customers.customer_id = orders.customer_id;


SELECT
    customers.region,
    SUM(orders.sales) AS total_sales
FROM orders
INNER JOIN customers
    ON orders.customer_id = customers.customer_id
GROUP BY customers.region;


SELECT
    customers.customer_name,
    COUNT(orders.order_id) AS order_count
FROM customers
LEFT JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_name;

SELECT products.category,
AVG(orders.discount) AS average_discount
FROM products
INNER JOIN orders
ON products.product_id = orders.product_id
GROUP BY products.category;

SELECT
    customers.customer_name,
    SUM(orders.sales) AS total_sales
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_name
HAVING SUM(orders.sales) > 2000;


SELECT
    customers.region,
    SUM(orders.sales) AS total_sales,
    AVG(orders.discount) AS average_discount,
    COUNT(orders.order_id) AS order_count
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY customers.region;

-- Uloha 12

SELECT
    customers.region,
    COUNT(CASE WHEN orders.sales > 1000 THEN 1 END) AS high_value_count,
    COUNT(CASE WHEN orders.sales <= 1000 THEN 1 END) AS low_value_count
FROM customers
INNER JOIN orders
    ON customers.customer_id = orders.customer_id
GROUP BY customers.region;