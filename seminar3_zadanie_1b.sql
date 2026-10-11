
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
