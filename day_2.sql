select 
    count(distinct p.product_category_name) as total_category
from products p;


select 'customer' as category,count(distinct c.customer_unique_id) from customers c 
union all
select 'seller' as category, count(seller_id) from sellers s 

select c.customer_city ,count(distinct c.customer_unique_id)
	from customers c 
	group by c.customer_city 
	order by count(*) desc 
	limit 10
	
-- 4 --
select c.customer_city ,
	count(distinct c.customer_unique_id) as total,
	round(count(distinct c.customer_unique_id) * 1.0 / (select count(distinct c.customer_unique_id) * 1.0 from customers c) * 100,2) as percentage
from customers c 
group by c.customer_city 
order by count(*) desc 
limit 10

select p.product_category_name,
	count(*)
	from products p 
	group by p.product_category_name 
	order by count(*) desc 
	limit 10

-- 6 --
select 
	'height_cm' as category,
    min(p.product_height_cm) as min_height,
    percentile_disc(0.25) within group (order by p.product_height_cm) as Q1,
    percentile_disc(0.5) within group (order by p.product_height_cm) as Q2,
    percentile_disc(0.75) within group (order by p.product_height_cm) as Q3,
    max(p.product_height_cm) as max_height
from products p
union all
select 
	'length_cm' as category,
    min(p.product_length_cm) as min_length,
    percentile_disc(0.25) within group (order by p.product_length_cm) as Q1,
    percentile_disc(0.5) within group (order by p.product_length_cm) as Q2,
    percentile_disc(0.75) within group (order by p.product_length_cm) as Q3,
    max(p.product_length_cm) as max_length
from products p
union all
select 
	'weight_g' as category,
    min(p.product_weight_g) as min_weight,
    percentile_disc(0.25) within group (order by p.product_weight_g) as Q1,
    percentile_disc(0.5) within group (order by p.product_weight_g) as Q2,
    percentile_disc(0.75) within group (order by p.product_weight_g) as Q3,
    max(p.product_weight_g) as max_weight
from products p
union all
select 
	'width_cm' as category,
    min(p.product_width_cm) as min_width,
    percentile_disc(0.25) within group (order by p.product_width_cm) as Q1,
    percentile_disc(0.5) within group (order by p.product_width_cm) as Q2,
    percentile_disc(0.75) within group (order by p.product_width_cm) as Q3,
    max(p.product_width_cm) as max_width
from products p

-- 7 --
select o.order_purchase_timestamp from orders o limit 10

select 
	to_char(o.order_purchase_timestamp, 'Day') as day_of_purchase,
	count(*) as total_purchase
from orders o 
group by to_char(o.order_purchase_timestamp, 'Day')
order by total_purchase desc 

-- 8 --
select * from orders o where o.order_status = 'canceled' order by order_status asc 


select 'order canceled' as type,count(*) from orders o 
where o.order_status = 'canceled'
group by o.order_status
union all 
select 'order approved' as type,count(*) from orders o 
where order_status = 'canceled' and o.order_approved_at is not null 
union all 
select 'order approved' as type,count(*) from orders o 
where order_status = 'canceled' and o.order_delivered_carrier_date is not null 
union all 
select 'order delivered customer' as type,count(*) from orders o 
where order_status = 'canceled' and o.order_delivered_customer_date is not null 

-- 9 --
select p.payment_type,
count(*) as total,
(count(*) * 1.0) / sum(count(*)) over() as prop_canceled
from orders o 
join payments p on p.order_id = o.order_id
where o.order_status = 'canceled'
group by p.payment_type 
order by total desc 

-- 10 --
select 
case when p.product_category_name = '' then 'Other' 
else p.product_category_name end as category,
oi.product_id ,
oi.price,
dense_rank() over(partition by p.product_category_name order by oi.price desc) as rank_price
from order_items oi
join products p on p.product_id = oi.product_id 
--group by p.product_category_name,2,3
order by category asc ,oi.price desc

with ranked as(
	select distinct 
	case when p.product_category_name = '' then 'Other' 
	else p.product_category_name end as category,
	oi.product_id ,
	oi.price,
	dense_rank() over(partition by p.product_category_name order by oi.price desc) as rank_price
	from order_items oi
	join products p on p.product_id = oi.product_id 
	order by category asc ,oi.price desc

)
select * from ranked
where rank_price = 3

-- 11 --
select replace(cast(o.order_id as text),'-','') as id_order from orders o
limit 10

select 'On Time' as type,round(sum(r.review_score)/count(*),2)
from orders o
join reviews r on r.order_id = replace(cast(o.order_id as text),'-','')
where o.order_delivered_customer_date <= o.order_estimated_delivery_date 
union all
select 'Late' as type,round(sum(r.review_score)/count(*),2)
from orders o
join reviews r on r.order_id = replace(cast(o.order_id as text),'-','')
where o.order_delivered_customer_date > o.order_estimated_delivery_date 

-- 12 --
select 
--extract(doy from o.order_delivered_customer_date),
--extract(doy from o.order_purchase_timestamp),
extract(doy from o.order_delivered_customer_date) - extract(doy from o.order_purchase_timestamp)) as days,
count(*)
from orders o 
where o.order_status = 'delivered'
group by days
order by count(*) desc 

select 
round(extract(epoch from (o.order_delivered_customer_date - o.order_purchase_timestamp)) / (24*60*60)) as days,
count(*)
from orders o 
where o.order_status = 'delivered'
group by days
order by count(*) desc 

-- 13 --
select * from customers c limit 10

select * from orders o where o.customer_id  = '06b8999e-2fba-1a1f-bc88-172c00ba8bc7'

select distinct c.customer_id , 
sum(p.payment_value) as revenue,
count(*) as total_order,
avg(p.payment_value) as avg_purchase
from customers c 
join orders o on o.customer_id = c.customer_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1
order by avg_purchase desc 
limit 10

select distinct c.customer_id , 
sum(p.payment_value) as revenue,
count(*) as total_order,
sum(payment_value) / count(distinct o.order_id) as avg_purchase
from customers c 
join orders o on o.customer_id = c.customer_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1,o.order_id 
order by avg_purchase desc 
limit 100

-- 14 --
select o.customer_id,c.customer_id,c.customer_unique_id from orders o
join customers c on c.customer_id  = o.customer_id 
limit 50


select distinct c.customer_unique_id,
count(o.order_id) over(partition by c.customer_unique_id) as total_order,
count(c.customer_unique_id) over () as total_unique_cust,
count(o.order_id) over(partition by c.customer_unique_id)::numeric / (count(c.customer_unique_id) over ())::numeric  as avg_freq
from customers c 
join orders o on o.customer_id = c.customer_id 
join payments p on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by 1,o.order_id 
order by total_order desc 

WITH customer_stats AS (
    SELECT 
        c.customer_unique_id,
        COUNT( o.order_id) over(partition by c.customer_unique_id) AS total_order,
        --COUNT( c.customer_unique_id) OVER () AS total_unique_cust
        (select count(distinct c.customer_unique_id)
			from customers c 
			JOIN orders o ON o.customer_id = c.customer_id
			WHERE o.order_status = 'delivered') 
		as total_unique
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN payments p ON p.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    group by 1, o.order_id
)
SELECT DISTINCT
    customer_unique_id,
    total_order,
    total_unique,
    (total_order::numeric / total_unique) AS avg_freq
FROM customer_stats
ORDER BY avg_freq desc
limit 10




select count(distinct c.customer_unique_id)
from customers c 
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'

-- 15 --
WITH customer_stats AS (
    SELECT 
        c.customer_unique_id,
        COUNT( o.order_id) over(partition by c.customer_unique_id) AS total_order,
        --COUNT( c.customer_unique_id) OVER () AS total_unique_cust
        (select count(distinct c.customer_unique_id)
			from customers c 
			JOIN orders o ON o.customer_id = c.customer_id
			WHERE o.order_status = 'delivered') 
		as total_unique,
		sum(p.payment_value) as revenue -- / count( o.order_id) as avg_purchase,
		-- count(distinct o.order_id) as totall
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN payments p ON p.order_id = o.order_id
    WHERE o.order_status = 'delivered' and c.customer_unique_id != 'da122df9-eedd-fedc-1dc1-f5349a1a690c'
    group by 1,o.order_id
)
SELECT 
    customer_unique_id,
    (revenue) / total_order as avg_purchase,
    (total_order::numeric / total_unique) AS avg_freq,
    (revenue / total_order) * (total_order::numeric / total_unique) as customer_value,
    total_unique,
    revenue,
    total_order
FROM customer_stats
ORDER BY customer_value desc
limit 15

select p.* from customers c
join orders o on c.customer_id = o.customer_id 
join order_items oi on oi.order_id = o.order_id 
join payments p on p.order_id = o.order_id 
where customer_unique_id = 'da122df9-eedd-fedc-1dc1-f5349a1a690c'

select p.* from customers c
join orders o on c.customer_id = o.customer_id 
join order_items oi on oi.order_id = o.order_id 
join payments p on p.order_id = o.order_id 
where o.customer_id = '926b6a6f-b8b6-081e-00b3-35edaf578d35'


-- Session 2 --

-- 1 --
select o.order_status ,count(*) as total_order
from orders o 
group by o.order_status 
order by total_order desc 

-- 2 --
select distinct p.product_category_name 
from orders o 
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id  = oi.product_id 
where o.order_status = 'canceled'
group by p.product_category_name 

select distinct
	case when p.product_category_name = '' then 'Other' else p.product_category_name end as category,
	count(distinct o.order_id) as total_order
from orders o 
join order_items oi on oi.order_id = o.order_id 
join products p on p.product_id  = oi.product_id 
where o.order_status = 'canceled'
group by p.product_category_name 
order by total_order desc 

-- 3 --
select c.customer_unique_id ,c.customer_city ,o.order_status , o.order_delivered_customer_date 
from customers c 
join orders o on o.customer_id = c.customer_id 
where o.order_status = 'canceled' and o.order_delivered_customer_date is not null

-- 4 --
select p.payment_type,p.payment_installments,p.payment_value from payments p 
where p.payment_type  = 'credit_card'

select * from orders o 
where order_id = 'a9c8ac0c-26c1-78f0-ad33-618f96225a01'

select * from order_items o 
where order_id = 'a9c8ac0c-26c1-78f0-ad33-618f96225a01'

select * from payments p 
where p.order_id = 'a9c8ac0c-26c1-78f0-ad33-618f96225a01'

select 
	s.seller_id ,
	s.seller_city ,
	p.payment_installments,p.payment_value ,oi.price ,
	p.payment_value,o.order_id
	--(sum(p.payment_installments) * sum(p.payment_value)) as total_loss_revenue
from payments p 
join order_items oi on oi.order_id = p.order_id 
join sellers s on s.seller_id = oi.seller_id 
join orders o on o.order_id = oi.order_id 
where o.order_status  = 'canceled' and s.seller_id = 'c4f7fee5-b0db-50e8-7766-f5a4d1b1b758'
order by s.seller_id desc 


select  
	s.seller_id ,
	s.seller_city ,
	--p.payment_installments,
	--p.payment_value,
	sum(p.payment_value * p.payment_installments) as total_loss_revenue
from payments p 
join orders o on o.order_id = p.order_id 
join order_items oi on oi.order_id = o.order_id
join sellers s on s.seller_id = oi.seller_id 
where o.order_status  = 'canceled'
group by 1,2 
order by total_loss_revenue desc 

-- 5 --
select  
	s.seller_id ,
	s.seller_city ,
	--p.payment_installments,
	--p.payment_value,
	sum(p.payment_value) as total_revenue
from payments p 
join orders o on o.order_id = p.order_id 
join order_items oi on oi.order_id = o.order_id
join sellers s on s.seller_id = oi.seller_id 
where o.order_status  = 'delivered'
group by 1,2 
order by total_revenue desc 
limit 10

-- 6 --
select 
	s.seller_id,
	s.seller_city,
	sum(r.review_score)/count(*) as avg_review,
	count(*) as total
from reviews r 
join order_items oi on r.order_id = replace(cast(oi.order_id as text),'-','')
join sellers s on s.seller_id = oi.seller_id 
group by 1,2
order by total desc
limit 10

-- 7 --
select 
	s.seller_id,
	s.seller_city,
	count(case when r.review_score in(1,2) then 1 end) as negative_reviews,
	count(case when r.review_score in(3) then 1 end) as neutral_reviews,
	count(case when r.review_score in(4,5) then 1 end) as positive_reviews
from reviews r 
join order_items oi on r.order_id = replace(cast(oi.order_id as text),'-','')
join sellers s on s.seller_id = oi.seller_id 
group by 1,2
order by negative_reviews desc

-- 8 --
select
	p.product_category_name,
	count(case when r.review_score in(1,2) then 1 end) as negative_reviews,
	count(case when r.review_score in(3) then 1 end) as neutral_reviews,
	count(case when r.review_score in(4,5) then 1 end) as positive_reviews,
	count(case when r.review_score in(1,2) then 1 end)*1.0 / count(case when r.review_score in(4,5) then 1 end) * 1.0 as neg_to_pos_ratio
from reviews r 
join order_items oi on r.order_id = replace(cast(oi.order_id as text),'-','')
join products p on p.product_id = oi.product_id  
group by 1
order by neg_to_pos_ratio desc 

-- 9 --
select 
	s.seller_city,
	c.customer_city,
	extract(doy from (o.order_delivered_customer_date - o.order_purchase_timestamp)) over(partition by) as days
from orders o 
join customers c on c.customer_id = o.customer_id 
join order_items oi on oi.order_id = o.order_id 
join sellers s on s.seller_id = oi.seller_id 
group by 1,2


WITH delivery_days AS (
    SELECT 
        s.seller_city,
        c.customer_city,
        EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400 AS days
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN sellers s ON s.seller_id = oi.seller_id
    WHERE o.order_status = 'delivered'
    	AND o.order_delivered_customer_date IS NOT NULL
    	AND o.order_purchase_timestamp IS NOT NULL
)
SELECT 
    seller_city,
    customer_city,
    floor(AVG(days)) AS avg_delivery_days
FROM delivery_days
GROUP BY 1, 2
ORDER BY avg_delivery_days desc
limit 15


SELECT 
        s.seller_city,
        c.customer_city,
        avg(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400 ) over(partition by s.seller_city,c.customer_city)
        AS days
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN sellers s ON s.seller_id = oi.seller_id
    WHERE o.order_status = 'delivered'
	order by days desc 

	
-- 10 --

with stages as(
	select 'purchased' as stage, count(*) as total,lag(count(*)) over()
	from orders o
union all
	select 'approved' as stage, count(*) as total,lag(count(*)) over()
	from orders o
	where o.order_approved_at is not null
union all
	select 'delivered_carrier' as stage, count(*) as total,lag(count(*)) over()
	from orders o
	where o.order_delivered_carrier_date is not null
union all
	select 'delivered_customer' as stage, count(*) as total,lag(count(*)) over()
	from orders o
	where o.order_delivered_customer_date is not null
)
select
	stage,
	total,
	lag(total) over(order by total desc) as previous_total,
	round(total * 1.0 / (lag(total) over(order by total desc) * 1.0) ,3) as convertion_rate
from stages


-- 11 --
SELECT 
	p.product_category_name ,
	sum(o.freight_value) / count(*) as ratarata
FROM order_items o
join products p on p.product_id = o.product_id 
group by 1
order by ratarata desc limit 10

-- 12 --
with ranked as(
	select 
		(case when p.product_category_name = '' then 'Other' else p.product_category_name end) as category_name,
		p.product_id ,
		(case when p.product_weight_g is null then 0 else p.product_weight_g end) as weight,
		dense_rank() over(partition by p.product_category_name order by  
		(case when p.product_weight_g is null then 0 else p.product_weight_g end) desc) as rank
	from products p
)
select category_name,product_id,weight from ranked
where rank = 1
order by category_name

-- 13 --
select 
	oi.product_id , 
	concat(s.seller_city,' - ',c.customer_city),
	oi.freight_value 
from order_items oi 
join sellers s on s.seller_id  = oi.seller_id 
join orders o on o.order_id = oi.order_id 
join customers c on c.customer_id = o.customer_id 
order by oi.freight_value desc
limit 10

-- 14 --
select 
	concat(s.seller_city,' - ',c.customer_city) as rute,
	count(distinct o.order_id) as total_order
from order_items oi 
join sellers s on s.seller_id  = oi.seller_id 
join orders o on o.order_id = oi.order_id 
join customers c on c.customer_id = o.customer_id 
group by rute
order by total_order desc 
limit 11

-- 15 --
with temp as(
	select 
		(case when p.product_category_name = '' then 'Other' else p.product_category_name end) as category_name,
		p.product_id ,
		oi.freight_value,
		oi.price
	from products p
	join order_items oi on oi.product_id = p.product_id 
)
select distinct 
	category_name,
	product_id,
	freight_value,
	price,
	round((freight_value / price),2) as ratio
from temp
order by ratio desc 
limit 10




