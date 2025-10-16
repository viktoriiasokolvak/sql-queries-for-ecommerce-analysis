/* Purpose:
This query calculates the percentage of messages sent by each account within each month, 
along with the first and last message dates for that account in the given month.
It uses window functions to compute per-account and per-month aggregations without creating additional views.
*/

-- Step 1: Aggregate sent message data per account and month
SELECT
 sent_month,
 id_account,
 account_cnt / total_cnt * 100 AS sent_msg_percent_from_this_month,
 MIN(sent_date) OVER(PARTITION BY id_account, sent_month) AS first_sent_date,
 MAX(sent_date) OVER(PARTITION BY id_account, sent_month) AS last_sent_date
FROM(
-- Step 2: Calculate message counts per account and per month
SELECT
 DATE_TRUNC(sent_date, MONTH) AS sent_month,
 id_account,
 sent_date,
 COUNT(*) OVER(PARTITION BY id_account, DATE_TRUNC(sent_date, MONTH)) AS account_cnt,
 COUNT(*) OVER(PARTITION BY DATE_TRUNC(sent_date, MONTH)) AS total_cnt
FROM(
-- Step 3: Base dataset - connect email_sent with account and session data
SELECT
 acc.id AS id_account,
 DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS sent_date
FROM
 `data-analytics-mate.DA.email_sent` es
JOIN
 `data-analytics-mate.DA.account` acc
ON
 es.id_account = acc.id
JOIN
 `data-analytics-mate.DA.account_session` acs
ON
 acc.id = acs.account_id
JOIN
 `data-analytics-mate.DA.session` s
ON
 acs.ga_session_id = s.ga_session_id))
