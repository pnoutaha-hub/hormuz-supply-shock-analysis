# Decisions Log

This log tracks the methodological questions, options considered, and reasoning behind each key decision in the project — meant to feed directly into the final README / report, and to be your prep material for interview questions like "walk me through a tradeoff you made."

Format per entry: **Question → Options considered → Reasoning → Decision**

---

### 1. Event window selection (Hormuz tension/risk periods)

**Question:** Which historical Strait of Hormuz risk periods should anchor the event-study analysis?

**Options considered:**
- Four-period structure: 1984-1988 (Tanker War), 2011-2012 (Iran sanctions), 2019 (tanker attacks), 2025-2026 (recent tensions/closure)
- Narrowed three-period structure: 1987-1988, 2011-2012, 2019

**Reasoning:**
- **2025-2026 dropped** — this period turned out to span two qualitatively different events: a June 2025 threat period (Strait stayed open) and an actual closure/blockade beginning March 2026 that was still unfolding as of project start. Using it would mean incomplete, unrevised CPI/PCE data (BEA/BLS release with a lag and PCE undergoes multiple revisions), making any finding provisional rather than solid. Decided the uncertainty wasn't worth it for a first project meant to demonstrate clean, defensible methodology.
- **1984-1988 narrowed to 1987-1988** — EIA's WTI spot price series only starts January 1986, and Brent only starts May 1987. The 1984-1985 portion of the original window has no matching official oil price data. Narrowing to 1987-1988 keeps the historically meaningful "Tanker War" precedent (including Operation Praying Mantis, April 1988) while staying fully inside EIA's data coverage.
- **Noted but not used as a reason to drop the period:** 1986 also saw a major Saudi-driven oil price collapse unrelated to Hormuz risk (OPEC oversupply war), which would have confounded a 1984-1988 or even 1986-1988 window. Starting at 1987 avoids the worst of this overlap.

**Decision:** Use three closed, fully-data-complete event windows: **1987-1988** (Tanker War/Operation Praying Mantis), **2011-2012** (Iran sanctions/EU oil embargo), **2019** (Gulf of Oman tanker attacks). All three are historically closed, fully covered by EIA/BLS/BEA data with no pending revisions, and require no caveats about missing or incomplete data.

---

### 2. Data resolution — annual averages vs. daily/monthly

**Question:** Should annual average price/CPI series be downloaded alongside the daily/monthly data?

**Options considered:**
- Download separate annual average files for oil price and CPI, in addition to daily/monthly.
- Use only daily (oil) and monthly (CPI/PCE) resolution — the finest resolution the sources provide — and skip annual files entirely.

**Reasoning:**
- The research question is about *speed and magnitude of transmission* — how quickly a Hormuz-related oil shock passes through to gasoline CPI. Annual averages would smooth over exactly this signal: a 2-3 month price spike would get diluted into a barely-visible blip once averaged across a full year, working against the thing the project is trying to measure.
- Monthly is the finest common resolution available across data sources anyway, since CPI and PCE are only released monthly — so daily oil + monthly CPI/PCE is already the natural ceiling on granularity for this analysis.
- An annual view isn't lost by skipping the download — it can be computed later in SQL directly from the daily/monthly data already collected (`GROUP BY EXTRACT(YEAR FROM date)`), so there's no need to maintain a second, separate raw file that could drift out of sync with the primary series.

**Decision:** Do not download separate annual average files. Keep raw data at daily (oil) and monthly (CPI/PCE) resolution only. If an annual-level chart is ever wanted later (e.g., a long-run context visual in Tableau), derive it via SQL aggregation from the existing daily/monthly tables rather than pulling a separate source file.

---

### 3. Date range mismatch — Brent (1987-2026) vs. CPI series (1987-2019)

**Question:** Should the Brent daily price file and the three CPI monthly files cover the same date range?

**Options considered:**
- Trim Brent down to match CPI's 1987-2019 range, so all raw files are perfectly aligned.
- Keep Brent at its full available history (1987-2026) and leave CPI at 1987-2019.

**Reasoning:**
- Brent was originally pulled at EIA's full available history without a deliberate cutoff, so it runs through the present (2026). The CPI files were pulled via BLS's One-Screen tool during a session that only captured data through 2019 — discovered after the fact when a commit message incorrectly said "2026" but the actual file contents stopped at 2019.
- Rather than treating this as an error to fully reconcile, it was left as-is: the three finalized event windows (1987-88, 2011-12, 2019) are all fully contained within 2019, so CPI data through 2019 is sufficient for the actual analysis — no event needs data past that point.
- Keeping Brent's longer history has a separate, legitimate benefit: it allows a "big picture" oil price context chart in Tableau (e.g., showing the full 1987-2026 trend line with event windows highlighted) even though the CPI-side household-spending analysis itself only needs data through 2019.

**Decision:** Leave the mismatch in place. `brent_daily_1987_2026.csv` intentionally retains full available history for context/visualization purposes; the three CPI files (`cpi_all_items_monthly_1987_2019.csv`, `cpi_energy_monthly_1987_2019.csv`, `cpi_gasoline_monthly_1987_2019.csv`) are correctly scoped to 1987-2019, which fully covers all three event windows used in the analysis. Filenames and commit messages were corrected on discovery to accurately reflect actual date ranges rather than assumed ones.

---

### 4. Day 2 data sources — why these specific four files (1 BEA + 3 BLS CE)

**Question:** Which BEA and BLS Consumer Expenditure (CE) files should be downloaded to capture the "household spending shift" side of the analysis, beyond the CPI price data already collected on Day 1?

**Options considered:**
- BEA: Table 2.8.7 ("Percent Change in Prices for PCE") vs. Table 2.3.5 (quarterly PCE by product) vs. Table 2.8.5 (monthly PCE by product, dollar levels)
- BLS CE: full income-quintile breakdown (`LB01` demographic with all 6 characteristics: All Consumer Units + 5 income quintiles) vs. national aggregate only (`LB0101` — All Consumer Units)
- BLS CE: how many separate spending categories to pull (total expenditures only, vs. total + transportation + gasoline)

**Reasoning:**
- **BEA Table 2.8.5 chosen over 2.8.7 and 2.3.5:** Table 2.8.7 measures *percent change in prices* — this would have duplicated the CPI data already collected on Day 1, not added new information. Table 2.3.5 has the right content (PCE by category in dollar levels) but is quarterly, too coarse to detect the 1-2 month transmission lag the project is built around. Table 2.8.5 is the monthly version with the same dollar-level category breakdown — the correct combination of frequency and unit type.
- **BLS CE scoped to national aggregate (`LB0101`) only, quintile breakdown dropped:** An income-quintile breakdown (whether lower-income households bear a disproportionate gasoline burden) would have been a genuinely interesting addition, but it wasn't part of the original project scope, would have ~6x'd the CE data pulled, and added a new demographic-comparison dimension to the SQL/Tableau work beyond what the 14-day plan accounts for. Decided to stay aligned with the original scope (national-level spending shares) and treat the quintile angle as a documented "if I had more time" extension for interview discussion instead.
- **Three CE categories pulled (total expenditures, transportation, gasoline) rather than one combined file:** Total expenditures is the denominator needed to calculate spending *shares* (gasoline ÷ total, transportation ÷ total) — without it, the transportation/gasoline dollar figures have no baseline to compare against. Transportation and gasoline were kept as two separate files rather than one item selection, consistent with the separate-single-series approach used for CPI on Day 1, to keep each source file simple and match the join-based SQL approach planned for Day 5.
- **All four files scoped to 1987-2019**, matching the CPI files and covering all three finalized event windows, rather than "2011 to latest" as an initial draft of the plan suggested — the longer range costs nothing (BLS CE data goes back to 1984) and avoids leaving the 1987-88 event window without CE coverage.

**Decision:** Use four Day 2 raw files: `pce_by_category_monthly_1987_2019.csv` (BEA Table 2.8.5, monthly, dollar levels, full product category breakdown) and three BLS CE files — `bls_ce_total_expenditures_annual_1987_2019.csv`, `bls_ce_transportation_annual_1987_2019.csv`, `bls_ce_gasoline_annual_1987_2019.csv` — all scoped to All Consumer Units (national aggregate, no income-quintile split) and 1987-2019.

---

### 5. PostgreSQL installation — EDB/PostgreSQL 18 instead of planned Homebrew 16

**Question:** Which PostgreSQL installation should the project use, given the original plan assumed a fresh Homebrew install but the Mac already had a different Postgres installation present?

**Options considered:**
- Continue with `brew install postgresql@16` as originally planned, potentially running two PostgreSQL installations side by side.
- Uninstall the pre-existing installation and start clean with Homebrew 16.
- Adopt the pre-existing installation (PostgreSQL 18, installed via the EDB installer) as the project's database engine instead.

**Reasoning:**
- The Mac already had PostgreSQL 18 installed and running via the EDB installer (`/Library/PostgreSQL/18/bin/`) before this project started, discovered when the planned Homebrew install caused version confusion.
- Running two separate PostgreSQL installations simultaneously risks port conflicts (both default to 5432) and general confusion about which instance a given tool (psql, pgAdmin, eventually Tableau) is actually talking to.
- Verified via `ps aux | grep postgres` and `brew services list` that Homebrew's `postgresql@16` was installed but never actually running (`status: none`) — so there was no live conflict, but keeping it around unused was unnecessary complexity for no benefit.
- PostgreSQL 18 is newer than the originally planned 16, with no functional downside for this project's needs (standard SQL, no version-specific features required) — adopting it avoids fighting a working setup just to match the original plan's assumption.

**Decision:** Use the pre-existing PostgreSQL 18 (EDB installer) as the project's database engine, managed via pgAdmin 4, rather than proceeding with the originally planned Homebrew installation. Connection details: host `localhost`, port `5432`, database `hormuz_project`, user `postgres` (password-protected, unlike the passwordless Homebrew setup originally planned). Homebrew's unused `postgresql@16` was left installed but confirmed not running, avoiding any port conflict.

---

### 6. CPI/CE data required a wide-to-long reshape before matching the target table structure

**Question:** How should the CPI (All Items, Energy, Gasoline) and PCE raw files be loaded, given they arrived in "wide" format (one row per year with 12 month columns) rather than the "long" format (one row per month) the project's SQL tables were designed around?

**Options considered:**
- Manually restructure each file in Excel (convert 12 month-columns per year into 12 separate rows) before import.
- Load the wide format as-is into a temporary staging table, then use SQL to reshape it into the final long-format table.

**Reasoning:**
- Manual Excel restructuring across 33 years × 12 months per file (three CPI files) would be slow and error-prone with no added value over doing it in SQL.
- Reshaping in SQL is a standard, realistic data engineering technique (unpivoting), and demonstrates a more advanced SQL skill (`UNION ALL` across per-month `SELECT`s, `TO_DATE` string concatenation) than the basic imports used elsewhere in the project — a stronger fit for a project meant to showcase SQL ability.
- Using a temporary staging table (e.g., `cpi_all_items_wide`) keeps the final tables clean and matches the same 2-column structure as every other table in the project, and the staging table is dropped after the reshape completes, leaving no clutter in the final schema.

**Decision:** For each CPI series, create a temporary `_wide` staging table matching the raw file's column structure, import the cleaned CSV into it, then run an `INSERT INTO ... SELECT ... UNION ALL` query to reshape it into the final long-format table (`obs_date`, `value`), and drop the staging table once verified. Applied successfully to `cpi_all_items`, `cpi_energy`, and `cpi_gasoline`.

---

### 7. PCE data narrowed to 4 categories instead of the full ~40-category breakdown

**Question:** The BEA PCE source file contains roughly 40 product category rows (Goods, Durable goods, Motor vehicles, Furnishings, Food, Clothing, Gasoline and other energy goods, Services, Housing, Healthcare, etc.), each spanning 396 columns (33 years × 12 months). Should all categories be imported, or only a subset?

**Options considered:**
- Import and reshape all ~40 categories into the long-format table.
- Import only the categories directly relevant to the project's research question.

**Reasoning:**
- The project's core question concerns gasoline/energy spending specifically, with broader Goods/Services/Total PCE figures needed only as context and denominators for spending-share calculations — none of the other ~36 categories (e.g., healthcare, recreation services, motor vehicles) are used anywhere in the planned analysis.
- Reshaping all 40 categories would require transposing 40 rows × 396 columns manually or via extensive formulas, a large amount of effort for categories that would never be queried.
- The source file's structure (category-as-row, date-as-column, with two stacked header rows for year and month) was also fundamentally different from the CPI files' structure, requiring a one-off extraction approach rather than the reusable wide-to-long SQL pattern used for CPI.

**Decision:** Extract and import only 4 categories: Personal Consumption Expenditures (Total), Goods, Gasoline and other energy goods, and Services. These were pulled directly from the raw file, transposed into long format (`obs_date`, `category`, `value`), and imported directly — no SQL staging table was needed since the extraction already produced the correct final structure.

---

### 8. Day 4 validation scope — null checks and value-range checks completed; duplicate checks skipped

**Question:** How thorough should Day 4's data-cleaning validation be — which checks were worth running across all 8 tables, and which could reasonably be skipped?

**Options considered:**
- Run a full suite of checks per table: null counts, min/max value ranges, duplicate-row detection, and date-range confirmation.
- Run only null checks and value-range checks, skipping duplicate detection and explicit date-range confirmation as separate steps.

**Reasoning:**
- Null checks (`COUNT(*)` vs `COUNT(column)`) and value-range checks (`MIN`/`MAX` sanity-checked against real historical context, e.g. Brent's 1998 low and 2008 high) are the checks most likely to catch a genuine import problem, and every one of the 8 tables passed both cleanly.
- By Day 4, row counts had already been verified at each import step during Day 3 (33 for CE tables, 396 for CPI tables, 1584 for PCE) against expected counts derived from the raw file structure — this made a separate explicit duplicate-row check low-value, since an undetected duplicate would very likely have already shown up as a row-count mismatch at import time.
- Given the low marginal value of the duplicate check relative to the friction encountered writing the combined multi-table query for it, it was consciously skipped rather than pushed through, in favor of moving forward to Day 5.

**Decision:** Day 4 validation was limited to null checks and value-range checks across all 8 tables (all passed). Explicit duplicate-row detection and standalone date-range confirmation queries were skipped as a deliberate scope decision, relying instead on the row-count verification already performed during Day 3's imports.

---

### 9. PCE pivoted from long to wide format before joining into master_monthly

**Question:** `pce_by_category` holds 4 categories stacked in long format (one row per date per category). Since the join target (`master_monthly`) needed one row per month with all variables as separate columns, how should PCE be brought into that structure?

**Options considered:**
- Join in only one PCE category directly (e.g., just Gasoline_and_Energy_Goods), keeping the join simple.
- Pivot all 4 PCE categories into separate columns (`pce_total`, `pce_goods`, `pce_gasoline_energy`, `pce_services`) first, then join the pivoted table.

**Reasoning:**
- Joining in only one category would have permanently discarded the Total, Goods, and Services context that had already been deliberately extracted back on Day 2/3 specifically because they were useful denominators and comparison points for the spending-share analysis.
- Pivoting first (using `CASE WHEN` + `MAX()` + `GROUP BY obs_date`) preserves all 4 categories as separate columns in a single row per month, matching the wide structure of every other table being joined, and avoids the join producing duplicate rows per date (which would have happened if the long-format PCE table were joined directly against the other single-row-per-date tables).

**Decision:** Created `pce_by_category_wide` via a pivot query before joining, giving `master_monthly` four distinct PCE columns instead of a single blended or arbitrarily-chosen category.

---

### 10. Annual CE data joined into master_monthly by year, not exact date

**Question:** `ce_total_expenditures`, `ce_transportation`, and `ce_gasoline` are annual (one row per year), while `master_monthly` is monthly. How should these be joined without either losing the annual data or fabricating monthly detail that doesn't exist in the source?

**Options considered:**
- Attempt to join on exact date, which would fail to match monthly rows to yearly rows entirely.
- Join using `EXTRACT(YEAR FROM obs_month) = obs_year`, so every month within a given year attaches to that year's single annual CE value.

**Reasoning:**
- CE data has no monthly granularity in the source — repeating the annual figure across every month of that year is the honest way to bring it into a monthly table without inventing precision the underlying survey doesn't provide.
- This was verified directly: querying all 12 months of 2011 confirmed `ce_transportation` returned the identical value (8293) for every month, and the overall row count of the joined table stayed at 470 (unchanged from the pre-CE-join `master_monthly`), confirming the year-based join didn't duplicate any rows.

**Decision:** Joined all three CE tables into `master_monthly_full` using `LEFT JOIN ... ON EXTRACT(YEAR FROM m.obs_month) = ce_table.obs_year`, accepting that CE columns will show the same value repeated across all 12 months of a given year — a documented and intentional limitation of using annual survey data alongside monthly indices.

---

### 11. Rolling average window set to 3 months, applied to gasoline CPI

**Question:** What window length should the rolling average use, and which variable(s) should it be applied to?

**Options considered:**
- A longer window (e.g., 6 or 12 months), which would smooth more aggressively.
- A shorter window (3 months), balancing noise reduction against still being responsive to real shocks within the ~12-24 month event windows already established.
- Applying the rolling average to every numeric column vs. only the primary variable of interest (gasoline CPI).

**Reasoning:**
- A 3-month window meaningfully reduces single-month noise while still being short enough to reflect real movement within event windows that are themselves only 12-24 months long (a 12-month rolling average would blur an entire Tanker Attacks-length window into a single smoothed value, defeating its purpose).
- Gasoline CPI was chosen as the variable to smooth since it's the project's core variable of interest, established since Day 6 as showing the clearest event-period signal; applying rolling averages to every column would add unused columns without a clear analytical purpose at this stage.

**Decision:** Added a 3-month rolling average (`cpi_gasoline_rolling_3mo`) and the existing month-over-month percent change (`cpi_gasoline_pct_change`) as permanent columns in `master_monthly_final`, built directly on top of `master_monthly_full` via window functions (`AVG() OVER (...)`, `LAG() OVER (...)`).

---

*(Future entries will be appended here as new methodological decisions come up during the project.)*
