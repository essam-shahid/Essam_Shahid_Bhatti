--Create staging table with all types text so all data will be loaded


create table event_raw ( event_time text,
event_type text,
product_id text,
category_id text,
category_code text,
brand text,
price text,
user_id text,
user_session text );



--Create table with clean output


CREATE TABLE  IF NOT EXISTS event_clean(
  MONTH_ID text,
  event_date date,
  event_time time,
  event_type text,
  product_id integer,
  category_id integer,
  category_code text,
  brand text,
  price float,
  user_id int,
  user_session text
);



--Create table with Daily Sales
CREATE TABLE  IF NOT EXISTS  daily_sales(DATE DATE,TOTAL_SALES INTEGER);



--Create table with Daily stats
CREATE TABLE  IF NOT EXISTS  daily_stats(
  DATE DATE,
  visitors	 INTEGER	,
  sessions	 INTEGER		,
  viewers	 INTEGER		,
  views		 INTEGER		,
  leaders	 INTEGER		,
  leads		 INTEGER		,
  purchasers INTEGER		,
  purchases  INTEGER
);

--Create table with Daily funnel
CREATE TABLE  IF NOT EXISTS daily_funnel(
  DATE DATE,
  VISITORS	INTEGER,
  VIEWERS INTEGER,
  LEADERS INTEGER,
  PURCHASERS INTEGER,
  VISITOR_TO_VIEWER	FLOAT	,
  VIEWER_TO_LEADER	FLOAT	,
  LEADER_TO_PURCHASER FLOAT
);


--Create table  Daily ticket
CREATE TABLE  IF NOT EXISTS  daily_ticket(
  DATE DATE,
  total_sales INTEGER,
  MIN_TICKET FLOAT,
  "25TH_PERC_TICKET" FLOAT,
  "50TH_PERC_TICKET" FLOAT,
  "75TH_PERC_TICKET" FLOAT,
  MAX_TICKET FLOAT
);

