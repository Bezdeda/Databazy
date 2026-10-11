
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(quantity_sold * unit_price) AS total_sales
    FROM public.flourmills_sales
    GROUP BY sale_date
)
SELECT
    sale_date,
    total_sales
FROM daily_sales
WHERE total_sales > 3000000
ORDER BY total_sales DESC;



WITH category_sales AS (
    SELECT
        product_category,
        SUM(quantity_sold * unit_price) AS total_sales
    FROM public.flourmills_sales
    GROUP BY product_category
)
SELECT
    product_category,
    total_sales
FROM category_sales
ORDER BY total_sales DESC;



WITH product_sales AS (
    SELECT
        product_category,
        product_name,
        SUM(quantity_sold * unit_price) AS total_product_sales
    FROM public.flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT
        product_category,
        product_name,
        total_product_sales,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_product_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE category_rank BETWEEN 1 AND 3
ORDER BY product_category, category_rank;


WITH customer_revenue AS (
    SELECT
        customer_type,
        SUM(quantity_sold * unit_price) AS revenue
    FROM public.flourmills_sales
    GROUP BY customer_type
),
revenue_share AS (
    SELECT
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS revenue_percentage
    FROM customer_revenue
)
SELECT
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM revenue_share
ORDER BY revenue DESC;


WITH last_purchase AS (
    SELECT
        customer_id,
        product_name,
        sale_date,
        quantity_sold * unit_price AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC, sales_id DESC
        ) AS rn
    FROM public.flourmills_sales
)
SELECT
    customer_id,
    product_name,
    sale_date,
    total_sales
FROM last_purchase
WHERE rn = 1
ORDER BY customer_id ASC;


WITH RECURSIVE date_range AS (
    SELECT
        MIN(sale_date) AS min_date,
        MAX(sale_date) AS max_date
    FROM public.flourmills_sales
),
calendar AS (
    SELECT min_date AS sale_date
    FROM date_range

    UNION ALL

    SELECT (calendar.sale_date + INTERVAL '1 day')::date
    FROM calendar
    CROSS JOIN date_range
    WHERE calendar.sale_date < date_range.max_date
)
SELECT sale_date
FROM calendar
ORDER BY sale_date ASC;


WITH RECURSIVE monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(quantity_sold * unit_price) AS revenue
    FROM public.flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1

    UNION ALL

    SELECT
        next.rn,
        next.month,
        next.revenue,
        current.cumulative_revenue + next.revenue
    FROM cumulative_target AS current
    JOIN ordered_months AS next
        ON next.rn = current.rn + 1
    WHERE current.cumulative_revenue < 500000000
)
SELECT
    month,
    cumulative_revenue
FROM cumulative_target
ORDER BY rn;
