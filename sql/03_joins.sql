-- ============================================================
-- 03_joins.sql
-- Strait of Hormuz & Household Spending Project
-- Day 5: builds the unified master_monthly_full analysis table
-- by aggregating daily oil prices to monthly, pivoting PCE from
-- long to wide format, and joining all 8 source tables together.
-- ============================================================

-- ---------- Step 1: Aggregate daily Brent prices to monthly averages ----------
-- Brent is daily; CPI/PCE are monthly. This collapses oil_prices
-- down to one average price per month so it can be joined against
-- the monthly tables.

CREATE TABLE oil_prices_monthly AS
SELECT
    DATE_TRUNC('month', price_date)::date AS obs_month,
    ROUND(AVG(price), 2) AS avg_monthly_price
FROM oil_prices
GROUP BY DATE_TRUNC('month', price_date)
ORDER BY obs_month;

-- Verify: should return ~470 rows (May 1987 - June 2026)
SELECT COUNT(*) FROM oil_prices_monthly;


-- ---------- Step 2: Pivot PCE from long to wide format ----------
-- pce_by_category holds 4 categories stacked in one table
-- (one row per date per category). Pivoting into 4 separate
-- columns matches the one-row-per-month shape of every other
-- table being joined, and avoids the join producing duplicate
-- rows per date. See decisions_log.md entry 9 for reasoning.

CREATE TABLE pce_by_category_wide AS
SELECT
    obs_date,
    MAX(CASE WHEN category = 'PCE_Total' THEN value END) AS pce_total,
    MAX(CASE WHEN category = 'Goods' THEN value END) AS pce_goods,
    MAX(CASE WHEN category = 'Gasoline_and_Energy_Goods' THEN value END) AS pce_gasoline_energy,
    MAX(CASE WHEN category = 'Services' THEN value END) AS pce_services
FROM pce_by_category
GROUP BY obs_date
ORDER BY obs_date;

-- Verify: should return 396 rows (down from 1584, since 4 rows-per-date
-- collapsed into 1 row-per-date across 4 columns)
SELECT COUNT(*) FROM pce_by_category_wide;


-- ---------- Step 3: Join the monthly tables into master_monthly ----------
-- LEFT JOIN keeps every row from oil_prices_monthly (the anchor table,
-- since Brent's coverage runs 1987-2026) and attaches matching CPI/PCE
-- values wherever a date match exists. Months beyond CPI/PCE's 2019
-- coverage will show NULL in those columns rather than being dropped.

CREATE TABLE master_monthly AS
SELECT
    o.obs_month,
    o.avg_monthly_price AS brent_price,
    ci.value AS cpi_all_items,
    ce.value AS cpi_energy,
    cg.value AS cpi_gasoline,
    p.pce_total,
    p.pce_goods,
    p.pce_gasoline_energy,
    p.pce_services
FROM oil_prices_monthly o
LEFT JOIN cpi_all_items ci ON o.obs_month = ci.obs_date
LEFT JOIN cpi_energy ce ON o.obs_month = ce.obs_date
LEFT JOIN cpi_gasoline cg ON o.obs_month = cg.obs_date
LEFT JOIN pce_by_category_wide p ON o.obs_month = p.obs_date
ORDER BY o.obs_month;

-- Verify: should return 470 rows, matching oil_prices_monthly's count
SELECT COUNT(*) FROM master_monthly;

-- Sanity check 1: a fully-covered month should have no NULLs
SELECT * FROM master_monthly WHERE obs_month = '2011-01-01';

-- Sanity check 2: a month past CPI/PCE coverage should show only
-- brent_price populated, with CPI/PCE columns NULL
SELECT * FROM master_monthly WHERE obs_month = '2025-06-01';


-- ---------- Step 4: Join annual CE data by year ----------
-- ce_total_expenditures / ce_transportation / ce_gasoline are annual
-- (one row per year), while master_monthly is monthly. Joining on
-- EXTRACT(YEAR FROM obs_month) = obs_year attaches each year's single
-- annual CE value to every month within that year. See decisions_log.md
-- entry 10 for reasoning.

CREATE TABLE master_monthly_full AS
SELECT
    m.*,
    cte.estimate AS ce_total_expenditures,
    ctr.estimate AS ce_transportation,
    cga.estimate AS ce_gasoline
FROM master_monthly m
LEFT JOIN ce_total_expenditures cte
    ON EXTRACT(YEAR FROM m.obs_month) = cte.obs_year
LEFT JOIN ce_transportation ctr
    ON EXTRACT(YEAR FROM m.obs_month) = ctr.obs_year
LEFT JOIN ce_gasoline cga
    ON EXTRACT(YEAR FROM m.obs_month) = cga.obs_year
ORDER BY m.obs_month;

-- Verify: should return 470 rows, unchanged from master_monthly
-- (confirms the year-join did not duplicate any rows)
SELECT COUNT(*) FROM master_monthly_full;

-- Sanity check: every month within a given year should show the
-- identical CE value (annual data repeated across months)
SELECT obs_month, ce_transportation
FROM master_monthly_full
WHERE EXTRACT(YEAR FROM obs_month) = 2011
ORDER BY obs_month;
