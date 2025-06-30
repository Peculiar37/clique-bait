-- 3. Product Funnel Analysis -- 
select *
from dannys_bait;

create table for_analysis as
WITH product_info AS (
    SELECT 
        product_id, 
        page_name AS product_name,
        product_category,
        SUM(CASE WHEN event_name = 'page view' THEN 1 ELSE 0 END) AS views,
        SUM(CASE WHEN event_name = 'add to cart' THEN 1 ELSE 0 END) AS cart_adds
    FROM dannys_bait
    WHERE product_id IS NOT NULL
    GROUP BY product_id, product_category, page_name
),
product_abandoned AS (
    SELECT 
        product_id, 
        COUNT(*) AS abandoned
    FROM dannys_bait
    WHERE event_name = 'add to cart'
    AND visit_id NOT IN (
        SELECT visit_id 
        FROM dannys_bait
        WHERE event_name = 'purchase'
    )
    GROUP BY product_id
),
product_purchased AS (
    SELECT 
        product_id, 
        COUNT(*) AS purchases
    FROM dannys_bait
    WHERE event_name = 'add to cart'
    AND visit_id IN (
        SELECT visit_id 
        FROM dannys_bait
        WHERE event_name = 'purchase'
    )
    GROUP BY product_id
)
SELECT 
    pi.*,
    pa.abandoned,
    pp.purchases
FROM product_info pi
LEFT JOIN product_abandoned pa ON pi.product_id = pa.product_id
LEFT JOIN product_purchased pp ON pi.product_id = pp.product_id
;

select *
from for_analysis;


-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
with category_info as (
select product_category,
sum(case when event_name = 'page view' then 1 else 0 end) as views,
sum(case when event_name = 'add to cart' then 1 else 0 end) as cart_adds
from dannys_bait
where product_id is not null
group by product_category
),
category_abandoned as (
select product_category,
count(*) as abandoned
from dannys_bait
where event_name = 'add to cart' 
and visit_id not in (
select visit_id
from dannys_bait
where event_name = 'purchase')
group by  product_category
),
category_purchased as (
select product_category,
count(*) as purchases 
from dannys_bait
where event_name = 'add to cart'
and visit_id not in (
select visit_id
from dannys_bait
where event_name = 'purchase')
group by product_category
)
select ci.*,
ca.abandoned,
cp.purchases
from category_info ci
left join category_abandoned ca on ci.product_category = ca. product_category
left join category_purchased cp on ci.product_category = cp. product_category
;

-- Which product had the most views, cart adds and purchases?
select *
from for_analysis
order by views desc
limit 1;

select *
from for_analysis
order by cart_adds desc
limit 1;

select *
from for_analysis
order by purchases desc
limit 1;

-- Which product was most likely to be abandoned?
select *
from for_analysis
order by abandoned desc
limit 1;

-- Which product had the highest view to purchase percentage?
select product_name ,
product_category ,
(purchases / views) * 100 as purchase_per_view_pct
from for_analysis 
order by purchase_per_view_pct desc
limit 1;

-- What is the average conversion rate from view to cart add?
select 
cast(avg(100 * views/cart_adds) as decimal (10,2)) as view_to_cart
from for_analysis 
;

-- What is the average conversion rate from cart add to purchase?
select 
cast(avg(100 * cart_adds / purchases) as decimal (10,2)) as cart_to_purchase
from for_analysis 
;




 
