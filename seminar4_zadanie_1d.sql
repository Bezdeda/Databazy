WITH posledne_objednavky AS (
    SELECT
        customers.customer_name,
        orders.order_id,
        orders.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY orders.customer_id
            ORDER BY orders.order_date DESC
        ) AS poradie
    FROM orders
    JOIN customers ON orders.customer_id = customers.customer_id
)
SELECT customer_name, order_id, order_date
FROM posledne_objednavky
WHERE poradie <= 2
ORDER BY customer_name, poradie;

WITH posledne_objednavky AS (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS poradie
    FROM orders
)
SELECT COUNT(*)
FROM posledne_objednavky
WHERE poradie <= 2;

WITH zisky AS (
    SELECT
        customers.region,
        customers.customer_name,
        SUM(orders.profit) AS total_profit
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    GROUP BY customers.region, customers.customer_id, customers.customer_name
)
SELECT
    region,
    customer_name,
    ROUND(total_profit::numeric, 2) AS total_profit,
    RANK() OVER (
        PARTITION BY region
        ORDER BY total_profit DESC
    ) AS profit_rank,
    DENSE_RANK() OVER (
        PARTITION BY region
        ORDER BY total_profit DESC
    ) AS profit_dense_rank
FROM zisky
ORDER BY region, total_profit DESC;


WITH predaje AS (
    SELECT
        customers.customer_name,
        SUM(orders.sales) AS total_sales
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    GROUP BY customers.customer_id, customers.customer_name
)
SELECT
    customer_name,
    ROUND(total_sales::numeric, 2) AS total_sales,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
FROM predaje
ORDER BY total_sales DESC;

WITH mesacne_predaje AS (
    SELECT
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    ROUND(monthly_sales::numeric, 2) AS monthly_sales,
    ROUND(LAG(monthly_sales, 1) OVER (ORDER BY month)::numeric, 2) AS prev_month_sales,
    ROUND(LEAD(monthly_sales, 1) OVER (ORDER BY month)::numeric, 2) AS next_month_sales
FROM mesacne_predaje
ORDER BY month;

WITH objednavky AS (
    SELECT
        customer_id,
        MAX(order_date) OVER (
            PARTITION BY customer_id
        ) AS last_order_date,
        MAX(order_date) OVER () AS latest_order_date
    FROM orders
)
SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    o.last_order_date
FROM objednavky o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.last_order_date < o.latest_order_date - INTERVAL '90 days'
ORDER BY o.last_order_date ASC;