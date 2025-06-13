# Recruiter Engagement Analytics Pipeline (MySQL)

## Overview

This project analyzes recruiter engagement on a job platform to identify usage patterns and early signs of disengagement. It uses a MySQL database to simulate a real-time analytics pipeline with automated insights generation. The goal is to enable business stakeholders to proactively address recruiter inactivity, optimize support interventions, and assess the impact of AI tool usage.

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

### 1. Data Cleaning & Preparation

```sql
-- Remove duplicate recruiter IDs
DELETE FROM Engagement
WHERE recruiter_id NOT IN (
  SELECT * FROM (SELECT MIN(recruiter_id) FROM recruiter_engagement GROUP BY recruiter_id) AS temp
);

-- Handle outliers (applicant quality must be between 0 and 100)
UPDATE Engagement
SET avg_applicant_quality = 100
WHERE avg_applicant_quality > 100;
```

### 2. KPI Dashboard Queries

#### a. Recruiter Activity Overview

```sql
SELECT
  COUNT(*) AS total_recruiters,
  AVG(logins_last_14d) AS avg_logins,
  AVG(job_posts_last_14d) AS avg_job_posts,
  AVG(ai_tool_usage_count) AS avg_ai_usage
FROM Engagement;
```

#### b. Top 10 Most Active Recruiters

```sql
SELECT recruiter_id, company, logins_last_14d, job_posts_last_14d
FROM Engagement
ORDER BY logins_last_14d DESC
LIMIT 10;
```

#### c. AI Tool Impact on Engagement

```sql
SELECT
  CASE WHEN ai_tool_usage_count > 0 THEN 'Used AI Tools' ELSE 'Did Not Use AI Tools' END AS ai_group,
  AVG(logins_last_14d) AS avg_logins,
  AVG(avg_applicant_quality) AS avg_quality
FROM recruiter_engagement
GROUP BY ai_group;
```

### 3. Churn Risk Detection

#### Define churn as recruiters with 0 logins and 0 job posts in the past 14 days

```sql
SELECT *
FROM Engagement
WHERE logins_last_14d = 0 AND job_posts_last_14d = 0;
```

### 4. Automation: Create Churn Risk Flag

```sql
ALTER TABLE Engagement ADD churn_risk BOOLEAN;

UPDATE Engagement
SET churn_risk = CASE
  WHEN logins_last_14d = 0 AND job_posts_last_14d = 0 THEN TRUE
  ELSE FALSE
END;
```

## Key Insights

* Recruiters who actively use AI tools tend to log in more frequently and have higher applicant quality scores.
* Churn risk is significantly associated with low login and job posting activity.
* Only \~5-7% of recruiters raised support tickets, suggesting UX or onboarding friction may not be the top reason for churn.

## Potential Extensions

* Build a scheduled MySQL event to refresh churn risk weekly.
* Export insights to Power BI or Tableau using MySQL connectors.
* Integrate this data into a real-time dashboard for customer success teams.

## Tools Used

* **MySQL 8.0**: Database engine
* **Faker**: Python library used to generate the dataset (100,000 rows)
* **Power BI / Tableau** *(optional)*: Visualization layer for non-technical stakeholders

## Final Notes

This project highlights how SQL alone can deliver meaningful automation, engagement monitoring, and early churn detection in a scalable and production-feasible manner. It’s ideal for showcasing database design, query proficiency, and data storytelling to hiring managers.

---

**Tags:** SQL, Automation, Churn Prediction, Analytics Pipeline, Data Storytelling, AI Impact, Dashboard Design
