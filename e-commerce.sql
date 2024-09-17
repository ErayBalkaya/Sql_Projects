Query filtrelemelerinde lazım olabilecek veya dikkat edilmesi gereken bazı bilgileri not olması açısından buldum

select avg(price) from order_items
--120.65

select avg (order_delivered_customer_date-order_purchase_timestamp) 
from orders
WHERE order_status NOT IN ('unavailable','canceled')
--12 days 13:23:49

with total_order as (
select count(o.order_id) total_orders 
from orders o
join order_items oi on o.order_id=oi.order_id
join sellers s on oi.seller_id=s.seller_id
group by s.seller_id)
select round(avg (total_orders),2) 
from total_order
--satılan adet ortalaması 36.40

select p.payment_installments,count(o.order_id) 
from payments p
join orders o on p.order_id=o.order_id 
WHERE order_status NOT IN ('unavailable','canceled')
group by 1 
order by 2 desc
--taksit ödeme sayıları

select o.order_id,o.customer_id,o.order_status,
c.customer_unique_id,c.customer_city,
s.seller_city,
p.product_category_name
from orders o
join customers c on o.customer_id=c.customer_id
join order_items oi on oi.order_id=o.order_id
join sellers s on oi.seller_id=s.seller_id
join products p on p.product_id=oi.product_id
where 
o.customer_id='0aad2e31b3c119c26acb8a47768cd00a'
and order_status NOT IN ('unavailable','canceled')
--aynı order_id farklı şehirdeki satıcılardan alışveriş yapabiliyor

select * from orders
where order_approved_at  is null
and order_status NOT IN ('unavailable','canceled')
--sipariş onayı olmadan teslim edilen veya üretilen siparişler var.bu yüzden filtrelemede kullanmak için pek güvenilir değil.




CASE 1 : SİPARİŞ ANALİZİ

--1: Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.
--NOT:
--İptal edilen ve mevcutta bulunmayan ürünleri filtrelemedim.
--order_approved_at kolonu boş olan fakat gönderilmiş veya hazırlanmış siparişler olduğu için null kolonu çıkıyor.

SELECT 
	date_trunc('month',order_approved_at)::date AS months,
	COUNT (*)total_amount
FROM 
	orders 
GROUP BY 
	1
	
--2 :Aylık olarak order status kırılımında order sayılarını inceleyiniz. Sorgu sonucunda çıkan outputu excel ile görselleştiriniz. Dramatik bir düşüşün ya da 
yükselişin olduğu aylar var mı? Veriyi inceleyerek yorumlayınız.iptal edilen veya yolda olanları ayrı gösterebilirsin.
--NOT:
--Bir önceki soruda belirttiğim gibi , order_approved_at kolonu boş olan fakat gönderilmiş veya hazırlanmış siparişler olduğu için order_purchase_timestamp 
--kolonunun daha güvenilir olacağını düşündüm.

SELECT 
	date_trunc('month',order_purchase_timestamp)::date AS months,
	order_status,
	COUNT (order_id) total_amount
FROM 
	orders 
WHERE 
	order_status NOT IN ('unavailable','canceled')
GROUP BY 
	1,2
ORDER BY 
	1

SELECT 
	date_trunc('month',order_purchase_timestamp)::date as month,
	order_status,
	COUNT (*) total_amount
FROM 
	orders 
WHERE 
	order_status IN ('unavailable','canceled')
GROUP BY 
	1,2
ORDER BY 
	1
	
--3 :Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. Özel günlerde öne çıkan kategoriler nelerdir? Örneğin yılbaşı, sevgililer günü…
--Her kategoriden ne kadar sipariş var mesela yılbaşında
--NOT:
--Sipariş verme tarihini Black Friday'e göre aldım.Brezilya'da Black Friday indirimleri yaklaşık 1 hafta sürüyor ve genelde kasımın 20 29'u  gibi kutlanıyor.

WITH BLACKFRIDAY AS (
SELECT 
	P.PRODUCT_CATEGORY_NAME,
	T.CATEGORY_NAME_ENGLISH,
	COUNT( O.ORDER_ID)BLACKFRIDAY
FROM ORDERS O
JOIN 
	ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
JOIN 
	PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
LEFT JOIN 
	TRANSLATION T ON P.PRODUCT_CATEGORY_NAME = T.CATEGORY_NAME
WHERE EXTRACT(MONTH FROM ORDER_PURCHASE_TIMESTAMP) = 11
		AND EXTRACT(DAY FROM ORDER_PURCHASE_TIMESTAMP) BETWEEN 20 AND 29
			AND ORDER_STATUS NOT IN ('unavailable','canceled')
GROUP BY 
	P.PRODUCT_CATEGORY_NAME,
	T.CATEGORY_NAME_ENGLISH
ORDER BY 
	COUNT( O.ORDER_ID) DESC
)
,REST AS (
	SELECT 
	P.PRODUCT_CATEGORY_NAME,
	T.CATEGORY_NAME_ENGLISH,
	COUNT( O.ORDER_ID)SALES_NOT_BF 
FROM ORDERS O
JOIN 
	ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
JOIN 
	PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
LEFT JOIN 
	TRANSLATION T ON P.PRODUCT_CATEGORY_NAME = T.CATEGORY_NAME
WHERE EXTRACT(MONTH FROM ORDER_PURCHASE_TIMESTAMP) != 11
		AND EXTRACT(DAY FROM ORDER_PURCHASE_TIMESTAMP) NOT BETWEEN 20 AND 29
			AND ORDER_STATUS NOT IN ('unavailable','canceled')
GROUP BY 
	P.PRODUCT_CATEGORY_NAME,
	T.CATEGORY_NAME_ENGLISH
ORDER BY 
	COUNT( O.ORDER_ID) DESC
	)
,PERCENTAGE AS (
	SELECT 
    BF.PRODUCT_CATEGORY_NAME,
    BF.CATEGORY_NAME_ENGLISH,
    ROUND (
	(SUM(BF.BLACKFRIDAY) / SUM(BF.BLACKFRIDAY) OVER ()) * 100,2) AS BLACKFRIDAY_PERCENTAGE,
    ROUND (
	(SUM(REST.SALES_NOT_BF) / SUM(REST.SALES_NOT_BF) OVER ()) * 100,2) AS SALES_NOT_BF_PERCENTAGE
FROM 
    BLACKFRIDAY BF 
JOIN 
    REST ON BF.PRODUCT_CATEGORY_NAME = REST.PRODUCT_CATEGORY_NAME
GROUP BY 
    BF.PRODUCT_CATEGORY_NAME,
    BF.CATEGORY_NAME_ENGLISH,
    BF.BLACKFRIDAY,
    REST.SALES_NOT_BF
)
SELECT 
	PRODUCT_CATEGORY_NAME,
    CATEGORY_NAME_ENGLISH,
	BLACKFRIDAY_PERCENTAGE-SALES_NOT_BF_PERCENTAGE INCREASE_PER
FROM 
	PERCENTAGE 
WHERE
	BLACKFRIDAY_PERCENTAGE-SALES_NOT_BF_PERCENTAGE>0
ORDER BY
	BLACKFRIDAY_PERCENTAGE-SALES_NOT_BF_PERCENTAGE DESC


--Dünya'nın genelinde olduğu gibi Brezilya'da da en çok alışveriş yapılan dönemlerden biri olduğu için bu dönemi inceledim.Genel siparişlerde olduğu gibi bu 
--dönemde de en çok satış yapılan kategori bed_bath_table kategorisi.En çok sipariş verilen 2. ürün olmayı başaran ise mobilya dekorasyon ürünleri oluyor.Normalde 
--genel olarak pahalı diyebileceğimiz bu kategorideki ürünlerde yapılan Black Friday indiriminin sipariş sayısını arttırdığını düşünüyorum.Aynı durum oyuncaklar 
--kategorisinde de görülebilir.

--4 :Haftanın günleri(pazartesi, perşembe, ….) ve ay günleri (ayın 1’i,2’si gibi) bazında order sayılarını inceleyiniz. Yazdığınız sorgunun outputu ile excel’de 
--bir görsel oluşturup yorumlayınız.
	
---NOT : Siparişin verildiği tarihten aldım.İptal ve mevcutta bulunmayan siparişleri filtreledim.Soruda vurgulanan order sayısı olduğu için to_char kullandım.

SELECT 
	INITCAP(TO_CHAR(ORDER_PURCHASE_TIMESTAMP,'day'))DAYS,
	COUNT(DISTINCT ORDER_ID) TOTAL_ORDERS_PURCHASED
FROM 
	ORDERS
WHERE 
	ORDER_STATUS NOT IN ('canceled','unavailable')
GROUP BY 
	1
ORDER BY 
	2 DESC


SELECT 
	TO_CHAR(ORDER_PURCHASE_TIMESTAMP,'dd') DAYS_OFTHE_MONTHS,
	COUNT(DISTINCT ORDER_ID) TOTAL_ORDERS_PURCHASED
FROM 
	ORDERS
WHERE 
	ORDER_STATUS NOT IN ('canceled','unavailable')
GROUP BY 
	1
ORDER BY 
	2 DESC
--Brezilya da Black Friday 22-29 kasım tarihleri arasında kutlanıyor.Bu yüzden alışveriş sayısının ayın 24'nde diğer günlere göre yüksek olması beklenen bir durum..

CASE 2 : MÜŞTERİ ANALİZİ
	
--1 :Hangi şehirlerdeki müşteriler daha çok alışveriş yapıyor? Müşterinin şehrini en çok sipariş verdiği şehir olarak belirleyip analizi ona göre yapınız. 
--Örneğin; Sibel Çanakkale’den 3, Muğla’dan 8 ve İstanbul’dan 10 sipariş olmak üzere 3 farklı şehirden sipariş veriyor.Sibel’in şehrini en çok sipariş verdiği şehir 
--olan İstanbul olarak seçmelisiniz ve Sibel’in yaptığı siparişleri İstanbul’dan 21 sipariş vermiş şekilde görünmelidir.

--NOTLAR:
--1.İptal edilen ve mevcutta bulunmayan siparişleri denklemden çıkardım.
--2.ROW_NUMBER() yerine RANK() kullandığımda bazı müşteriler farklı şehirlerden eşit sayıda sipariş verdikleri için o iki şehir de yazacaktı.Tek şehir görünmesi için Row kullandım.

WITH CITY_RANK AS(
	SELECT 
		C.CUSTOMER_UNIQUE_ID,
		C.CUSTOMER_CITY,
		COUNT(O.ORDER_ID)TOTAL_ORDER,
		ROW_NUMBER() OVER (PARTITION BY C.CUSTOMER_UNIQUE_ID ORDER BY COUNT(O.ORDER_ID) DESC) RANKING
	FROM 
		CUSTOMERS C
	JOIN 
		ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
	WHERE 
		O.ORDER_STATUS NOT IN ('unavailable','canceled')
	GROUP BY 
		1,2
)
,TOTAL AS(
	SELECT 
		CUSTOMER_UNIQUE_ID,
		CUSTOMER_CITY,
		SUM(TOTAL_ORDER)TOPLAM
	FROM 
		CITY_RANK
	GROUP BY 
		1,2
	ORDER BY 
		SUM(TOTAL_ORDER) DESC
)
,COMBINE AS (
	SELECT 
		CITY_RANK.CUSTOMER_UNIQUE_ID,
		CITY_RANK.CUSTOMER_CITY,
		TOTAL.TOPLAM
	FROM 
		CITY_RANK
	JOIN
		TOTAL ON CITY_RANK.CUSTOMER_UNIQUE_ID = TOTAL.CUSTOMER_UNIQUE_ID
	WHERE
		CITY_RANK.RANKING = 1 
)
SELECT 
	CUSTOMER_CITY,
	SUM(TOPLAM)total_order_sum
FROM COMBINE
GROUP BY 
	1
ORDER BY 
	2 DESC


CASE 3: SATICI ANALİZİ
	
--1 :Siparişleri en hızlı şekilde müşterilere ulaştıran satıcılar kimlerdir? Top 5 getiriniz. Bu satıcıların order sayıları ile ürünlerindeki yorumlar ve puanlamaları inceleyiniz ve yorumlayınız.
--Yukarıda ortalama satış adetini 36 bulduğum için 36 orderdan fazla gönderim yapanları aldım.Siparişin verildiği ve müşterinin eline ulaştığı zaman aralığını aldım.


WITH DELIVERY_TIMES AS(
	SELECT 
		oi.SELLER_ID,
		ROUND(AVG(O.ORDER_DELIVERED_CUSTOMER_DATE::date - O.ORDER_PURCHASE_TIMESTAMP::date),2)ORDER_DELIVERY_TIME
	FROM 
		ORDERS O
	JOIN 
		ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN 
		SELLERS S ON OI.SELLER_ID = S.SELLER_ID
	where o.order_status like 'delivered'
	and o.ORDER_DELIVERED_CUSTOMER_DATE is not null
	and o.ORDER_PURCHASE_TIMESTAMP is not null
	
	GROUP BY 
		oi.SELLER_ID
	HAVING 
		COUNT( OI.ORDER_ID) > 36
	ORDER BY 
		ORDER_DELIVERY_TIME
)
	SELECT 
		DT.SELLER_ID,
		ORDER_DELIVERY_TIME,
		COUNT(OI.ORDER_ID)ORDER_TOTAL,
		ROUND(AVG(R.REVIEW_SCORE),2)REV_SCORE,
		COUNT(R.REVIEW_COMMENT_TITLE)COMMENT_COUNT,
		COUNT(R.REVIEW_COMMENT_MESSAGE)MESSAGE_COUNT
	FROM 
		DELIVERY_TIMES DT
	JOIN 
		ORDER_ITEMS OI ON DT.SELLER_ID = OI.SELLER_ID
	JOIN 
		REVIEWS R ON OI.ORDER_ID = R.ORDER_ID
	GROUP BY 
		DT.SELLER_ID,2
	ORDER BY 
		ORDER_DELIVERY_TIME
	LIMIT 
		5

--2 :Hangi satıcılar daha fazla kategoriye ait ürün satışı yapmaktadır? Fazla kategoriye sahip satıcıların order sayıları da fazla mı? 
--NOT:Kategorisi boş olmayanları ele aldım.İptal edilen ve mevcutta bulunmayan siparişleri denklemden çıkardım.


WITH CATEGORY_SALES AS (
	SELECT 
		OI.SELLER_ID,
		P.PRODUCT_CATEGORY_NAME,
		T.CATEGORY_NAME_ENGLISH,
		COUNT(O.ORDER_ID)ORDER_TOTAL
	FROM 
		ORDER_ITEMS OI
	JOIN 
		ORDERS O ON OI.ORDER_ID = O.ORDER_ID
	JOIN 
		PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
	LEFT JOIN 
		TRANSLATION T ON T.CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
	WHERE 
		ORDER_STATUS NOT IN ('unavailable','canceled')
	GROUP BY 
		OI.SELLER_ID,
		P.PRODUCT_CATEGORY_NAME,
		T.CATEGORY_NAME_ENGLISH
	ORDER BY 
		OI.SELLER_ID,
		ORDER_TOTAL DESC
)
	SELECT 
		SELLER_ID,
		COUNT(DISTINCT PRODUCT_CATEGORY_NAME)CATEGORY_COUNT,
		SUM(ORDER_TOTAL)ORDERS_SUM,
		ROUND((SUM(ORDER_TOTAL)/COUNT(DISTINCT PRODUCT_CATEGORY_NAME)),2) as sales_rate_per_category
	FROM 
		CATEGORY_SALES
	WHERE 
		PRODUCT_CATEGORY_NAME IS NOT NULL
	GROUP BY 
		SELLER_ID
	ORDER BY 
		4 DESC


CASE 4 : PAYMENT ANALİZİ
	
--1 :Ödeme yaparken taksit sayısı fazla olan kullanıcılar en çok hangi bölgede yaşamaktadır? Bu çıktıyı yorumlayınız.

--ORTALAMA TAKSİT SAYISINI 3 DEN FAZLASINI ALDIM.

SELECT 
	C.CUSTOMER_STATE,
	COUNT(DISTINCT O.ORDER_ID)TOTAL_DISTINCT_ORDER
FROM 
	PAYMENTS P
JOIN 
	ORDERS O ON P.ORDER_ID = O.ORDER_ID
JOIN 
	CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE 
	P.PAYMENT_INSTALLMENTS > 3
GROUP BY 
	1
ORDER BY 
	2 DESC

--Taksitli alışverişi daha çok kullanan bölgeler aynı zamanda ülkenin nüfusunun en yoğun olduğu bölgeler,az olan bölgeler ise nüfusun az olduğu bölgeler.Burada 
--taksit ve alışveriş adetlerinin nüfus ile doğru orantılı olduğunu görebiliyoruz.
	
with toplam as (
select  c.customer_state,
count(distinct o.order_id)total_distinct_order
from payments p
join orders o on p.order_id=o.order_id 
join customers c on o.customer_id=c.customer_id
group by 1
order by 2 desc
	),
	pesin as (
	select  c.customer_state,
count(distinct o.order_id)pesiN
from payments p
join orders o on p.order_id=o.order_id 
join customers c on o.customer_id=c.customer_id
where p.payment_installments<=2		
group by 1
order by 2 desc
	),
	taksit as (
		select  c.customer_state,
count(distinct o.order_id)taksit
from payments p
join orders o on p.order_id=o.order_id 
join customers c on o.customer_id=c.customer_id
where p.payment_installments>3		
group by 1
order by 2 desc
	)
	select t.customer_state ,
	round((pesin*1.0/total_distinct_order*1.0)* 100,2) pesin,
	round((taksit*1.0/total_distinct_order*1.0)* 100,2)taksit
	from toplam t 
	join pesin p on t.customer_state=p.customer_state
	join taksit ta on p.customer_state=ta.customer_state
	order by taksit desc

--Bence bu şekilde daha sağlıklı bilgi edinebiliriz.Bölgelerin pesin ve taksitli ödemelerine bakıp o bölgenin ekonomik durumu hakkında daha rahat yorum yapabiliriz.
--Örneğin yukarıda 3 taksitten fazla taksitle ödeme yapanlar SP bölgesinde en çok.Fakat burada gördüğümüz gibi yüzde olarak taksit seçeneğini daha az kullanan bölge
--yani taksitsiz alışverişin daha fazla olduğu bölge.


--2 :Ödeme tipine göre başarılı order sayısı ve toplam başarılı ödeme tutarını hesaplayınız. En çok kullanılan ödeme tipinden en az olana göre sıralayınız.

SELECT 
	P.PAYMENT_TYPE,
	COUNT(DISTINCT O.ORDER_ID)ORDER_COUNT,
	ROUND(SUM(P.PAYMENT_VALUE::decimal),2)TOTAL_PAYMENT
FROM 
	PAYMENTS P
JOIN 
	ORDERS O ON P.ORDER_ID = O.ORDER_ID
WHERE 
	ORDER_STATUS NOT IN ('unavailable','canceled')
GROUP BY 
	1
ORDER BY 
	2 DESC

--3 :Tek çekimde ve taksitle ödenen siparişlerin kategori bazlı analizini yapınız. En çok hangi kategorilerde taksitle ödeme kullanılmaktadır?

WITH PAYMENT_STYLE AS (
	SELECT 
		PR.PRODUCT_CATEGORY_NAME,
		T.CATEGORY_NAME_ENGLISH,
		P.PAYMENT_INSTALLMENTS,
		COUNT(DISTINCT O.ORDER_ID) TOTAL_ORDERS,
		CASE
			WHEN PAYMENT_INSTALLMENTS <= 1 THEN 'Tek Çekim'
			ELSE 'Taksitli'
		END AS PAY_TYPE,
		DENSE_RANK() OVER (PARTITION BY CASE WHEN PAYMENT_INSTALLMENTS <= 1 THEN 'Tek Çekim'
			ELSE 'Taksitli'
			END ORDER BY COUNT(DISTINCT O.ORDER_ID) DESC) AS RANKING
	FROM 
		PAYMENTS P
	JOIN 
		ORDERS O ON P.ORDER_ID = O.ORDER_ID
	JOIN 
		ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN 
		PRODUCTS PR ON PR.PRODUCT_ID = OI.PRODUCT_ID
	LEFT JOIN 
		TRANSLATION T ON PR.PRODUCT_CATEGORY_NAME = T.CATEGORY_NAME
	WHERE 
		O.ORDER_STATUS NOT IN ('unavailable','canceled')
	GROUP BY 
		1,2,3
)
		SELECT 
			*
		FROM 
			PAYMENT_STYLE
		WHERE 
			RANKING BETWEEN 1 AND 5

