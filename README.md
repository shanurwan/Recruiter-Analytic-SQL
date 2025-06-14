# Recruiter Engagement Analytics Pipeline (MySQL)

## Overview

This project aims to track, monitor, and automate analytics on recruiter engagement activities using MySQL. By building a self-updating audit system, we can highlight signs of disengagement (inactivity, poor applicant quality, excessive support tickets, and churn risks). The system stores historical snapshots in an audit table, enabling easy trend analysis and integration with visualization tools.

## Dataset Description

Table: `Engagement`

| Column Name                 | Data Type | Description                                |
| --------------------------- | --------- | ------------------------------------------ |
| recruiter\_id               | VARCHAR   | Unique ID for each recruiter               |
| company                     | VARCHAR   | Recruiter's company name                   |
| logins\_last\_14d           | INT       | Number of logins in the past 14 days       |
| job\_posts\_last\_14d       | INT       | Job postings made in the past 14 days      |
| avg\_applicant\_quality     | FLOAT     | Quality score (0-100) of applicants        |
| support\_tickets\_last\_30d | INT       | Support tickets raised in the past 30 days |
| ai\_tool\_usage\_count      | INT       | Usage count of AI-based tools              |
| last\_active\_date          | DATE      | Date of last platform activity             |

## MySQL Project Objectives

- Identify disengaged recruiters based on custom threshold logic

- Monitor activity changes over time via delta tracking

- Automatically flag high-risk recruiter behaviors for follow-up

- Enable consistent data flow for reports and dashboards

## Methodology
The automation framework includes:

a. Snapshot Table Creation
A table `Engagement_audit` was created to store each day’s snapshot of recruiter activity.

b. Stored Procedure: `run_recruiter_engagement_snapshot()`
This procedure compares current recruiter metrics to the latest available snapshot to compute:

- `delta_logins`

- `delta_posts`

- `quality_flag (avg_applicant_quality < 60)`

- `support_flag (support_tickets_last_30d > 5)`

- `churn_risk (logins = 0 and posts = 0)`

The output is stored in `Engagement_audit` with a timestamp.

## Audit Table Schema
Table name `Engagement_audit`

| Column Name           | Data Type | Description                             |
| --------------------- | --------- | --------------------------------------- |
| recruiter\_id         | VARCHAR   | Recruiter unique ID                     |
| delta\_logins         | INT       | Change in logins since last snapshot    |
| delta\_posts          | INT       | Change in job posts since last snapshot |
| quality\_flag         | BOOLEAN   | Flag if avg applicant quality < 60      |
| support\_flag         | BOOLEAN   | Flag if support tickets > 5 in 30 days  |
| churn\_risk           | BOOLEAN   | True if both logins and posts are 0     |
| logins\_last\_14d     | INT       | Current login count (14-day window)     |
| job\_posts\_last\_14d | INT       | Current job post count (14-day window)  |
| snapshot\_date        | DATETIME  | Timestamp of this audit snapshot        |

## Sample Output

| recruiter\_id | delta\_logins | delta\_posts | quality\_flag | support\_flag | churn\_risk | snapshot\_date | logins_last_14d | job_posts_last_14d |
| ------------- | ------------- | ------------ | ------------- | ------------- | ----------- | ---------------| ----------------| -------------------|
| R1234         | -2            | 0            | TRUE          | FALSE         | FALSE       | 2025-06-16     | 2               | 0                  |
| R5678         | 0             | 0            | FALSE         | TRUE          | TRUE        | 2025-06-16     | 1               | 0                  |


## Key Features
Automation-Ready: No manual tracking—run daily via Event Scheduler

Historical Tracking: Delta logic detects behavior changes

Risk Flags: Easy to identify support issues, quality drops, and churn

Extensible: Easily expand logic to include new dimensions (e.g., message response time, conversion rates)

## Potential Extensions

* Real-Time Notifications (Slack, Email) on critical churn/support spikes

* Dashboard integration (e.g., Power BI for time-series visualizations)

* ML-Based Anomaly Detection for deeper recruiter behavior insights

* Filterable Reports by industry, recruiter role, team, or geography

## Tools Used

* **MySQL 8.0**: Database engine
* **Faker**: Python library used to generate the dataset (100,000 rows)
* **Power BI / Tableau** *(optional)*: Visualization layer for non-technical stakeholders

## How to use 
1. Manual Execution
   
After updating the `Engagement table` with new data, run:

```sql
CALL run_recruiter_engagement_snapshot();
```
2. Scheduled Execution
   
Enable daily automation using MySQL Events:

```sql
CREATE EVENT IF NOT EXISTS daily_engagement_check
ON SCHEDULE EVERY 1 DAY
DO CALL run_recruiter_engagement_snapshot();
```
 [Ensure event_scheduler = ON in MySQL server settings]
## Final Notes

This SQL project shows how structured queries and automation can uncover recruiter disengagement patterns, improving operational oversight and recruitment efficiency. It offers scalable monitoring and provides a foundation for deeper analytics or visual dashboards for talent teams.


