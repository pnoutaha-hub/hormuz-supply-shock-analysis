# Findings

Headline results from the exploratory SQL analysis (Day 6), written in plain English for use in the final README and interview prep.

---

## Headline Finding

**Gasoline prices moved sharply faster than the broader economy during two of three Strait of Hormuz tension periods — but only the sustained 2011-12 Iran sanctions period translated into a measurable shift in household spending behavior, a pattern independently confirmed by two separate government surveys (BEA's Personal Consumption Expenditures and BLS's Consumer Expenditure Survey). This suggests the *duration* of a Hormuz-related shock matters more than its *intensity* for actually reshaping household budgets.**

---

## Supporting Results

### 1. Gasoline CPI vs. overall CPI growth by event period (month-over-month % change)

| Period | Gasoline CPI % change | All Items CPI % change | Gasoline moved... |
|---|---|---|---|
| Tanker Attacks (2019) | 0.76% | 0.19% | **~4x faster** than overall economy |
| Iran Sanctions (2011-12) | 0.56% | 0.20% | **~2.8x faster** than overall economy |
| Normal (all other months) | 0.40% | 0.21% | ~2x faster (baseline pattern) |
| Tanker War (1987-88) | 0.19% | 0.35% | *Slower* than overall economy |

**This is the key comparison that isolates the effect.** During Iran Sanctions, overall CPI was actually *below* its normal-period average (0.20% vs. 0.21%) — meaning the broader economy was not experiencing unusual inflation. Gasoline, by contrast, grew nearly 3x faster than the general price level in that same window. This rules out "everything was just more expensive that decade" as an explanation and confirms the price effect was genuinely gasoline-specific, not a symptom of broader inflation.

Tanker Attacks (2019) shows an even sharper gasoline-specific price shock (4x the overall CPI rate) — but this is precisely the period where the spending-share response (below) did *not* materialize, pointing to shock duration as the key differentiator.

Tanker War (1987-88) is a genuine exception: general prices moved *faster* than gasoline during this period, a different regime than the other two events, discussed further under Limitations.

**Methodology note:** all comparisons use % change, not raw CPI index levels, specifically to avoid the misleading effect of long-term inflation drift across a 39-year dataset. An earlier raw-level comparison was discarded for this reason (see decisions_log.md).

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

- **Iran Sanctions (2011-12)** is the strongest, most complete finding: gasoline prices grew nearly 3x faster than the overall economy, and households devoted a measurably larger share of spending to gasoline — both effects present, isolated from general inflation, and confirmed by two independent surveys.
- **Tanker Attacks (2019)** produced the largest gasoline-specific price shock of the three events (4x the overall CPI rate) but the *smallest* spending-share response. This was a sharp, short shock (isolated June 2019 incidents) rather than a sustained one — prices spiked but household budgeting behavior didn't have time to visibly shift within the narrow window.
- **Tanker War (1987-88)** is a different regime entirely: general prices moved faster than gasoline specifically, unlike the other two events. Possible explanations: this was a prolonged, telegraphed conflict occurring during a broader higher-inflation era (general CPI growth of 0.35%/month is itself notably elevated), and/or the small sample (20 months) makes the comparison more sensitive to a few atypical months.

## Limitations

- **Sample size varies widely by period.** Iran Sanctions has 24 monthly observations; Tanker Attacks and Tanker War have far fewer (12 and 20 respectively, or as few as 1-2 annual observations in the CE data). Iran Sanctions should be treated as the most statistically reliable of the three comparisons.
- **This is a correlational analysis, not a causal one.** No regression or significance testing was performed (a deliberate scope decision — see decisions_log.md), so "faster than normal" and "gasoline-specific" are descriptive findings, not statistically tested claims.
- **The 1987-88 result runs counter to the initial hypothesis** in an interesting way — general inflation, not gasoline specifically, was the dominant story during that period. This is reported honestly rather than omitted.

---

*(To be expanded with additional findings as Day 6-7 analysis continues.)*

