-- 4. Campaigns Analysis
create table campaign_analysis as 
select user_id, visit_id, campaign_name,
min(event_time) as visit_start_time,
sum(case when event_name = 'page view' then 1 else 0 end) as page_views,
sum(case when event_name = 'add to cart' then 1 else 0 end) as cart_adds,
sum(case when event_name = 'purchase' then 1 else 0 end) as purchases,
sum(case when event_name = 'ad impression' then 1 else 0 end) as impression,
sum(case when event_name = 'ad click' then 1 else 0 end) as click,
group_concat( distinct case when event_name = 'add to cart' then page_name end order by sequence_number separator ' ,') as cart_products
from dannys_bait
group by  user_id, visit_id, campaign_name;

select *
from campaign_analysis;

-- users who have received impressions during each campaign period
select 
count(distinct user_id) as received_impression 
from campaign_analysis
where impression > 0
and campaign_name is not null;
 
 -- Number of users who received impressions but didn't click on the ad during campaign periods
select 
count(distinct user_id) as received_impression_not_clicked 
from campaign_analysis
where impression > 0
and click = 0
and campaign_name is not null;

-- Number of users who didn't receive impressions during campaign periods
select 
count(distinct user_id) as not_received_impression
from campaign_analysis
where campaign_name  is not null
and user_id not in (
select user_id
from campaign_analysis 
where impression > 0)
;

-- overall impression rate = ( 9/ 9 + 3) * 100 = 
-- overall click rate = 

-- Calculate the average clicks, average views, average cart adds, and average purchases of each group
-- for users who received impressions
SET @received = 9;

SELECT 
  CAST(SUM(page_views) / @received AS DECIMAL(10,1)) AS avg_view,
  CAST(SUM(cart_adds) / @received AS DECIMAL(10,1)) AS avg_cart_adds,
  CAST(SUM(purchases) / @received AS DECIMAL(10,1)) AS avg_purchase
FROM campaign_analysis
WHERE impression > 0
AND campaign_name IS NOT NULL;

-- for users who received impressions but didnt click
 SET @received_not_clicked = 0;

SELECT
  CAST(SUM(page_views) / @received_not_clicked AS DECIMAL(10,1)) AS avg_view,
  CAST(SUM(cart_adds) / @received_not_clicked AS DECIMAL(10,1)) AS avg_cart_adds,
  CAST(SUM(purchases) / @received_not_clicked AS DECIMAL(10,1)) AS avg_purchase
FROM campaign_analysis  
WHERE impression > 0
AND click = 0
AND campaign_name IS NOT NULL;

-- for users who didnt receive impressions
SET @not_received = 3;

SELECT 
  CAST(SUM(page_views) / @not_received AS DECIMAL(10,1)) AS avg_view,
  CAST(SUM(cart_adds) / @not_received AS DECIMAL(10,1)) AS avg_cart_adds,
  CAST(SUM(purchases) / @not_received AS DECIMAL(10,1)) AS avg_purchase
FROM campaign_analysis
WHERE campaign_name IS NOT NULL
AND user_id NOT IN (
  SELECT user_id
  FROM campaign_analysis
  WHERE impression > 0
);
