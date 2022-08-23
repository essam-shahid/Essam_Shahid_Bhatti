--Daily ticket Table Being loaded
insert
	into
	daily_ticket with Items_purchased as (
	select
		distinct event_date,
		user_id,
		round(sum(price) over (partition by user_session
	order by
		event_date ),
		2) as ticket_Amounts,
		count(product_id) over (partition by user_session
	order by
		event_date ) as number_of_items_per_ticket
	from
		event_clean
	where
		event_type = 'purchase' ) ,
	TICKET_SIZE as(
	select
		event_date,
		user_id,
		ROUND(CAST(ticket_Amounts AS REAL)/ CAST(number_of_items_per_ticket AS REAL),
		2) as TICKET
	from
		Items_purchased
	GROUP BY
		1,
		2) ,
	Total_sales_TICKET as (
	select
		b.event_date,
		a.total_sales,
		TICKET
	from
		daily_sales A
	inner join TICKET_SIZE B ON
		A.date = b.event_Date) ,
	Final_TICKET_PERCENTLE AS (
	SELECT
		A.*,
		ntile(100) OVER (
	ORDER BY
		TICKET ASC) as percentle
	FROM
		Total_sales_TICKET A ),
	Final_Insert as (
	select
		event_date,
		total_sales,
		min(ticket),
		max(case when percentle = 25 then ticket else NULL END) "25TH_PERC_TICKET",
		max(case when percentle = 50 then ticket else NULL END) "50TH_PERC_TICKET",
		max(case when percentle = 75 then ticket else NULL END) "75TH_PERC_TICKET",
		max(ticket)
	from
		Final_TICKET_PERCENTLE
	group by
		1,
		2)
select
	*
from
	Final_Insert
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		daily_ticket A
	WHERE
		A.DATE = event_date);
