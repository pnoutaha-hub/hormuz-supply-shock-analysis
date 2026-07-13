-- ============================================================
-- 05_window_functions.sql
-- Strait of Hormuz & Household Spending Project
-- Day 7: adds time-series sophistication to the analysis table -
-- a 3-month rolling average (to smooth noise) and month-over-month
-- percent change (to measure the speed of price movement) for
-- gasoline CPI, producing the final analysis-ready table.
-- ============================================================

-- ---------- Preview: 3-month rolling average of gasoline CPI ----------
-- Window functions calculate a value using a "window" of nearby rows
-- without collapsing them into a single group (unlike GROUP BY, which
-- merges rows together into one row per group).

SELECT
    obs_month,
    cpi_gasoline,
    ROUND(AVG(cpi_gasoline) OVER (
        ORDER BY obs_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW    -- this month + the 2 before it = 3-month window
    ), 2) AS rolling_3mo_avg
FROM master_monthly_full
ORDER BY obs_month;


-- ---------- Build the final table: rolling average + % change ----------
-- Combines the Day 6 month-over-month % change technique (using LAG())
-- with a new 3-month rolling average, added as permanent columns
-- on top of everything already in master_monthly_full.

CREATE TABLE master_monthly_final AS
SELECT
    m.*,
    ROUND(AVG(cpi_gasoline) OVER (
        ORDER BY obs_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS cpi_gasoline_rolling_3mo,
    ROUND(
        (cpi_gasoline - LAG(cpi_gasoline) OVER (ORDER BY obs_month))
        / LAG(cpi_gasoline) OVER (ORDER BY obs_month) * 100
    , 2) AS cpi_gasoline_pct_change
FROM master_monthly_full m
ORDER BY m.obs_month;

-- Verify: should return 470, unchanged from master_monthly_full
-- (confirms this only added columns, not rows)
SELECT COUNT(*) FROM master_monthly_final;

-- Sanity check: view raw value, rolling average, and % change together
-- for a month inside the Iran Sanctions event window
SELECT obs_month, cpi_gasoline, cpi_gasoline_rolling_3mo, cpi_gasoline_pct_change
FROM master_monthly_final
WHERE obs_month = '2011-03-01';


-- ============================================================
-- Day 6 exploratory analysis queries (for reference/reproducibility)
-- These were run against master_monthly_full and produced the
-- results documented in notes/findings.md.
-- ============================================================

-- Gasoline CPI: average month-over-month % change by event period
SELECT
    CASE
        WHEN obs_month BETWEEN '1987-01-01' AND '1988-12-31' THEN 'Tanker War'
        WHEN obs_month BETWEEN '2011-01-01' AND '2012-12-31' THEN 'Iran Sanctions'
        WHEN obs_month BETWEEN '2019-01-01' AND '2019-12-31' THEN 'Tanker Attacks'
        ELSE 'Normal'
    END AS event_period,
    ROUND(AVG(pct_change), 2) AS avg_monthly_pct_change,
    COUNT(*) AS num_months
FROM (
    SELECT
        obs_month,
        cpi_gasoline,
        (cpi_gasoline - LAG(cpi_gasoline) OVER (ORDER BY obs_month))
            / LAG(cpi_gasoline) OVER (ORDER BY obs_month) * 100
            AS pct_change
    FROM master_monthly_full
) sub
GROUP BY event_period
ORDER BY event_period;

-- CPI All Items: same comparison, used to isolate the gasoline-specific
-- effect from general inflation (see decisions_log.md / findings.md)
SELECT
    CASE
        WHEN obs_month BETWEEN '1987-01-01' AND '1988-12-31' THEN 'Tanker War'
        WHEN obs_month BETWEEN '2011-01-01' AND '2012-12-31' THEN 'Iran Sanctions'
        WHEN obs_month BETWEEN '2019-01-01' AND '2019-12-31' THEN 'Tanker Attacks'
        ELSE 'Normal'
    END AS event_period,
    ROUND(AVG(pct_change), 2) AS avg_monthly_pct_change_all_items,
    COUNT(*) AS num_months
FROM (
    SELECT
        obs_month,
        cpi_all_items,
        (cpi_all_items - LAG(cpi_all_items) OVER (ORDER BY obs_month))
            / LAG(cpi_all_items) OVER (ORDER BY obs_month) * 100
            AS pct_change
    FROM master_monthly_full
) sub
GROUP BY event_period
ORDER BY event_period;

-- PCE: gasoline/energy share of total spending by event period
SELECT
    CASE
        WHEN obs_month BETWEEN '1987-01-01' AND '1988-12-31' THEN 'Tanker War'
        WHEN obs_month BETWEEN '2011-01-01' AND '2012-12-31' THEN 'Iran Sanctions'
        WHEN obs_month BETWEEN '2019-01-01' AND '2019-12-31' THEN 'Tanker Attacks'
        ELSE 'Normal'
    END AS event_period,
    ROUND(AVG(pce_gasoline_energy / pce_total * 100), 2) AS avg_gas_share_pct,
    COUNT(*) AS num_months
FROM master_monthly_full
WHERE pce_gasoline_energy IS NOT NULL
GROUP BY event_period
ORDER BY event_period;

-- CE (annual survey): gasoline share of total spending by event period
-- Independent cross-validation against the PCE result above
SELECT
    CASE
        WHEN g.obs_year BETWEEN 1987 AND 1988 THEN 'Tanker War'
        WHEN g.obs_year BETWEEN 2011 AND 2012 THEN 'Iran Sanctions'
        WHEN g.obs_year = 2019 THEN 'Tanker Attacks'
        ELSE 'Normal'
    END AS event_period,
    ROUND(AVG(g.estimate / t.estimate * 100), 2) AS avg_gas_share_pct,
    COUNT(*) AS num_years
FROM ce_gasoline g
JOIN ce_total_expenditures t ON g.obs_year = t.obs_year
GROUP BY event_period
ORDER BY event_period;
