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

*(Future entries will be appended here as new methodological decisions come up during the project.)*
