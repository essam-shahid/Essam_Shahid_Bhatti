.DEFAULT_GOAL := run


#--------------------Pre load checks--------------------#
#-------------------------------------------------------#

#First we will create an empty staging table which will have all types as text so everything could be loaded#
create-tables:
	@echo "Creating Empty Staging table for loading"
	@sqlite3 db/assignment.db  ".read sql/create-tables.sql"
	@echo "Tables for loading has been created!"
	



#Define Variables for file Check
#We have a load directory and done directory which we use during and post loading of the file

WORKDIR=/assignment
landing_file_dir=$(WORKDIR)/data
file_dir=$(landing_file_dir)/file
file_dir_load=$(WORKDIR)/data/load
file_dir_done=$(landing_file_dir)/done
file_to_be_loaded=$(file_dir_load)/Latest_File.csv


#--------------------Pre load checks--------------------#
#-------------------------------------------------------#

# File will be loaded into raw table
# First row will be removed as .import loads all the rows
file_prep:
	@echo "File being Loaded into raw table"
	@sed '1d' $(file_dir)/*.csv > $(file_to_be_loaded)
	@chmod 777 $(file_to_be_loaded) 
	@mv $(file_dir)/*.csv $(file_dir_done)
	@gzip $(file_dir_done)/*.csv
	@echo "Load file ready!"
	
	
	
#--------------------Task 1-----------------------------#
#-------------------------------------------------------#
#We will be ingesting data into the table created above with each column#
	
ingesting-data-into-staging-table:
	
	@echo "Setting the mode to CSV to interpret the input file as a CSV file"
	@sqlite3 db/assignment.db ".mode csv"
	@echo "Ingesting data into staging table"
	@sqlite3 db/assignment.db -separator ',' ".import $(file_to_be_loaded) event_raw"
	@echo "Raw data has been inserted into staging table!"
	

#--------------------Task 2-----------------------------#
#-------------------------------------------------------#
	
	
#We will be transforming and cleaning the raw data so it can be inserted into final table#
transform_raw_table:
	@echo "Transformation being applied on Staging table for final loading"
	sqlite3 db/assignment.db ".read sql/transform-stg-table.sql"
	@echo "Clean Data has been loaded in event_clean table"
	

#--------------------Task 3-----------------------------#
#-------------------------------------------------------#
daily_sales_analysis:
	@echo "Insert Into Daily Sales Table"
	@sqlite3 db/assignment.db ".read sql/daily_sales.sql"
	@echo "Daily Sales Table Loaded!"




#--------------------Task 4-----------------------------#
#-------------------------------------------------------#
daily_stats_analysis:
	@echo "Insert Into  Daily Sales Table"
	@sqlite3 db/assignment.db ".read sql/daily_stats.sql"
	@echo "Daily Sales Table Loaded!"




#--------------------Task 5-----------------------------#
#-------------------------------------------------------#
daily_funnel_analysis:
	@echo "Insert Into Daily funnel Table"
	@sqlite3 db/assignment.db ".read sql/daily_funnel.sql"
	@echo "Daily Sales Table Loaded!"


#--------------------Task 6-----------------------------#
#-------------------------------------------------------#
daily_ticket_analysis:
	@echo "Insert Into Daily ticket Table"
	@sqlite3 db/assignment.db ".read sql/daily_ticket.sql"
	@echo "Daily Sales Table Loaded!"


#--------------------Post load Steps--------------------#
#-------------------------------------------------------#
post-steps-file:
	@echo "Pipeline Finish!"
	@rm -f $(file_to_be_loaded)

# TODO: Add all the necessary steps to complete the assignment
run: create-tables
	if ls $(landing_file_dir)/*.csv; \
		then echo "File Found on the Landing Directory!"; \
		echo "Moving File To Loading"; \
		for file1 in ls $(landing_file_dir)/*.csv;\
			do echo "$$file1";\
			 mv -v $$file1  $(file_dir); \
			 $(MAKE) file_prep; \
			 $(MAKE) ingesting-data-into-staging-table; \
			 $(MAKE) transform_raw_table; \
			 $(MAKE) daily_sales_analysis; \
			 $(MAKE) daily_stats_analysis; \
			 $(MAKE) daily_funnel_analysis; \
			 $(MAKE) daily_ticket_analysis; \
			 $(MAKE) post-steps-file; \
			done;\
	else echo " No file Found on Landing Directory!";\
	fi
	
	




