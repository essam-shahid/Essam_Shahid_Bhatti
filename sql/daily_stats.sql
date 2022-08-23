--Daily Stats Table Being loaded
insert into daily_stats
with daily_sts as (
select
	event_date,
	count(distinct user_id) as visitors,
	count(DISTINCT user_session) as sessions,
	count(distinct (case when event_type = 'view' then user_id else NULL END)) as viewers,
	count(distinct (case when event_type = 'view' then product_id else NULL END)) as views,
	count(distinct (case when event_type = 'cart' then user_id else NULL END)) as leaders,
	count(distinct (case when event_type = 'cart' then product_id else NULL END)) as leads,
	count(distinct (case when event_type = 'purchase' then user_id else NULL END)) as purchasers,
	count(distinct (case when event_type = 'purchase' then product_id else NULL END)) as purchases
from
	event_clean
GROUP BY
	1 )
select
	*
from
	daily_sts  A
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		daily_stats 
	WHERE
		A.event_date = DATE);