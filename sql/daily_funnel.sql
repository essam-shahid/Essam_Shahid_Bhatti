--Daily Funnel Table Being loaded
insert
	into
	daily_funnel
select
	Date,
	visitors VISITORS,
	viewers VIEWERS,
	leaderS LEADERS,
	purchasers PURCHASERS,
	round(cast(viewers as real)/ cast(visitors as real),
	2) as VISITOR_TO_VIEWER,
	round(cast(leaders as real)/ cast(viewers as real),
	2) as VIEWER_TO_LEADER,
	round(cast(purchasers as real)/ cast(leaders as real),
	2) as LEADER_TO_PURCHASER
from
	daily_stats A
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		daily_funnel
	WHERE
		A.DATE = DATE)