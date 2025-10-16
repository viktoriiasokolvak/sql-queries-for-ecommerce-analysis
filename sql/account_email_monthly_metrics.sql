/*
Purpose:
This SQL script creates two views and a final query to analyze email sending activity by accounts.
It calculates monthly metrics for each account, including:
- Number of emails sent by the account per month
- First and last email sent dates
- Percentage of an account's emails relative to the total emails sent in that month
*/

-- View 1: Aggregates email activity per account per month
CREATE VIEW `Students.v_sokolvak_aggregation_data_1` AS
  SELECT
    EXTRACT(MONTH FROM DATE_ADD(s.date, INTERVAL es.sent_date DAY)) AS sent_month,
    es.id_account,
    COUNT(es.id_message) AS account_msg_cnt,
    MIN(DATE_ADD(s.date, INTERVAL es.sent_date DAY)) AS first_sent_date,
    MAX(DATE_ADD(s.date, INTERVAL es.sent_date DAY)) AS last_sent_date
  FROM
    `data-analytics-mate.DA.email_sent` es
  JOIN
    `data-analytics-mate.DA.account_session` acs
  ON 
    es.id_account = acs.account_id
  JOIN
    `data-analytics-mate.DA.session` s
  ON
    acs.ga_session_id = s.ga_session_id
  GROUP BY 1, 2


-- View 2: Calculates total messages sent by all accounts per month
CREATE VIEW `Students.v_sokolvak_aggregation_data_2` AS
  SELECT
    EXTRACT(MONTH FROM DATE_ADD(s.date, INTERVAL es.sent_date DAY)) AS sent_month,
    COUNT(id_message) AS total_msg_in_month
  FROM
    `data-analytics-mate.DA.email_sent` es
  JOIN
    `data-analytics-mate.DA.account_session` acs
  ON 
    es.id_account = acs.account_id
  JOIN
    `data-analytics-mate.DA.session` s
  ON
    acs.ga_session_id = s.ga_session_id
  GROUP BY
    sent_month
  

-- Final query: Calculates each account's share of emails per month and includes first/last email dates
SELECT
  base_data.sent_month,
  base_data.id_account,
  base_data.account_msg_cnt / month_total.total_msg_in_month * 100 AS sent_msg_percent_from_this_month,
  base_data.first_sent_date,
  base_data.last_sent_date
FROM
  `Students.v_sokolvak_aggregation_data_1` AS base_data
JOIN
  `Students.v_sokolvak_aggregation_data_2` AS month_total
ON
  base_data.sent_month = month_total.sent_month
