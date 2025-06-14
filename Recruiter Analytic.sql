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

/* Create Table for Engagement Audit */

CREATE TABLE IF NOT EXISTS Engagement_audit (
    recruiter_id,
    delta_logins,
    delta_posts,
    quality_flag,
    support_flag,
    churn_risk,
    logins_last_14d,
    job_posts_last_14d,
    snapshot_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


/* Stored Procedure */

DELIMITER //

CREATE PROCEDURE run_recruiter_engagement_snapshot()
BEGIN
  DECLARE last_snapshot_date DATETIME;

  -- Get the latest snapshot date
  SELECT MAX(snapshot_date) INTO last_snapshot_date
  FROM Engagement_audit;

  INSERT INTO Engagement_audit (
    recruiter_id,
    delta_logins,
    delta_posts,
    quality_flag,
    support_flag,
    churn_risk,
    logins_last_14d,
    job_posts_last_14d,
    snapshot_date
  )
  SELECT
    e.recruiter_id,
    e.logins_last_14d - COALESCE(p.logins_last_14d, 0) AS delta_logins,
    e.job_posts_last_14d - COALESCE(p.job_posts_last_14d, 0) AS delta_posts,
    CASE WHEN e.avg_applicant_quality < 60 THEN TRUE ELSE FALSE END AS quality_flag,
    CASE WHEN e.support_tickets_last_30d > 5 THEN TRUE ELSE FALSE END AS support_flag,
    CASE WHEN e.logins_last_14d = 0 AND e.job_posts_last_14d = 0 THEN TRUE ELSE FALSE END AS churn_risk,
    e.logins_last_14d,
    e.job_posts_last_14d,
    NOW() AS snapshot_date
  FROM Engagement e
  LEFT JOIN (
    SELECT recruiter_id, logins_last_14d, job_posts_last_14d
    FROM Engagement_audit
    WHERE snapshot_date = last_snapshot_date
  ) p ON e.recruiter_id = p.recruiter_id;
  
END //

DELIMITER ;
