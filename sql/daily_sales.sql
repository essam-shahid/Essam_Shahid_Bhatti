--Daily Sales Table Being Created

Insert
	into
	daily_sales WITH INSERT_ST AS (
	select
		event_date as DATE,
		count(product_id) AS TOTAL_SALES
	from
		event_clean
	where
		event_type = 'purchase'
	GROUP BY
		DATE )
SELECT
	*
FROM
	INSERT_ST A
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		daily_sales
	WHERE
		A.DATE = DATE)