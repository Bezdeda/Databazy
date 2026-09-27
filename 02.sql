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