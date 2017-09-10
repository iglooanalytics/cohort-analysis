/*

Cohort Analysis in Tableau
Evaluate the performance of your retention marketing using cohort analysis with Tableau and SQL.
http://www.iglooanalytics.com/blog/cohort-analysis-in-tableau.html

*/

-- ----------------------------
--  Table structure for cohort
-- ----------------------------
CREATE VIEW "public".cohort_dfn_by_month_first_purchase AS
  SELECT
  user_id,
  DATE_TRUNC('month', MIN(date)) as cohort
  FROM events
  GROUP BY 1;

-- ----------------------------
--  Table structure for metric
-- ----------------------------
CREATE VIEW "public".retention_by_user_by_month AS
  SELECT
  user_id,
  DATE_TRUNC('month', date) AS months_active,
  SUM(revenue) AS revenue
  FROM events
  GROUP BY 1,2;

-- ----------------------------------
--  Table structure for cohort+metric
-- ----------------------------------
CREATE VIEW "public".cohort_retention_by_month_first_purchase AS
  SELECT
  cohort,
  m.months_active AS month_actual,
  SUM(m.revenue) AS revenue,
  RANK() OVER (PARTITION BY cohort ORDER BY months_active ASC)-1 AS month_rank,
  RANK() OVER (PARTITION BY cohort ORDER BY months_active DESC)-1 AS month_rank_trend,
  COUNT(DISTINCT(c.user_id)) AS subscribers
  FROM cohort_dfn_by_month_first_purchase c
  JOIN retention_by_user_by_month m
  ON c.user_id = m.user_id
  GROUP BY 1,2
  ORDER BY 1,2;