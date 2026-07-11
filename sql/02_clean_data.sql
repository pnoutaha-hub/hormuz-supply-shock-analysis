-- ============================================================
-- 02_clean_data.sql
-- Strait of Hormuz & Household Spending Project
-- Reshapes the three CPI series from "wide" format (one row per
-- year, 12 month columns) into "long" format (one row per month)
-- to match the structure of cpi_all_items / cpi_energy / cpi_gasoline.
--
-- Pattern: create a temporary staging table matching the wide CSV's
-- shape, import into it, reshape via INSERT ... SELECT ... UNION ALL,
-- verify, then drop the staging table.
-- See decisions_log.md entry 6 for reasoning behind this approach.
-- ============================================================

-- ---------- CPI ALL ITEMS ----------

CREATE TABLE cpi_all_items_wide (
    obs_year INT,
    jan NUMERIC, feb NUMERIC, mar NUMERIC, apr NUMERIC,
    may NUMERIC, jun NUMERIC, jul NUMERIC, aug NUMERIC,
    sep NUMERIC, oct NUMERIC, nov NUMERIC, dec NUMERIC
);
-- (cpi_all_items_monthly_1987_2019_clean.csv imported here via pgAdmin)

INSERT INTO cpi_all_items (obs_date, value)
SELECT TO_DATE(obs_year || '-01', 'YYYY-MM'), jan FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-02', 'YYYY-MM'), feb FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-03', 'YYYY-MM'), mar FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-04', 'YYYY-MM'), apr FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-05', 'YYYY-MM'), may FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-06', 'YYYY-MM'), jun FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-07', 'YYYY-MM'), jul FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-08', 'YYYY-MM'), aug FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-09', 'YYYY-MM'), sep FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-10', 'YYYY-MM'), oct FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-11', 'YYYY-MM'), nov FROM cpi_all_items_wide
UNION ALL
SELECT TO_DATE(obs_year || '-12', 'YYYY-MM'), dec FROM cpi_all_items_wide;

-- Verify: should return 396 (33 years x 12 months)
SELECT COUNT(*) FROM cpi_all_items;

DROP TABLE cpi_all_items_wide;


-- ---------- CPI ENERGY ----------

CREATE TABLE cpi_energy_wide (
    obs_year INT,
    jan NUMERIC, feb NUMERIC, mar NUMERIC, apr NUMERIC,
    may NUMERIC, jun NUMERIC, jul NUMERIC, aug NUMERIC,
    sep NUMERIC, oct NUMERIC, nov NUMERIC, dec NUMERIC
);
-- (cpi_energy_monthly_1987_2019_clean.csv imported here via pgAdmin)

INSERT INTO cpi_energy (obs_date, value)
SELECT TO_DATE(obs_year || '-01', 'YYYY-MM'), jan FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-02', 'YYYY-MM'), feb FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-03', 'YYYY-MM'), mar FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-04', 'YYYY-MM'), apr FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-05', 'YYYY-MM'), may FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-06', 'YYYY-MM'), jun FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-07', 'YYYY-MM'), jul FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-08', 'YYYY-MM'), aug FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-09', 'YYYY-MM'), sep FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-10', 'YYYY-MM'), oct FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-11', 'YYYY-MM'), nov FROM cpi_energy_wide
UNION ALL
SELECT TO_DATE(obs_year || '-12', 'YYYY-MM'), dec FROM cpi_energy_wide;

-- Verify: should return 396
SELECT COUNT(*) FROM cpi_energy;

DROP TABLE cpi_energy_wide;


-- ---------- CPI GASOLINE ----------

CREATE TABLE cpi_gasoline_wide (
    obs_year INT,
    jan NUMERIC, feb NUMERIC, mar NUMERIC, apr NUMERIC,
    may NUMERIC, jun NUMERIC, jul NUMERIC, aug NUMERIC,
    sep NUMERIC, oct NUMERIC, nov NUMERIC, dec NUMERIC
);
-- (cpi_gasoline_monthly_1987_2019_clean.csv imported here via pgAdmin)

INSERT INTO cpi_gasoline (obs_date, value)
SELECT TO_DATE(obs_year || '-01', 'YYYY-MM'), jan FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-02', 'YYYY-MM'), feb FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-03', 'YYYY-MM'), mar FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-04', 'YYYY-MM'), apr FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-05', 'YYYY-MM'), may FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-06', 'YYYY-MM'), jun FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-07', 'YYYY-MM'), jul FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-08', 'YYYY-MM'), aug FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-09', 'YYYY-MM'), sep FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-10', 'YYYY-MM'), oct FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-11', 'YYYY-MM'), nov FROM cpi_gasoline_wide
UNION ALL
SELECT TO_DATE(obs_year || '-12', 'YYYY-MM'), dec FROM cpi_gasoline_wide;

-- Verify: should return 396
SELECT COUNT(*) FROM cpi_gasoline;

DROP TABLE cpi_gasoline_wide;


-- ============================================================
-- Day 4: Data validation
-- Confirms no missing values and realistic min/max ranges
-- across all 8 tables. All 8 passed both checks.
-- (Duplicate-row checks were deliberately skipped as low-value
-- given row counts were already verified at import time -
-- see decisions_log.md entry 8)
-- ============================================================

-- Null check pattern (repeated for every table, swapping column/table name)
SELECT COUNT(*) AS total_rows, COUNT(price) AS non_null_prices
FROM oil_prices;

-- Value-range check pattern (repeated for every table)
SELECT MIN(price) AS lowest_price, MAX(price) AS highest_price
FROM oil_prices;

-- PCE range check, grouped by category since PCE holds 4 categories
-- at very different scales in one table
SELECT category, MIN(value) AS lowest_value, MAX(value) AS highest_value
FROM pce_by_category
GROUP BY category;
