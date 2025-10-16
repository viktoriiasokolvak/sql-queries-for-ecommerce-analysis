/* Purpose:
This query aggregates key business metrics by continent:
revenue, device distribution, account verification, and session counts.
*/

-- Step 1: Calculate total and device-based revenue (in USD)
WITH revenue_usd AS (
  SELECT
    sp.continent,
    SUM(p.price) AS revenue,
    SUM(CASE WHEN sp.device = 'mobile' THEN p.price END) AS revenue_from_mobile,
    SUM(CASE WHEN sp.device = 'desktop' THEN p.price END) AS revenue_from_desktop
  FROM
    `data-analytics-mate.DA.order` o
  JOIN
    `data-analytics-mate.DA.product` p
  ON
    o.item_id = p.item_id
  JOIN
    `data-analytics-mate.DA.session_params` sp
  ON
    o.ga_session_id = sp.ga_session_id
  GROUP BY
    sp.continent),

  
-- Step 2: Count total and verified accounts per continent
account_params AS (
  SELECT
    sp.continent,
    COUNT(acc.id) AS account_cnt,
    COUNT(CASE WHEN is_verified = 1 THEN acc.id END ) AS verified_account
  FROM
    `data-analytics-mate.DA.session_params` sp
  LEFT JOIN
    `data-analytics-mate.DA.account_session` acs
  ON
    sp.ga_session_id = acs.ga_session_id
  JOIN
    `data-analytics-mate.DA.account` acc
  ON
    acc.id = acs.account_id
  GROUP BY
    sp.continent
),


-- Step 3: Count unique sessions by continent
session_cnts AS (
  SELECT
    continent,
    COUNT(DISTINCT ga_session_id) AS session_cnt
  FROM
    `data-analytics-mate.DA.session_params`
  GROUP BY
    continent
)

  
-- Step 4: Combine all metrics into a single summary table
SELECT
  account_params.continent,
  revenue_usd.revenue,
  revenue_usd.revenue_from_mobile,
  revenue_usd.revenue_from_desktop,
  revenue_usd.revenue / SUM(revenue_usd.revenue) OVER () * 100 AS revenue_percent_of_total,
  account_params.account_cnt,
  account_params.verified_account,
  session_cnts.session_cnt
FROM
  account_params
LEFT JOIN
  revenue_usd
ON
  account_params.continent = revenue_usd.continent
LEFT JOIN
  session_cnts
ON
  session_cnts.continent = account_params.continent
