--Transformations added to raw table for loading

insert
	into
	event_clean With RM_Space as (
	SELECT
		trim(event_time) as event_time,
		trim(event_type) event_type,
		trim(product_id) product_id,
		trim(category_id) category_id,
		trim(category_code) category_code,
		trim(brand) brand,
		trim(price) price,
		trim(user_id) user_id,
		trim(user_session) user_session
	FROM
		event_raw),
	MISSING_CODE_BRAND as(
	select
		DATE(SUBSTR(event_time, 1, 10)) event_date,
		SUBSTR(event_time,
		12,
		05) event_time,
		event_type,
		product_id,
		category_id,
		case
			when category_code = '' then 'OTHERS'
			ELSE UPPER(category_code)
		END AS category_code ,
		case
			when brand = '' then 'OTHERS'
			ELSE UPPER(brand)
		end as Brand,
		case
			when price = '' then max(price) OVER (partition by product_id,
			category_id)
			else price
		end as price,
		user_id,
		user_session
	from
		RM_Space),
	MISSING_USER_SESSION AS(
	SELECT
		A.*,
		LAG(EVENT_TIME) OVER (
	ORDER BY
		EVENT_DATE,
		EVENT_TIME) LG_TIME,
		LEAD(EVENT_TIME) OVER (
	ORDER BY
		EVENT_DATE,
		EVENT_TIME) LD_TIME,
		LAG(user_session) OVER (
	ORDER BY
		EVENT_DATE,
		EVENT_TIME) LG_SESSION,
		LEAD(user_session) OVER (
	ORDER BY
		EVENT_DATE,
		EVENT_TIME) LD_SESSION
	FROM
		MISSING_CODE_BRAND A),
	FINAL_RAW_FORM AS(
	SELECT
		event_date,
		event_time,
		event_type,
		product_id,
		category_id,
		category_code,
		brand,
		price,
		user_id,
		case
			when user_session = '' then
			CASE
				WHEN EVENT_TIME = LG_TIME THEN LG_SESSION
				WHEN EVENT_TIME = LD_TIME THEN LD_SESSION
				WHEN EVENT_TIME-LG_TIME<EVENT_TIME-LD_TIME THEN LG_SESSION
				WHEN EVENT_TIME-LG_TIME>EVENT_TIME-LD_TIME THEN LD_SESSION
			end
			ELSE user_session
		end as user_session
	from
		MISSING_USER_SESSION A) ,
	DUPS AS (
	SELECT
		A.*,
		ROW_NUMBER() over (partition by event_date,
		event_time,
		product_id,
		category_id,
		category_code,
		brand,
		price,
		user_id,
		user_session) as RN
	FROM
		FINAL_RAW_FORM A ),
	Remove_DUPS AS (
	SELECT
		TRIM(strftime('%Y%m', A.event_date)) AS MONTH_ID,
		event_date,
		event_time,
		event_type,
		product_id,
		category_id,
		category_code,
		brand,
		price,
		user_id,
		user_session
	from
		DUPS A
	where
		rn = 1),
	Final_Insert as (
	SELECT
		MONTH_ID,
		event_date,
		event_time,
		event_type,
		product_id,
		category_id,
		category_code,
		brand,
		cast(price as float),
		user_id,
		user_session
	from
		Remove_DUPS )
select
	*
from
	Final_Insert A
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		event_clean
	WHERE
			A.MONTH_ID=MONTH_ID
		and A.event_date=event_date
		and A.event_time=event_time
		and event_type = event_type
		and product_id = product_id
		and category_id = category_id
		and category_code = category_code
		and brand = brand
		and price = price
		and user_id = user_id
		and user_session = user_session ) ;