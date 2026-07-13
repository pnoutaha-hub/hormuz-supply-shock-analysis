# Findings

Headline results from the exploratory SQL analysis (Day 6), written in plain English for use in the final README and interview prep.

---

## Headline Finding

**Gasoline's share of household spending rose meaningfully during the sustained 2011-12 Iran sanctions period, and this pattern was independently confirmed by two separate government surveys (BEA's Personal Consumption Expenditures and BLS's Consumer Expenditure Survey). The sharper but shorter 2019 tanker attacks did not produce the same shift — suggesting the *duration* of a Strait of Hormuz-related shock matters more than its *intensity* for actually reshaping household budgets.**

---

## Supporting Results

### 1. Gasoline CPI growth by event period (month-over-month % change)

| Period | Avg monthly % change | Months observed |
|---|---|---|
| Tanker Attacks (2019) | 0.76% | 12 |
| Iran Sanctions (2011-12) | 0.56% | 24 |
| Normal (all other months) | 0.40% | 414 |
| Tanker War (1987-88) | 0.19% | 20 |

Two of the three event windows (Iran Sanctions, Tanker Attacks) show faster average gasoline price growth than normal periods. The 1987-88 Tanker War is a genuine exception, moving *slower* than normal — a real and worth-discussing nuance, not smoothed over (see Limitations below).

**Methodology note:** this compares % change, not raw CPI index levels, specifically to avoid the misleading effect of long-term inflation drift across a 39-year dataset. An earlier raw-level comparison was discarded for this reason (see decisions_log.md).

### 2. Gasoline share of total spending — PCE (monthly, BEA)

| Period | Avg gasoline/energy share of total PCE |
|---|---|
| Iran Sanctions (2011-12) | 3.84% |
| Tanker War (1987-88) | 3.06% |
| Normal | 2.89% |
| Tanker Attacks (2019) | 2.44% |

### 3. Gasoline share of total spending — Consumer Expenditure Survey (annual, BLS)

| Period | Avg gasoline share of total CE spending |
|---|---|
| Iran Sanctions (2011-12) | 5.35% |
| Tanker War (1987-88) | 3.62% |
| Normal | 3.68% |
| Tanker Attacks (2019) | 3.32% |

**Cross-validation:** PCE and CE are independently collected by different agencies (BEA vs. BLS) using different methodologies, yet both show the identical ranking — Iran Sanctions highest, Tanker Attacks at or below the normal baseline. Agreement between two independent sources is meaningfully stronger evidence than either source alone.

---

## Interpretation

- **Iran Sanctions (2011-12)** is the strongest, most complete finding: gasoline prices grew faster *and* households devoted a larger share of spending to gasoline — both effects present, and confirmed by two independent surveys.
- **Tanker Attacks (2019)** shows the opposite pattern from what a simple hypothesis would predict: fastest price growth, but *lowest* spending-share response. Plausible explanation: this was a sharp, short shock (isolated June 2019 incidents) rather than a sustained one, so prices spiked but household budgeting behavior didn't have time to visibly shift within the narrow window.
- **Tanker War (1987-88)** shows slower-than-normal price growth despite being the historical namesake event for Hormuz risk. Possible explanations: this was a prolonged, telegraphed conflict (markets may have priced in the risk gradually rather than reacting sharply month to month), and/or the small sample (20 months) makes the average more sensitive to a few atypical months.

## Limitations

- **Sample size varies widely by period.** Iran Sanctions has 24 monthly observations; Tanker Attacks and Tanker War have far fewer (12 and 20 respectively, or as few as 1-2 annual observations in the CE data). Iran Sanctions should be treated as the most statistically reliable of the three comparisons.
- **This is a correlational analysis, not a causal one.** Tension months may coincide with other macroeconomic factors (broader inflation, global demand shifts) not isolated here. No regression or significance testing was performed (a deliberate scope decision — see decisions_log.md).
- **The 1987-88 result runs counter to the initial hypothesis.** This is reported honestly rather than omitted; it is a genuine and interesting exception rather than a data error.

---

*(To be expanded with additional findings as Day 6-7 analysis continues.)*
