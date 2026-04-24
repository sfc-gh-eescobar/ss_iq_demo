# Snowhouse Clone — Shake Shack IQ Agent

Replicates the full Shake Shack Marketing Intelligence Agent into
`SFCOGSOPS-SNOWHOUSE_AWS_US_WEST_2` under `TEMP.EESCOBAR`, excluding the ML
model and `score_customer` custom function.

## What's deployed

| Object type | Count | Names |
|---|---|---|
| Tables | 16 | `MKT_*` — same schemas and row counts as the source `DEMO_DB.SHAKE_SHACK` account |
| Semantic views | 4 | `MKT_CUSTOMER_INTELLIGENCE_VIEW`, `MKT_CHANNEL_FINANCIAL_VIEW`, `MKT_MENU_LTO_VIEW`, `MKT_RETENTION_COHORT_VIEW` |
| Cortex Search service | 1 | `MKT_REVIEW_SEARCH_SERVICE` over 9,802 guest reviews |
| Agent | 1 | `SHAKE_SHACK_IQ_AGENT` (v2.2, 5 tools — score_customer removed) |

Target compute: `ROLE=SALES_ENGINEER`, `WAREHOUSE=SE_WH`.

## Row-count parity (source → target)

| Table | Rows |
|---|---|
| MKT_CHANNEL_ECONOMICS | 7 |
| MKT_CHANNEL_FINANCIAL_MART | 2,607,600 |
| MKT_COMMODITY_PRICES | 3,288 |
| MKT_CUSTOMER_INTELLIGENCE_MART | 50,000 |
| MKT_GUEST_PROFILES | 50,000 |
| MKT_GUEST_RETENTION_COHORT | 49,449 |
| MKT_GUEST_REVIEWS | 9,802 |
| MKT_LOCATIONS | 286 |
| MKT_LTO_CAMPAIGNS | 41 |
| MKT_LTO_CHANNEL_ATTACH | 116,199 |
| MKT_MARKETING_CAMPAIGNS | 101 |
| MKT_MENU_ITEMS | 126 |
| MKT_MENU_PERFORMANCE_MART | 12,585,572 |
| MKT_ORDER_ITEMS | 6,193,931 |
| MKT_TRANSACTIONS | 2,024,915 |
| MKT_WEATHER_DAILY | 153,988 |

## Replay sequence (from scratch)

1. `01_tables.sql` — creates the 16 MKT_* tables with identical DDL.
2. Stage data load (skipped after one-time run):
   - Source `COPY INTO @SS_EXPORT_STAGE/<T>/` then `GET` to local.
   - Local `PUT` to `@TEMP.EESCOBAR.SS_IMPORT_STAGE/<T>/`.
3. `05_load_data.sql` — `COPY INTO` each table from the staged Parquet files.
4. `02_semantic_views.sql` — 4 SQL-native semantic views.
5. `03_search_service.sql` — Cortex Search service over `MKT_GUEST_REVIEWS` (warehouse rewritten to `SE_WH`).
6. `04_create_agent.sql` — v2.2 agent spec, 5 tools (customer_intelligence, channel_financial, menu_lto, retention_cohort, guest_reviews). `score_customer` was removed; all FQNs rewritten to `TEMP.EESCOBAR`.

## Smoke test

```
Q: "What was the difference in attachment rates for these premium LTOs between
    our in-Shack kiosk orders and our third-party delivery channels across our
    top 20 highest-volume locations?"
```

Expected: Big Shack kiosk ~7.4% vs delivery ~4.3-4.9%; Dubai Chocolate kiosk ~4.3% vs delivery ~2.9-3.6%. Agent response follows the v2.2 template (headline → scorecard → action).

## Differences from source

- **No ML** — `SCORE_CUSTOMER_TOOL` procedure and backing XGBoost service are not replicated. All `score_customer` references removed from the agent spec and tool selection instructions.
- **Warehouse** — search service uses `SE_WH` (source used `ADMIN_WH`).
- **Role** — all grants and ownership under `SALES_ENGINEER`.
