-- 2. Digital Analysis
-- joining tables
create table dannys_bait as 
select 
pg.page_id,
pg.page_name,
pg.product_category,
pg.product_id,
ci.campaign_id,
ci.products,
ci.campaign_name,
ci.start_date,
ei.event_type,
ei.event_name,
ee.visit_id,
ee.cookie_id,
ee.sequence_number,
ee.event_time,
us.user_id
from events ee

left join page_hierarchy pg on pg.page_id = ee.page_id
left join event_identifier ei on ei.event_type = ee.event_type
left join users us on ee.cookie_id = us.cookie_id
left join campaign_identifier ci on ci.start_date = us.start_date;

select *
from dannys_bait;

-- How many users are there?
select 
count(distinct user_id) as number_of_user
from dannys_bait;

-- How many cookies does each user have on average?
select avg(cookies) as avg_cookies
from 
(select user_id,
count(cookie_id) as cookies
from dannys_bait
group by user_id) as temp;

-- What is the unique number of visits by all users per month?
select
month(event_time) as per_month,
count(distinct visit_id) as number_of_visits
from dannys_bait
group by per_month
order by per_month;

-- What is the number of events for each event type?
select event_type, event_name,
count(*) as no_of_events 
from dannys_bait
group by event_type, event_name
order by event_type;

-- What is the percentage of visits which have a purchase event?
select
(count(distinct visit_id)/(select count(distinct visit_id) from events) *100) as purchase_percent 
from dannys_bait 
where event_name = 'purchase'
;

-- What is the percentage of visits which view the checkout page but do not have a purchase event?
with checkout_page as (
select count(visit_id) as cnt
from dannys_bait
where event_name = 'page_view'
and page_name = 'checkout'
)
select
round(100* count(distinct visit_id) / (select count(cnt) from checkout_page)) as percent_view_checkout 
from dannys_bait
where event_name = 'purchase'
;

-- What are the top 3 pages by number of views?
select page_name ,
count(*) as page_views
from dannys_bait
where page_name = 'page_view'
group by page_name
order by page_views desc
limit 3;


-- What is the number of views and cart adds for each product category?
select product_category,
sum(case when event_name = 'page view' then 1 else 0 end) as page_views,
sum(case when event_name = 'add to cart' then 1 else 0 end) as cart_adds
from dannys_bait
where product_category is not null
group by product_category;

-- What are the top 3 products by purchases?
select product_id,
product_category, page_name,
count(*) as product_purchase
from dannys_bait
where event_name = 'add to cart'
and visit_id in (
select visit_id
from dannys_bait
where event_name = 'purchase')
group by  product_id, product_category, page_name
order by product_purchase desc
limit 3;




