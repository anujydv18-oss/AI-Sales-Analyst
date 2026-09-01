-- ============================================================
-- AI-Sales-Analyst: SQL Analysis
-- Dataset: Olist Brazilian E-Commerce
-- Covers: revenue trends, customer segmentation & retention,
--         seller performance, delivery, and payment analysis
-- ============================================================

CREATE DATABASE ai_sales_analyst;
USE ai_sales_analyst;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM orders;

USE ai_sales_analyst;

SELECT COUNT(*) AS total_items
FROM order_items;

SELECT
    COUNT(*) AS total_items,
    COUNT(DISTINCT order_id) AS orders_with_items
FROM order_items;

SELECT
    o.order_id,
    o.order_status,
    oi.product_id,
    oi.price,
    oi.freight_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
LIMIT 10;

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_sellers
FROM sellers;

SELECT COUNT(*) AS total_payments
FROM order_payments;

SELECT COUNT(*) AS total_categories
FROM product_category_translation;

SELECT 
    ROUND(SUM(price), 2) AS Total_Revenue,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM order_items;

Select round(sum(price) / COUNT(DISTINCT order_id),2) as AOV FROM order_items;

with monthly_revenue as
(select date_format(o.order_purchase_timestamp, '%Y-%m') Months,
       sum(oi.price) as Revenue
from orders o 
join order_items oi on o.order_id = oi.order_id
group by date_format(o.order_purchase_timestamp, '%Y-%m')),

Previous_Rev as (select months,
       revenue,
       lag(revenue) over ( 
       order by months ) as Previous_Month_Revenue
from monthly_revenue 
)

select months,
       revenue,
       ROUND((Revenue - Previous_Month_Revenue) 
        / Previous_Month_Revenue * 100,2) AS Revenue_Change_Percent
from Previous_Rev 
order by months;

select date_format(order_purchase_timestamp, '%Y-%m') Months,
       count(distinct(order_id)) as Total_Order
from orders 
group by date_format(order_purchase_timestamp, '%Y-%m')
ORDER BY Months;

select date_format(o.order_purchase_timestamp, '%Y-%m') Months,
       count(distinct(o.order_id)) as Total_Order,
       ROUND(SUM(oi.price), 2) AS Total_Revenue,
       round(sum(oi.price) / COUNT(DISTINCT o.order_id),2) as AOV
from orders o 
join order_items oi on o.order_id = oi.order_id
group by date_format(o.order_purchase_timestamp, '%Y-%m')
order by Months;

select p.product_id,
       sum(oi.price) as Revenue
from products p
join order_items oi on p.product_id = oi.product_id
group by p.product_id
order by Revenue desc;
       
SELECT
    product_id,
    ROUND(SUM(price), 2) AS Revenue,
    COUNT(DISTINCT order_id) AS Total_Orders
FROM order_items
GROUP BY product_id
ORDER BY Revenue DESC
LIMIT 10;

SELECT
    pc.product_category_name_english AS Category,
    ROUND(SUM(oi.price), 2) AS Revenue,
    COUNT(DISTINCT oi.order_id) as Total_order,
    ROUND(
    SUM(oi.price) / COUNT(DISTINCT oi.order_id),
    2
) AS AOV
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN product_category_translation pc
    ON p.product_category_name = pc.product_category_name
GROUP BY pc.product_category_name_english
ORDER BY AOV DESC;

select count(distinct(order_id)) as orders,
       payment_type,
       sum(payment_value) as Amout
from order_payments 
group by payment_type;

select count(distinct(customer_id)) as Unique_customer,
       customer_state
from customers
group by customer_state
order by unique_customer desc;


select c.customer_state as State,
       count(distinct(c.customer_id)) as Total_Customer,
       count(distinct(o.order_id)) as Total_Order,
       sum(oi.price) as Revenue
from customers c 
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
group by c.customer_state
order by revenue desc;

select c.customer_unique_id as Customer,
       count(distinct(o.order_id)) orders
from customers c
join orders o on c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) > 1;

with customer_orders as (select c.customer_unique_id as Customer,
       count(distinct(o.order_id)) Total_orders
from customers c
join orders o on c.customer_id = o.customer_id
GROUP BY customer_unique_id)

select count(*) as Total_customer,
       sum(case when total_orders > 1 then 1 else 0 end ) as Repeat_customer,
       round(sum(case when total_orders > 1 then 1 else 0 end ) / count(*) * 100,2) AS Repeat_Customer_Percent
from customer_orders;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS Month,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_number
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
)

SELECT
    Month,
    COUNT(DISTINCT CASE 
        WHEN order_number = 1 THEN customer_unique_id 
    END) AS New_Customers,
    
    COUNT(DISTINCT CASE 
        WHEN order_number > 1 THEN customer_unique_id 
    END) AS Returning_Customers

FROM customer_orders
GROUP BY Month
ORDER BY Month;

select c.customer_unique_id,
       count(distinct(o.order_id)) As Total_Orders 
from customers c 
join orders o on c.customer_id = o.customer_id
group by c.customer_unique_id;

WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    Total_Orders,
    COUNT(*) AS Total_Customers
FROM customer_orders
GROUP BY Total_Orders
ORDER BY Total_Orders;

SELECT  c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Order,
        Sum(oi.price) as Revenue
from customers c 
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id 
group by c.customer_unique_id
order by Revenue desc 
limit 10;

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS Revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    ROUND(AVG(Revenue), 2) AS Average_Revenue_Per_Customer
FROM customer_revenue;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN Total_Orders = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS Customer_Type,
    COUNT(*) AS Total_Customers
FROM customer_orders
GROUP BY Customer_Type;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS Total_Orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS Revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),

customer_analysis AS (
    SELECT
        co.customer_unique_id,
        co.Total_Orders,
        COALESCE(cr.Revenue, 0) AS Revenue,
        CASE
            WHEN co.Total_Orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS Customer_Type
    FROM customer_orders co
    LEFT JOIN customer_revenue cr
        ON co.customer_unique_id = cr.customer_unique_id
)

SELECT
    Customer_Type,
    COUNT(*) AS Total_Customers,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(
        SUM(Revenue) / SUM(SUM(Revenue)) OVER () * 100,
        2
    ) AS Revenue_Percent
FROM customer_analysis
GROUP BY Customer_Type;

select c.customer_unique_id,
       DATE_FORMAT(
       MIN(o.order_purchase_timestamp),
       '%Y-%m'
) First_purchase_month
from customers c 
join orders o on c.customer_id = o.customer_id
group by c.customer_unique_id;

SELECT
    c.customer_unique_id,
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS Purchase_Month
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_unique_id,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY
    c.customer_unique_id,
    Purchase_Month;
    
    WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            MIN(o.order_purchase_timestamp),
            '%Y-%m'
        ) AS First_Purchase_Month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

purchase_months AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS Purchase_Month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)

SELECT
    f.customer_unique_id,
    f.First_Purchase_Month,
    p.Purchase_Month,

    TIMESTAMPDIFF(
        MONTH,
        STR_TO_DATE(CONCAT(f.First_Purchase_Month, '-01'), '%Y-%m-%d'),
        STR_TO_DATE(CONCAT(p.Purchase_Month, '-01'), '%Y-%m-%d')
    ) AS Months_Since_First_Purchase

FROM first_purchase f
JOIN purchase_months p
    ON f.customer_unique_id = p.customer_unique_id

ORDER BY
    f.customer_unique_id,
    p.Purchase_Month;
    
    WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            MIN(o.order_purchase_timestamp),
            '%Y-%m'
        ) AS First_Purchase_Month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

purchase_months AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS Purchase_Month
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

customer_activity AS (
    SELECT
        f.customer_unique_id,
        f.First_Purchase_Month,
        p.Purchase_Month,

        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(CONCAT(f.First_Purchase_Month, '-01'), '%Y-%m-%d'),
            STR_TO_DATE(CONCAT(p.Purchase_Month, '-01'), '%Y-%m-%d')
        ) AS Months_Since_First_Purchase

    FROM first_purchase f
    JOIN purchase_months p
        ON f.customer_unique_id = p.customer_unique_id
),

cohort_size AS (
    SELECT
        First_Purchase_Month,
        COUNT(DISTINCT customer_unique_id) AS Cohort_Customers
    FROM customer_activity
    GROUP BY First_Purchase_Month
)

SELECT
    ca.First_Purchase_Month,
    ca.Months_Since_First_Purchase,
    COUNT(DISTINCT ca.customer_unique_id) AS Retained_Customers,
    cs.Cohort_Customers,

    ROUND(
        COUNT(DISTINCT ca.customer_unique_id)
        / cs.Cohort_Customers * 100,
        2
    ) AS Retention_Percent

FROM customer_activity ca

JOIN cohort_size cs
    ON ca.First_Purchase_Month = cs.First_Purchase_Month

GROUP BY
    ca.First_Purchase_Month,
    ca.Months_Since_First_Purchase,
    cs.Cohort_Customers

ORDER BY
    ca.First_Purchase_Month,
    ca.Months_Since_First_Purchase;
    
    SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS Average_Delivery_Days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

SELECT
    COUNT(DISTINCT order_id) AS Total_Delivered_Orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS Late_Orders,

    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        )
        / COUNT(DISTINCT order_id) * 100,
        2
    ) AS Late_Order_Percent

FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

SELECT
    c.customer_state AS State,

    COUNT(DISTINCT o.order_id) AS Total_Delivered_Orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS Late_Orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        )
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS Late_Order_Percent

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY Late_Order_Percent DESC;

SELECT
    c.customer_state AS State,

    COUNT(DISTINCT o.order_id) AS Total_Delivered_Orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS Late_Orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        )
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS Late_Order_Percent

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

ORDER BY Late_Orders DESC;

SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS Month,

    COUNT(DISTINCT o.order_id) AS Delivered_Orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS Late_Orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        )
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS Late_Rate

FROM orders o

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')

ORDER BY Month;

WITH product_revenue AS (
    SELECT
        p.product_category_name,
        oi.product_id,
        SUM(oi.price) AS Revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_category_name,
        oi.product_id
),

ranked_products AS (
    SELECT
        product_category_name,
        product_id,
        Revenue,

        RANK() OVER (
            PARTITION BY product_category_name
            ORDER BY Revenue DESC
        ) AS Product_Rank

    FROM product_revenue
)

SELECT
    product_category_name,
    product_id,
    ROUND(Revenue, 2) AS Revenue,
    Product_Rank
FROM ranked_products
WHERE Product_Rank <= 3
ORDER BY
    product_category_name,
    Product_Rank;
    
    WITH category_revenue AS (
    SELECT
        p.product_category_name AS Category,
        SUM(oi.price) AS Revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_category_name
)

SELECT
    Category,
    ROUND(Revenue, 2) AS Revenue,

    ROUND(
        Revenue / SUM(Revenue) OVER () * 100,
        2
    ) AS Revenue_Contribution_Percent

FROM category_revenue

ORDER BY Revenue DESC;

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        ) AS Month,

        SUM(oi.price) AS Revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        DATE_FORMAT(
            o.order_purchase_timestamp,
            '%Y-%m'
        )
)

SELECT
    Month,
    ROUND(Revenue, 2) AS Revenue,

    ROUND(
        SUM(Revenue) OVER (
            ORDER BY Month
        ),
        2
    ) AS Cumulative_Revenue

FROM monthly_revenue

ORDER BY Month;

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id AS Customer,
        SUM(oi.price) AS Revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),

ranked_customers AS (
    SELECT
        Customer,
        Revenue,
        RANK() OVER (
            ORDER BY Revenue DESC
        ) AS Customer_Rank
    FROM customer_revenue
)

SELECT
    Customer,
    ROUND(Revenue, 2) AS Revenue,
    Customer_Rank
FROM ranked_customers
WHERE Customer_Rank <= 10
ORDER BY Customer_Rank;

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id AS Customer,
        SUM(oi.price) AS Revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    Customer,
    ROUND(Revenue, 2) AS Revenue,

    ROUND(
        Revenue / SUM(Revenue) OVER () * 100,
        2
    ) AS Revenue_Contribution_Percent

FROM customer_revenue

ORDER BY Revenue DESC;

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id AS Customer,
        SUM(oi.price) AS Revenue
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),

customer_segments AS (
    SELECT
        Customer,
        Revenue,
        NTILE(10) OVER (
            ORDER BY Revenue DESC
        ) AS Customer_Decile
    FROM customer_revenue
)

SELECT
    Customer_Decile,
    COUNT(*) AS Customers,
    ROUND(SUM(Revenue), 2) AS Revenue,
    ROUND(
        SUM(Revenue) /
        SUM(SUM(Revenue)) OVER () * 100,
        2
    ) AS Revenue_Percent
FROM customer_segments
GROUP BY Customer_Decile
ORDER BY Customer_Decile;

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id AS Customer,

        COUNT(DISTINCT o.order_id) AS Total_Orders,

        SUM(oi.price) AS Revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS Total_Customers,

    ROUND(SUM(Revenue), 2) AS Total_Revenue,

    ROUND(AVG(Revenue), 2) AS Average_Customer_Revenue,

    ROUND(AVG(Total_Orders), 2) AS Average_Orders_Per_Customer,

    ROUND(
        SUM(Revenue) / SUM(Total_Orders),
        2
    ) AS Average_Order_Value

FROM customer_metrics;

SELECT
    s.seller_id AS Seller,

    COUNT(DISTINCT oi.order_id) AS Total_Orders,

    COUNT(oi.product_id) AS Total_Items,

    ROUND(SUM(oi.price), 2) AS Revenue,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS AOV

FROM sellers s

JOIN order_items oi
    ON s.seller_id = oi.seller_id

GROUP BY s.seller_id

ORDER BY Revenue DESC

LIMIT 10;

SELECT
    oi.seller_id AS Seller,

    COUNT(DISTINCT o.order_id) AS Total_Orders,

    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END
    ) AS Late_Orders,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN o.order_id
            END
        )
        / COUNT(DISTINCT o.order_id) * 100,
        2
    ) AS Late_Delivery_Percent

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY oi.seller_id

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY Late_Delivery_Percent DESC;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'canceled'
        THEN o.order_id
    END) AS cancelled_orders,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN o.order_status = 'canceled'
            THEN o.order_id
        END)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS cancellation_rate

FROM orders o

GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')

ORDER BY month;

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    SUM(payment_value) AS total_payment,
    ROUND(
        SUM(payment_value) / SUM(SUM(payment_value)) OVER () * 100,
        2
    ) AS payment_share_pct
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment DESC;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    op.payment_type,
    COUNT(*) AS payments,
    ROUND(SUM(op.payment_value), 2) AS payment_value
FROM order_payments op
JOIN orders o
    ON op.order_id = o.order_id
GROUP BY
    month,
    op.payment_type
ORDER BY
    month,
    payment_value DESC;
    
    SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,

    COUNT(*) AS delivered_orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS late_delivery_rate

FROM orders o

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY month
ORDER BY month;

SELECT
    c.customer_state AS state,

    COUNT(*) AS delivered_orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) / COUNT(*) * 100,
    2
    ) AS late_delivery_rate

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY late_delivery_rate DESC;

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value,

    COUNT(DISTINCT o.customer_id) AS active_customers,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'canceled'
        THEN o.order_id
    END) AS cancelled_orders

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY month
ORDER BY month;