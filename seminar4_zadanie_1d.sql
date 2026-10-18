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