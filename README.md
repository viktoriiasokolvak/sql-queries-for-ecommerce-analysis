# SQL Portfolio – Account, Email, and Sales Analytics

## 📘 Overview
This repository contains a collection of SQL queries designed for analyzing user behavior, email activity, and sales performance using data from an e-commerce platform.  
All queries were written and tested in **BigQuery** and focus on data aggregation, ranking, and analytical metrics using **CTEs**, **window functions**, and **joins** across multiple datasets.

---

## 📂 Repository Content

| File | Description |
|------|--------------|
| `account_email_metrics.sql` | Main analytical query combining account creation and email metrics by country, verification, and subscription status. Includes ranking of top 10 countries by accounts and sent emails. |
| `monthly_account_message_share.sql` | Calculates each account’s share of messages within a month using window functions. Identifies first and last sent dates per account per month. |
| `account_email_monthly_metrics.sql` | Builds two aggregation views to calculate monthly message counts and combines them to find each account’s message share. |
| `continent_revenue_account_session_analysis.sql` | Aggregates global revenue, device-based revenue, account verification, and session counts by continent. Shows share of total revenue per region. |

---

## 🧠 Key Concepts Demonstrated
- Use of **Common Table Expressions (CTEs)** for logical query structuring  
- **Window functions** for calculating running totals, ranks, and percentages  
- **Data aggregation** by multiple dimensions (country, continent, month, device)  
- Creation of **analytical views** for modular data analysis  
- Ranking and percentage calculations to identify top contributors  

---

## 🛠️ Tools
- **SQL dialect:** BigQuery SQL  
- **Data source:** educational dataset
- **Environment:** Google BigQuery  

---



## 📈 Author
**Viktoriia Sokolvak**  
Data Analyst | SQL, Python, Tableau
