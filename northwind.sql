--1) Müşterilere doğru terapilerde bulunabilmek için müşteri segmentasyonu isteniyor.
--   Customer segmentation is required in order to provide the right therapies to customers.
--   Power BI (RFM)

WITH rfm_base AS (
    SELECT 
        o.customer_id,
        c.company_name,
        c.city,
        c.country,
        MAX(o.order_date) AS last_order_date,
        COUNT(o.order_id) AS total_orders,
        SUM(od.unit_price * od.quantity) AS total_spent
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    JOIN 
        customers c ON o.customer_id = c.customer_id
    GROUP BY 
        o.customer_id, c.company_name, c.city, c.country
),
rfm_scores AS (
    SELECT 
        customer_id,
        company_name,
        EXTRACT(DAY FROM AGE('1998-05-07', last_order_date)) AS recency,
        total_orders AS frequency,
        total_spent AS monetary
    FROM 
        rfm_base
),
rfm_class AS (
    SELECT
        customer_id,
        company_name,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score,
        CONCAT(
            NTILE(5) OVER (ORDER BY recency), 
            NTILE(5) OVER (ORDER BY frequency DESC), 
            NTILE(5) OVER (ORDER BY monetary DESC)
        ) AS rfm_note
    FROM 
        rfm_scores
)
SELECT 
    customer_id,
    company_name,
	recency_score,frequency_score,monetary_score,
    rfm_note,
    CASE
        WHEN (recency_score = 1 OR recency_score = 2) AND (frequency_score = 1 OR frequency_score = 2) THEN 'Hibernating'
        WHEN (recency_score = 1 OR recency_score = 2) AND (frequency_score = 3 OR frequency_score = 4) THEN 'At Risk'
        WHEN (recency_score = 1 OR recency_score = 2) AND frequency_score = 5 THEN 'Cant Lose'
        WHEN recency_score = 3 AND (frequency_score = 1 OR frequency_score = 2) THEN 'About to Sleep'
        WHEN recency_score = 3 AND frequency_score = 3 THEN 'Need Attention'
        WHEN (recency_score = 3 OR recency_score = 4) AND (frequency_score = 4 OR frequency_score = 5) THEN 'Loyal Customers'
        WHEN recency_score = 4 AND frequency_score = 1 THEN 'Promising'
        WHEN recency_score = 5 AND frequency_score = 1 THEN 'New Customers'
        WHEN (recency_score = 4 OR recency_score = 5) AND (frequency_score = 2 OR frequency_score = 3) THEN 'Potential Loyalists'
        WHEN recency_score = 5 AND (frequency_score = 4 OR frequency_score = 5) THEN 'Champions'
    END AS client_segment
FROM 
    rfm_class
ORDER BY 
    customer_id;


--2) Satın alma bölümü ürünlerin stok durumlarını ve tekrar sipariş verilip verilmemesi gerektiğini öğrenmek istiyor.
--   The purchasing department wants to know the stock status of the products and whether they should be reordered or not.
--   Power BI (PRODUCTS)

SELECT 
    p.product_name,
    p.unit_in_stock,
    p.reorder_level,
    COALESCE(SUM(od.quantity), 0) AS total_orders,
    CASE 
        WHEN p.unit_in_stock <= p.reorder_level THEN 'Reorder Needed'
        ELSE 'Stock Sufficient'
    END AS reorder_status
FROM 
    products p
LEFT JOIN 
    order_details od ON p.product_id = od.product_id
WHERE
    p.discontinued = 0
GROUP BY 
    p.product_name, p.unit_in_stock, p.reorder_level
ORDER BY 
    p.product_name ASC;
	
--or

SELECT 
    p.product_name,
    p.unit_in_stock,
    p.reorder_level,
    COALESCE(SUM(od.quantity), 0) AS total_orders,
    CASE 
        WHEN p.discontinued = 1 THEN 'No Longer Sold'
        WHEN p.unit_in_stock <= p.reorder_level THEN 'Reorder Needed'
        ELSE 'Stock Sufficient'
    END AS stock_status
FROM 
    products p
LEFT JOIN 
    order_details od ON p.product_id = od.product_id
GROUP BY 
    p.product_name, p.unit_in_stock, p.reorder_level, p.discontinued
ORDER BY 
    p.unit_in_stock ASC;

	
	
--3) IK bölümü çalışanların performanslarının ölçülmesini ve aylık karşılaştırılmasını istiyor.
--   The HR department wants the performance of employees to be measured and compared monthly.
--   Power BI (EMPLOYEES)

WITH employee_sales AS (
    SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    EXTRACT(MONTH FROM o.order_date) AS order_month,
    count (distinct(o.order_id)) AS total_orders,
    SUM(od.quantity) AS total_products_sold,
    ROUND(AVG(od.unit_price * od.quantity)::NUMERIC, 2) AS avg_order_value,
    ROUND(AVG(od.discount)::NUMERIC, 2) AS avg_discount,
    ROUND(SUM(od.unit_price * od.quantity)::NUMERIC, 2) AS total_sales,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC - SUM(o.freight)::NUMERIC, 2) AS total_income
FROM 
    employees e
JOIN 
    orders o ON e.employee_id = o.employee_id
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    e.employee_id, full_name, order_year, order_month
),
monthly_sales AS (
    SELECT 
        employee_id,
        full_name,
        order_year,
        order_month,
        total_orders,
        total_products_sold,
        avg_order_value,
        avg_discount,
        total_sales,
        total_income,
        CASE 
            WHEN LAG(total_products_sold) OVER (PARTITION BY employee_id ORDER BY order_year, order_month) IS NULL THEN 0
            ELSE ROUND(
                (total_products_sold - LAG(total_products_sold) OVER (PARTITION BY employee_id ORDER BY order_year, order_month))::NUMERIC * 100.0 / 
                LAG(total_products_sold) OVER (PARTITION BY employee_id ORDER BY order_year, order_month)::NUMERIC
                , 2)
        END AS products_sold_diff_percentage,
        CASE 
            WHEN LAG(total_income) OVER (PARTITION BY employee_id ORDER BY order_year, order_month) IS NULL THEN 0
            ELSE ROUND(
                (total_income - LAG(total_income) OVER (PARTITION BY employee_id ORDER BY order_year, order_month))::NUMERIC * 100.0 / 
                LAG(total_income) OVER (PARTITION BY employee_id ORDER BY order_year, order_month)::NUMERIC
                , 2)
        END AS income_diff_percentage
    FROM employee_sales
)
SELECT 
    employee_id,
    full_name,
    order_year,
    order_month,
    total_orders,
    total_products_sold,
    avg_order_value,
    avg_discount,
    total_sales,
    total_income,
    products_sold_diff_percentage,
    income_diff_percentage
FROM monthly_sales
ORDER BY employee_id, order_year, order_month;


--4) Ürün kategorilerinin aylık indirimli satış tutarları ve satış oranları.(Navlun hariç)
--   Monthly discounted sales amounts and sales rates of product categories. (Excluding freight)
--   Power BI (PRODUCTS)

WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        p.category_id,
        c.category_name,
        SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
    FROM
        orders o
    JOIN
        order_details od ON o.order_id = od.order_id
    JOIN
        products p ON od.product_id = p.product_id
    JOIN
        categories c ON p.category_id = c.category_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        p.category_id,
        c.category_name
),
monthly_totals AS (
    SELECT
        year,
        month,
        SUM(total_sales) AS total_sales_all_categories
    FROM
        monthly_sales
    GROUP BY
        year,
        month
)
SELECT
    ms.year,
    ms.month,
    ms.category_name,
    ms.total_sales,
    (ms.total_sales::float / mt.total_sales_all_categories) * 100 AS sales_percentage
FROM
    monthly_sales ms
JOIN
    monthly_totals mt ON ms.year = mt.year AND ms.month = mt.month
ORDER BY
    ms.year,
    ms.month,
    ms.category_name;
	

--5) Kaç sipariş zamanında teslim edildi, geç teslim edildi veya gönderilmedi.
--   How many orders were delivered on time, late, and not shipped.
--   Power BI (TOOLTIP SHIPPING)
WITH delivery_status AS (
    SELECT
        od.product_id,
        CASE
            WHEN o.shipped_date IS NULL THEN 'Not Shipped'
            WHEN o.shipped_date <= o.required_date THEN 'On Time'
            ELSE 'Late'
        END AS delivery_status
    FROM
        orders o
    JOIN
        order_details od ON o.order_id = od.order_id
)
SELECT
    delivery_status,
    COUNT(*) AS product_count
FROM
    delivery_status
GROUP BY
    delivery_status;

--6) Elmizdeki data tarihlerinin başından beri her ayın trend  ürünü nedir,kaç adet satılmıştır ve indirim sonucunda bu üründen ne kadar gelir elde edilmiştir.(Navlun hariç)
--   What is the trend product of each month since the beginning of the data we have, how many units were sold and how much income was obtained from this product as a result of the discount (excluding freight).   
--   Python

WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        p.product_name,
        c.category_name,  
        SUM(od.quantity) AS total_quantity,
        ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::NUMERIC, 2) AS total_income
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    JOIN 
        products p ON od.product_id = p.product_id
	JOIN
		categories c ON c.category_id=p.category_id
    GROUP BY 
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        p.product_name,
        c.category_name 
)
SELECT 
    year,
    month,
    product_name,
    category_name,  
    total_quantity,
    total_income
FROM (
    SELECT 
        year,
        month,
        product_name,
        category_name,  
        total_quantity,
        total_income,
        RANK() OVER (PARTITION BY year, month ORDER BY total_quantity DESC) AS rank
    FROM 
        monthly_sales
) ranked_sales
WHERE 
    rank = 1
ORDER BY 
    year, 
    month;

--7 ) Kategori isimlerine göre her ürünün aylık fiyat değişimi ve oranları nedir ?
--    Monthly price change percentages by category
--    Python

WITH monthly_prices AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        c.category_name,
        AVG(od.unit_price) AS avg_price
    FROM
        orders o
    JOIN
        order_details od ON o.order_id = od.order_id
    JOIN
        products p ON od.product_id = p.product_id
    JOIN
        categories c ON p.category_id = c.category_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        c.category_name
),
price_changes AS (
    SELECT
        mp1.year,
        mp1.month,
        mp1.category_name,
        mp1.avg_price AS current_price,
        LAG(mp1.avg_price) OVER (PARTITION BY mp1.category_name ORDER BY mp1.year, mp1.month) AS previous_price
    FROM
        monthly_prices mp1
)
SELECT
    pc.year,
    pc.month,
    pc.category_name,
    pc.current_price,
    pc.previous_price,
    CASE
        WHEN pc.previous_price IS NULL THEN NULL
        ELSE ((pc.current_price - pc.previous_price) / pc.previous_price) * 100
    END AS price_change_percentage
FROM
    price_changes pc
WHERE
    pc.previous_price IS NOT NULL
    AND ((pc.current_price - pc.previous_price) / pc.previous_price) * 100 <> 0
ORDER BY
    pc.category_name,
    pc.year,
    pc.month;
	
	
	
	
