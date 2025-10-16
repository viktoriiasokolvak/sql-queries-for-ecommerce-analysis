/*
Purpose: 
This SQL script calculates key account and email metrics for an e-commerce platform.
It aggregates data by date, country, send interval, account verification, and subscription status.
Metrics include account creation counts, emails sent, opened, and clicked, as well as total and ranked metrics per country.
The final dataset contains top 10 countries by total account creation or total emails sent.
*/

-- Step 1: Calculate account metrics
WITH account_metrics AS (
  SELECT
    s.date,
    sp.country,
    acc.send_interval,
    acc.is_verified,
    acc.is_unsubscribed,
    COUNT(DISTINCT acc.id) AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM
    `data-analytics-mate.DA.account` acc
  JOIN
    `data-analytics-mate.DA.account_session` acs
  ON
    acc.id = acs.account_id
JOIN
    `data-analytics-mate.DA.session_params` sp
ON
    sp.ga_session_id = acs.ga_session_id
JOIN
    `data-analytics-mate.DA.session` s
ON
    s.ga_session_id = sp.ga_session_id
GROUP BY
    1, 2, 3, 4, 5
),


-- Step 2: Calculate email metrics
email_metrics AS (
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    sp.country,
    acc.send_interval,
    acc.is_verified,
    acc.is_unsubscribed,
    0 AS account_cnt,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM
    `data-analytics-mate.DA.email_sent` es
  LEFT JOIN
    `data-analytics-mate.DA.email_open` eo
  ON
    es.id_message = eo.id_message
  LEFT JOIN
    `data-analytics-mate.DA.email_visit` ev
  ON
    es.id_message = ev.id_message
  JOIN
    `data-analytics-mate.DA.account` acc
  ON
    acc.id = es.id_account
  JOIN
    `data-analytics-mate.DA.account_session` acs
  ON
    acs.account_id = es.id_account
  JOIN
    `data-analytics-mate.DA.session` s
  ON
    s.ga_session_id = acs.ga_session_id
  JOIN
    `data-analytics-mate.DA.session_params` sp
  ON
    sp.ga_session_id = acs.ga_session_id
  GROUP BY 
    1,2,3,4,5
),


-- Step 3: Combine account and email metrics
union_metrics AS (
  SELECT * FROM account_metrics
  UNION ALL
  SELECT * FROM email_metrics
),


-- Step 4: Aggregate metrics by required dimensions
aggregated_metrics AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM
    union_metrics
  GROUP BY
    1, 2, 3, 4, 5
),


-- Step 5: Calculate total metrics per country
totals_per_country AS (
  SELECT
    country,
    SUM(account_cnt) AS total_country_account_cnt,
    SUM(sent_msg) AS total_country_sent_cnt
  FROM
    aggregated_metrics
  GROUP BY
    country
),


-- Step 6: Rank countries by total accounts and sent emails
country_ranked AS (
  SELECT
    *,
    RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt,
  FROM
    totals_per_country
)


-- Step 7: Final dataset
SELECT
  am.date,
  am.country,
  am.send_interval,
  am.is_verified,
  am.is_unsubscribed,
  am.account_cnt,
  am.sent_msg,
  am.open_msg,
  am.visit_msg,
  cr.total_country_account_cnt,
  cr.total_country_sent_cnt,
  cr.rank_total_country_account_cnt,
  cr.rank_total_country_sent_cnt
FROM
  aggregated_metrics am
JOIN
  country_ranked cr
ON
  am.country = cr.country
WHERE
  cr.rank_total_country_account_cnt <= 10
  OR cr.rank_total_country_sent_cnt <= 10
