# E-Commerce KPI Analysis (SQL)

# Cleaning legacy orders data and delivering 10 trusted business KPIs.



### **1)** Business context

A retail team inherited a legacy e-commerce orders extract from an acquisition. The data is usable, but not trustworthy: mixed date formats, inconsistent categories, duplicates, and missing values. The goal is to build one clean “source of truth” table and compute 10 business KPIs for reporting.



#### 2\) What this repo contains

sql/data\_cleaning\_pipeline.sql → raw → typed/parsing → rules → dedup → clean\_table

sql/kpi\_calculations.sql → kpi\_1 … kpi\_10 → kpi\_results

assets/ → screenshots (row counts, KPI output, before/after checks)

dataset/C01\_l01\_ecommerce\_retail\_data.xlsx



### 3\) KPIs delivered

KPI 1: Average Order Value (AOV) — average revenue per valid order.

KPI 2: Gross Margin % — profit share after cost.

KPI 3: Return Rate — share of orders returned.

KPI 4: Orders by Segment — how volume splits by customer tier.

KPI 5: Segment GMV Share — how revenue splits by tier.

KPI 6: High-Value Segment GMV Share — revenue share from premium tiers.

KPI 7: Peak Hour — which hour sees the most orders.

KPI 8: Top Month by GMV — best month by sales.

KPI 9: Latest MoM GMV Growth — most recent month vs the prior month.

KPI 10: Max MoM Payment Share Shift — biggest month-to-month change in payment mix.



### 4\) Data issues and how they were handled

Mixed date formats → multi-format parsing into a single typed date.

Category/segment typos → normalised mapping into a small, consistent set of values.

Invalid values (e.g. negative amounts, impossible hours) → rule-based filtering with counts reported.

Duplicates → deduplicated on a strict business key (documented in the SQL).



### 5) Tech stack

SQL (CTEs, CASE, window functions, data-quality checks)

Execution environment: Verulam Blue Mint

Version control: Git



### 6) Key learnings

Profiling first makes cleaning decisions measurable and defensible.

Data-quality rules are business decisions, not just technical ones.

A clean, shared denominator (clean\_table) prevents silent KPI drift.



### 7) How to run (optional)

Open your SQL environment.

Run: sql/data\_cleaning\_pipeline.sql

Run: sql/kpi\_calculations.sql

Check outputs in: clean\_table and kpi\_results

