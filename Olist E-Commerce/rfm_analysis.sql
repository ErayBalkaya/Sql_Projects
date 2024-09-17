select customerid,
max(invoicedate) from rfm
group by 1
order by 2 desc
--son fatura tarihinden 1 gün sonrasını bugün olarak alacağım.Yani 2011-12-10
select * from rfm where unitprice*quantity   <0
--iadeler
select count(distinct invoiceno),sum(unitprice*quantity) from rfm where customerid is null
--üye olmayanların toplam alışverişleri
select count(*) from rfm where description is null or description like ''
--açıklaması olmayan faturalar
select * from rfm where customerid is null or description like ''
--customerid si olmayan müşteriler
select * from rfm where invoiceno like 'C%' and quantity<=0
--iptal ve iade edilenler
--Sadece üye olan (customerid si olanlar) göre RFM hazırladım.
--Burada amacımız kullanıcıların sipariş alışkanlıklarını anlamak ve değerli kullanıcıları
--belirlemek olduğu için eksi değerleri ve customerid si olmayan kullanıcıları analize katmıyorum

--recency

SELECT 
	CUSTOMERID,
	'2011-12-10' - MAX(INVOICEDATE::date)TIME_PASSED
FROM 
	RFM
WHERE 
	CUSTOMERID IS NOT NULL 
	AND UNITPRICE * QUANTITY > 0
GROUP BY 
	CUSTOMERID
ORDER BY 
	CUSTOMERID


--frequency

SELECT 
	CUSTOMERID,
	COUNT (DISTINCT INVOICENO)TOTAL_INVOICE
FROM 
	RFM
WHERE 
	CUSTOMERID IS NOT NULL 
	AND UNITPRICE * QUANTITY > 0
GROUP BY 
	CUSTOMERID
ORDER BY 
	2 DESC
--monetary

SELECT 
	CUSTOMERID,
	ROUND(SUM(UNITPRICE * QUANTITY)::decimal,2)
FROM 
	RFM
WHERE CUSTOMERID IS NOT NULL
	AND UNITPRICE * QUANTITY > 0
GROUP BY 
	CUSTOMERID
ORDER BY 
	2
--RFM
WITH RFM_VALUES AS (
	SELECT 
	 	CUSTOMERID,
		'2011-12-10' - MAX(INVOICEDATE::date)RECENCY,
		COUNT (DISTINCT INVOICENO)FREQUENCY,
		ROUND(SUM(UNITPRICE * QUANTITY)::decimal,2)MONETARY
	FROM 
		RFM
	WHERE CUSTOMERID IS NOT NULL
		AND UNITPRICE * QUANTITY > 0
	GROUP BY 
		CUSTOMERID)
,RFM_RATES AS (
	SELECT 
		CUSTOMERID,
		RECENCY,
		NTILE(5) OVER (ORDER BY RECENCY DESC) RECENCY_SCORE,
		FREQUENCY,
		NTILE(5) OVER (ORDER BY FREQUENCY)FREQUENCY_SCORE,
		MONETARY,
		NTILE(5) OVER (ORDER BY MONETARY)MONETARY_SCORE
	FROM 
		RFM_VALUES)
,RFM_ANALYSIS AS (
	SELECT 
		CUSTOMERID,
		--RECENCY,
		RECENCY_SCORE,
		--FREQUENCY,
		FREQUENCY_SCORE,
		--MONETARY,
		MONETARY_SCORE,
		CONCAT(RECENCY_SCORE,FREQUENCY_SCORE,MONETARY_SCORE) RFM_SCORE
	FROM 
		RFM_RATES
	ORDER BY 
		CUSTOMERID)
SELECT *,
	CASE
		WHEN (RECENCY_SCORE = 1 OR RECENCY_SCORE = 2) AND (FREQUENCY_SCORE = 1 OR FREQUENCY_SCORE = 2) THEN 'Hibernating'
		WHEN (RECENCY_SCORE = 1 OR RECENCY_SCORE = 2) AND (FREQUENCY_SCORE = 3 OR FREQUENCY_SCORE = 4) THEN 'At Risk'
		WHEN (RECENCY_SCORE = 1 OR RECENCY_SCORE = 2) AND FREQUENCY_SCORE = 5 THEN 'Cant Loose'
		WHEN RECENCY_SCORE = 3 AND (FREQUENCY_SCORE = 1 OR FREQUENCY_SCORE = 2) THEN 'About_to_Sleep'
		WHEN RECENCY_SCORE = 3 AND FREQUENCY_SCORE = 3 THEN 'Need_Attention'
		WHEN (RECENCY_SCORE = 3 OR RECENCY_SCORE = 4) AND (FREQUENCY_SCORE = 4 OR FREQUENCY_SCORE = 5) THEN 'Loyal_Customers'
		WHEN RECENCY_SCORE = 4 AND FREQUENCY_SCORE = 1 THEN 'Promising'
		WHEN RECENCY_SCORE = 5 AND FREQUENCY_SCORE = 1 THEN 'New_Customers'
		WHEN (RECENCY_SCORE = 4 OR RECENCY_SCORE = 5) AND (FREQUENCY_SCORE = 2 OR FREQUENCY_SCORE = 3) THEN 'Potential_Loyalists'
		WHEN RECENCY_SCORE = 5 AND (FREQUENCY_SCORE = 4 OR FREQUENCY_SCORE = 5) THEN 'Champions'
	END AS CLIENT_SEGMENT
FROM 
	RFM_ANALYSIS;
--frequency 2

with frequency as (
select 
customerid,
invoiceno,
invoicedate::date,
LAG(invoicedate::date) OVER (PARTITION BY customerid ORDER BY invoicedate::date ) 
as prev_invoicedate
from rfm
where customerid is not null
	AND UNITPRICE * QUANTITY > 0
group by 1,invoiceno,3	
)
select customerid,
round(avg(invoicedate::date-prev_invoicedate),2) freq 
from frequency
group by customerid
---
with rfm_final as(
	select 
	customerid,
	max(invoicedate::date)last_invoice_date,
	ROUND(SUM(UNITPRICE * QUANTITY)::decimal,2)monetary
	from rfm
	where customerid is not null
	AND UNITPRICE * QUANTITY > 0
	group by customerid)
,freq as (
select 
customerid,
invoicedate::date,
LAG(invoicedate::date) OVER (PARTITION BY customerid ORDER BY invoicedate::date ) 
as prev_invoicedate
from rfm
where customerid is not null AND UNITPRICE * QUANTITY > 0	
group by 1,2
),
son as(
select 
rfm_final.customerid,
'2011-12-10'::date-last_invoice_date recency,
ntile(5) over (order by '2011-12-10'::date-last_invoice_date desc) recency_score,
monetary, 
ntile(5) over (order by monetary)monetary_score,
round(avg(invoicedate::date-prev_invoicedate),2) frequency,
ntile(5) over (order by round(avg(invoicedate::date-prev_invoicedate),2))frequency_score
from rfm_final 
	join freq on rfm_final.customerid=freq.customerid
group by rfm_final.customerid,2,4)
,graph as (
select customerid,recency_score,frequency_score,monetary_score,
concat(recency_score,frequency_score,monetary_score)
from son
order by customerid)
select * ,
case 
when (recency_score=1 or recency_score=2) AND (frequency_score=1 or frequency_score=2)  then 'Hibernating' 
when (recency_score=1 or recency_score=2)AND (frequency_score=3 or frequency_score=4)  then 'At Risk'
when (recency_score=1 or recency_score=2) AND frequency_score=5  then 'Cant Loose'
when recency_score=3 AND (frequency_score=1 or frequency_score=2) then 'About_to_Sleep' 
when recency_score=3 AND frequency_score=3 then 'Need_Attention'  
when (recency_score=3 or recency_score=4) AND (frequency_score=4 or frequency_score=5) then 'Loyal_Customers'
when recency_score=4 AND frequency_score=1 then 'Promising'
when recency_score=5 AND frequency_score=1 then 'New_Customers'
when (recency_score=4 or recency_score=5) AND (frequency_score=2 or frequency_score=3) then 'Potential_Loyalists'
when recency_score=5 AND (frequency_score=4 or frequency_score=5) then 'Champions' 
end 
as client_segment
from graph;
--aşağıdaki query de freq null yazanların tek bir kez alışveriş yaptıklarını görüyoruz.-
--days difference ı null olanlar sadece 1 kez sipariş verenler
--days difference ı 0 olanlar aynı gün birden çok fatura kesilenler

WITH InvoiceCTE AS (
  SELECT 
    customerid,
    COUNT(DISTINCT invoiceno) AS distinct_invoices,
    invoicedate::date AS invoice_date,
    LAG(invoicedate::date) OVER (PARTITION BY customerid ORDER BY invoicedate::date) AS previous_invoice_date,
    invoicedate::date - LAG(invoicedate::date) OVER (PARTITION BY customerid ORDER BY invoicedate::date) AS days_difference
  FROM 
    rfm
  GROUP BY 
    1, 3
)

SELECT 
  customerid,
  distinct_invoices,
  invoice_date,
  previous_invoice_date,
  days_difference
FROM InvoiceCTE
GROUP BY
  customerid,
  distinct_invoices,
  invoice_date,
  previous_invoice_date,
  days_difference
HAVING AVG(days_difference) =1;
