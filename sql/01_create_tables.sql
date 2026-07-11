-- ============================================================
-- 01_create_tables.sql
-- Strait of Hormuz & Household Spending Project
-- Creates all 8 core tables used to hold the cleaned raw data
-- from EIA (oil prices), BLS (CPI, Consumer Expenditure Survey),
-- and BEA (Personal Consumption Expenditures).
-- ============================================================

-- Daily Brent crude oil spot price (EIA), 1987-2026
CREATE TABLE oil_prices (
    price_date DATE,
    price NUMERIC
);

-- BLS CPI, All Items, Seasonally Adjusted (CUSR0000SA0), 1987-2019
CREATE TABLE cpi_all_items (
    obs_date DATE,
    value NUMERIC
);

-- BLS CPI, Energy, Seasonally Adjusted (CUSR0000SA0E), 1987-2019
CREATE TABLE cpi_energy (
    obs_date DATE,
    value NUMERIC
);

-- BLS CPI, Gasoline (all types), Seasonally Adjusted (CUSR0000SETB01), 1987-2019
CREATE TABLE cpi_gasoline (
    obs_date DATE,
    value NUMERIC
);

-- BEA Table 2.8.5, Personal Consumption Expenditures by Major Type of Product, Monthly
-- Narrowed to 4 categories: PCE_Total, Goods, Gasoline_and_Energy_Goods, Services
-- (see decisions_log.md entry 7 for reasoning)
CREATE TABLE pce_by_category (
    obs_date DATE,
    category TEXT,
    value NUMERIC
);

-- BLS Consumer Expenditure Survey, Total Average Annual Expenditures
-- All Consumer Units (LB0101), 1987-2019
CREATE TABLE ce_total_expenditures (
    obs_year INT,
    estimate NUMERIC
);

-- BLS Consumer Expenditure Survey, Transportation
-- All Consumer Units (LB0101), 1987-2019
CREATE TABLE ce_transportation (
    obs_year INT,
    estimate NUMERIC
);

-- BLS Consumer Expenditure Survey, Gasoline, other fuels, and motor oil
-- All Consumer Units (LB0101), 1987-2019
CREATE TABLE ce_gasoline (
    obs_year INT,
    estimate NUMERIC
);
