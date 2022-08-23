## Essam Shahid Bhatti FinalHotel Assignment ##

The overal objective of the assignment is to ingest the raw files with the behavioural event data, clean them up and create a series of tables with aggregated data for analytical purposes. We will divide the challenge into several tasks. Remember to create a SQL script for each task, store it in the `sql` directory and add them to a target of the `Makefile` that will be executed when building the docker image.

It is not mandatory, but you can also include an additional `README` file to explain any of the tasks of your #### Solution: and the decisions you've made.



#### Detailed Information has been mentioned below each task. All the SQL are named after their tasks.####



### Define Variables for file Check:
	Variables where defined for landing files and loading files and done directory to move the file to done once we have loaded in our tables



### Pre-Ingestion

	We have created 2 targets in Makefile *create-tables* and *file_prep*. The create-tables target will create empty tables for the below ingestion and analysis.
	The file_prep will prepare the file. Since *.import* SQLITE command loads complete data, we will remove the header used *sed* command and create a generic loading file "Latest_File.csv".
	Once file to be loaded is prepared, we will move the actual file to a done directory so we can have a backup of the file if it is required. We also zip the actual file to make sure there aren't any space issues.
	The above step is when we have the following ingestion running on a machine.




### Task 1: Ingesting the data

The objective of this step is to ingest the source data from January (`2020-Jan.csv`) into a table named `event_raw`. For example, you can use the `.import` command from SQLite to do it.
 The structure of this table will depend on the process that you use to ingest the data, but it should have **at least one column for each of the columns in the source CSV file**.


#### Solution:

	Empty table was created for staging in pre-ingestion. Ideally, staging table should be empty after every batch processing to avoid any duplicates but we had incorporated NOT Exists clause in the query to avoid
	duplicates in our final table.
	
	Once the empty table was created, we set the mode to "csv" so input file can be handled as comma separated, and we used the sqllite3 CMD Line command "-separator ',' "Latest_File.csv"
	which allowed the file to be inserted in each column as per defined in the "create-empty-stg-table.sql". This way, each column in the source file has a column in staging table.
	
	
	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***




### Task 2: Cleaning up the data

Depending on the process you've followed to ingest the data, the `event_raw` table may have incorrect data types, the `NULL` values may have been ingested as empty strings, etc. In this step we want you to perform all the necessary clean up to make sure that the quality of the data is high and it is ready to be consumed. The task is open ended in the sense that you can apply any processing that you think will improve the quality of the dataset.

The output should be a table named `event_clean` with **exactly one column for each of the columns in the source CSV file** and the most appropriate data types. You will use the `event_clean` table in the following steps as the basis to extract meaningfull insights.



#### Solution:

	We also created a clean table, which we can call `event_clean`. This table will have all the cleansed data after the checks and fixtures are applied. The following fixtures were applied
	in the "transform-stg-table.sql":
	
	1) Special characters or Space in text/characters: 
			Once we get any columns with text data type, there is always risk of having special characters like space which is not visible at first, but can cause 
			issues while joining with dimensional tables.  Hence we added trim() function with each column to remove all the empty spaces.
			
	2) Empty Values in Category_Code and Brand:
			We received NULL values in the Category_Code and Brand columns which is loaded as empty space by .import. This could cause missing numbers in reporting based on 
			Category_Code and Brand so we introduced another value "OTHERS" in both columns so we can have complete reporting. Since we already used trim before we used *case when ...=''* which handled
			any NULLs received.
			
	3) Empty Value in USER_SESSION:
			We also received missing values in USER Session , which can cause duplicates on price or missing so we used lag and lead functions	against event
			date and time to check whether the same session was used or not. If the event_time was equal to previous session, we tagged the previous session, 
			if the event_time was equal to next we tagged the leading session.
			If it was not equal, we calculated the difference and tagged the session with whoever it was closer.
			
	4) Missing Price:
			Although the file was fine, there might be issue if price is missing. So we use max price with window function partitioned on product_id,category_id
			to find any missing price to calculate.
			
	5) Dups assign and remove:
			Once all the missing values were added/assigned, we used row_number() to assign rn to each row so we can finds duplicates and removed them
			by using the 1 row for each row. 
			
	6) Event_Date and Event_Time Columns:
			We also introduced 2 new columns by using *substr()* function on event_time so we could have day wise and hour wise data, in case any aggregation mart is required.

	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***

	


### Task 3: Daily sales

Here we want you to calculate the aggregated sales per day. The output should be a `daily_sales` table with the following shape:

| DATE       | TOTAL_SALES |
|------------|-------------|
| 2020-01-01 |        1000 |
|        ... |         ... |



#### Solution:

	`daily_sales` table was created at the start. We know,the event_type "purchase" is product purchased hence is marked as sale. We already extracted date in the above step, 
	we would just count all the product ids sold on each event_date. Since we removed all the duplicates above, there would not be any over reporting due to duplicates.
	
	
	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***


### Task 4: Daily stats of visitors, sessions, viewers, views, leaders, leads, purchasers and purchases

In this step we would like you to calculate the daily stats for the following metrics:
- `visitors`: Number of different users that have visited the store.
- `sessions`: Number of different user sessions for the users that have visited the store.
- `viewers`: Number of different users that have viewed at least one item.
- `views`: Total number of products viewed.
- `leaders`: Number of different users that have added at least one item to the cart.
- `leads`: Total number of products added to the cart.
- `purchasers`: Number of different users that have purchased at least one item.
- `purchases`: Total number of products purchased.

The output should be a `daily_stats` table with the following shape:

| DATE       | VISITORS | SESSIONS | VIEWERS | VIEWS | LEADERS | LEADS | PRUCHASERS | PURCHASES |
|------------|----------|----------|---------|-------|---------|-------|------------|-----------|
| 2020-01-01 |     1000 |     1250 | 950     | 1125  |     750 |   825 |        250 |       500 |
|        ... |      ... |      ... |         |       |     ... |   ... |        ... |       ... |




#### Solution:

	`daily_stats` table was created at the start. We know,the event_types and how we can calculate the required stats. We already extracted date in the above steps, 
	we would just count on each event_date. Since we removed all the duplicates above, there would not be any over reporting.
	
	- `visitors`: Number of different users that have visited the store: 
				  Since we need to find all the "different" users that visited the store, we would count the "distinct" users ids which visited the store.
				  
	- `sessions`: Number of different user sessions for the users that have visited the store.
				  Count the Distinct sessions of a particular user every day would give Sessions
				
	- `viewers`: Number of different users that have viewed at least one item.
				  Count the distinct user_id who have viewed any product. We use case statement to assign NULLs to any other event type, then count the 
				  user_ids to find the different users who have viewed atleast one item. 
				  
					
	- `views`: Total number of products viewed.
				 Assign NULLS to all other event_types and count the distinct product_ids which were viewed to give total views.

	
	- `leaders`: Number of different users that have added at least one item to the cart.
				 The event_type 'cart' gives items added to cart and we find distinct users who added atleast one item in their cart.
	
	
	- `leads`: Total number of products added to the cart.
				Assign NULLS to all other event_types and count the distinct product_ids which were viewed to give total leads.
	
	- `purchasers`: Number of different users that have purchased at least one item.
				Assign NULLS to all other event_types and count the distinct user_ids who purchased one time to give different purchasers.
				
	- `purchases`: Total number of products purchased.
				Assign NULLS to all other event_types and count the distinct product_ids which have been purchased one time to give Total purchasers.
	
	
	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***
	
	
	
### Task 5: Daily conversion funnel

Building up on top of the previous insight, now we want you to calculate the daily conversion funnel. For that we want to know the ratio of users that make it from one step to the next of the journey.

We consider the user journey to go through the following steps:

```
visitor -> viewer -> leader -> purchaser
```

The output should be a `daily_funnel` table with the following shape:

| DATE       | VISITORS | VIEWERS | LEADERS | PRUCHASERS | VISITOR_TO_VIEWER | VIEWER_TO_LEADER | LEADER_TO_PURCHASER |
|------------|----------|---------|---------|------------|-------------------|------------------|---------------------|
| 2020-01-01 |     1000 | 950     |     750 |        250 |              0.95 |             0.79 |                0.33 |
|        ... |      ... |         |     ... |        ... |               ... |              ... |                 ... |


#### Solution:

	`daily_funnel` table was created at the start. We did all the necessary calculations in the previous steps. We already extracted date in the above steps, 
	Since we removed all the duplicates above, there would not be any over reporting. Since the values we calculated in the previous task were all integers
	we had to cast them to real and used the round() function to convert to 2 decimal places.


	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***



### Task 6: Daily ticket size

We want to understand which is the distribution of the purchase or ticket size per user daily. For that, 
we consider that all the items purchased by a user during one session belong to the same purchase or ticket. 
We will calculate some basic statistics (min, max and 25th, 50th and 75th percentiles) about the ticket size to estimate it's distribution.

The output should be a `daily_ticket` table with the following shape:

| DATE       | TOTAL_SALES | MIN_TICKET | 25TH_PERC_TICKET | 50TH_PERC_TICKET | 75TH_PERC_TICKET | MAX_TICKET |
|------------|-------------|------------|------------------|------------------|------------------|------------|
| 2020-01-01 |        1000 |       1.25 |             2.50 |            10.35 |            25.50 |     150.25 |
|        ... |         ... |        ... |              ... |              ... |              ... |        ... |



#### Solution:

	`daily_ticket table was created at the start. We did all the necessary calculations in the previous steps. We already extracted date in the above steps, 
	Since we had to calculate ticket/purchase per user daily, we calculated all the total amounts and items per ticket/per session. Once we had that, we found the ticket size 
	per user and tagged daily sales against them. We then used the *NTILE(100)* function to create buckets of our ticket sizes. Then we used the 25th,50th and 75th bucket,
	and select the maximum of the bucket since the relative values are below that. 

	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***



### Task 7: Incremental load

So far you have only worked with one of the source CSV files. The objective now is to reproduce all the previous steps with the other file with data for February 2020 (`2020-Feb.csv`). 
Make sure to **load the data incrementally** into the existing tables without droping or truncating them. The objective is to simulate a batch process that would happen every once in a while when new data is available.

#### Solution:
	
	For incremental load, the best practice is to have a staging table, which will then load into intermediate table and finally into final table. Since truncate/delete was not encouraged,
	we used NOT Exists where if an old record or a same record were to be inserted, the query would exclude these rows. To have a proper batch process, we executed "run" command recursively based
	on the number of files in the landing directory. We had created the table once, before executing our loop. 
	Once it is confirmed file is available in the landing directory, we pick one file and execute all the targets created above. We move the file from landing directory to file directory. We create 
	a final load file and move the actual to done directory to keep a record of all the files loaded, in case we might need to load again. Having all the NOT Exists check ensure,
	there are no duplicates.We can run the same task again and we won't have duplicates.
	
	
	***We have included the NOT Exists clause so there are no duplicates in the final table if job is executed more than once with the same data.***



## References

- [eCommerce Events History in Cosmetics Shop](https://www.kaggle.com/mkechinov/ecommerce-events-history-in-cosmetics-shop)
- [REES46 Marketing Platform](https://rees46.com/)
- [Customer Data Platform](https://en.wikipedia.org/wiki/Customer_data_platform)
- [Conversion funnel](https://chartio.com/learn/product-analytics/what-is-a-funnel-analysis/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [GNU Make utility](https://www.gnu.org/software/make/)
