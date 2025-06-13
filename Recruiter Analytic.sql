/* Import csv file */
Create database Recruiter;

use recruiter;

create table Engagement (
recruiter_id varchar(100),	
company	varchar(100),
logins_last_14d	int,
job_posts_last_14d	int,
avg_applicant_quality float,
support_tickets_last_30d int,	
ai_tool_usage_count	int,
last_active_date date
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/recruiter_engagement_data.csv'
INTO TABLE engagement
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
