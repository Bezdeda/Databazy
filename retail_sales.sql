-- Active: 1790517270206@@127.0.0.1@5432@retail_sales@public

CREATE DATABASE retail_sales;


CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales NUMERIC(12,2) NOT NULL,
    profit NUMERIC(12,2) NOT NULL
);


ALTER DATABASE retail_sales
SET datestyle = 'ISO, MDY';


CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Celkovy predaj: %', total_sales;
END;
$$;

CALL get_customer_sales('C001');

SELECT COUNT(*)
FROM orders;



CREATE OR REPLACE PROCEDURE apply_regional_discount(
    region_name VARCHAR,
    discount_rate NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - discount_rate)
    WHERE region = region_name;

    RAISE NOTICE 'Zlava % pre region % bola aplikovana.',
    discount_rate, region_name;
END;
$$;


CREATE OR REPLACE PROCEDURE get_sales_between(
    start_date DATE,
    end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_sales NUMERIC(15,2);
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO total_sales
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'Od % do %: %',
    start_date, end_date, total_sales;
END;
$$;

CALL get_sales_between('2024-01-01', '2024-03-31');
