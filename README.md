# Shake Shack Marketing Intelligence Agent (Shake IQ)

## Multi-Domain Analytics Agent for C-Suite Marketing Decision-Making

**Version**: 2.0 (April 2026)
**Agent**: `DEMO_DB.SHAKE_SHACK.SHAKE_SHACK_IQ_AGENT`
**Key Capabilities**: Customer intelligence, channel economics, menu/LTO analytics, retention cohort analysis, ML churn scoring, guest review search (11 platforms)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture](#architecture)
3. [Snowflake Objects Inventory](#snowflake-objects-inventory)
4. [Data Model](#data-model)
5. [Semantic Views](#semantic-views)
6. [Cortex Search Service](#cortex-search-service)
7. [ML Model](#ml-model)
8. [Agent Configuration](#agent-configuration)
9. [C-Suite Demo Questions](#c-suite-demo-questions)
10. [Deployment](#deployment)

---

## Executive Summary

The Shake IQ Agent is a Snowflake Cortex Agent designed for Shake Shack's C-suite (CMO, CFO, COO) and senior marketing leadership. It combines **four semantic views**, an **ML-powered churn scoring tool**, and a **Cortex Search service** into a single conversational interface that answers strategic questions across:

- **Customer Intelligence** — 50K guest profiles with RFM segmentation, CLV tiers, behavioral segments, and churn risk
- **Channel Financial Analytics** — 2.6M transactions with full channel economics including third-party delivery commissions
- **Menu & LTO Performance** — 12.5M order items with weather correlation, commodity price tracking, and stage-gate innovation pipeline
- **Retention Cohort Analysis** — App acquisition retention tracking with 1-3-5 promotion attribution, format-level (Drive-Thru vs Traditional) and regional (Midwest) breakdowns
- **ML Churn Scoring** — XGBoost model deployed on Snowpark Container Services for real-time churn prediction
- **Guest Review Search** — 9,700+ reviews from 11 platforms (Yelp, Google, TripAdvisor, DoorDash, UberEats, Instagram, TikTok, Twitter, App Store iOS, Google Play, Qualtrics)

Data covers **18 months** (Jan 2025 – Jun 2026), **280+ locations** across 23 US markets and 6 international markets, **7 ordering channels**, and **4 store formats** (Traditional, Drive-Thru, Stadium, Airport).

---

## Architecture

```
                                     Snowflake (DEMO_DB.SHAKE_SHACK)
                             ┌──────────────────────────────────────────────────────┐
                             │                                                      │
  ┌──────────────┐           │   ┌────────────────────────────────────────────────┐  │
  │  11 Source   │───────────│──>│           Data Tables (11)                     │  │
  │  Tables      │           │   │  Guests ─ Transactions ─ Order Items           │  │
  │  (synthetic) │           │   │  Locations ─ Menu Items ─ Channels             │  │
  └──────────────┘           │   │  LTO Campaigns ─ Marketing Campaigns           │  │
                             │   │  Weather ─ Commodity Prices ─ Guest Reviews    │  │
                             │   └──────────────┬─────────────────────────────────┘  │
                             │                  │                                    │
                             │                  v                                    │
                             │   ┌────────────────────────────────────────────────┐  │
                             │   │          Pre-Joined Mart Tables (4)            │  │
                             │   │                                                │  │
                             │   │  MKT_CUSTOMER_          MKT_CHANNEL_           │  │
                             │   │  INTELLIGENCE_MART      FINANCIAL_MART         │  │
                             │   │  (50K rows)             (2.6M rows)            │  │
                             │   │                                                │  │
                             │   │  MKT_MENU_              MKT_GUEST_             │  │
                             │   │  PERFORMANCE_MART       RETENTION_COHORT       │  │
                             │   │  (12.5M rows)           (per-guest cohort)     │  │
                             │   └──────────────┬─────────────────────────────────┘  │
                             │                  │                                    │
                             │                  v                                    │
                             │   ┌────────────────────────────────────────────────┐  │
                             │   │   Semantic Views (4) + Search Service (1)      │  │
                             │   │                                                │  │
                             │   │  Customer    Channel    Menu &    Retention     │  │
                             │   │  Intelligence Financial LTO      Cohort        │  │
                             │   │  View (13VQR) View(8VQR) View(10VQR) View      │  │
                             │   │                                                │  │
                             │   │  MKT_REVIEW_SEARCH_SERVICE (9,700+ reviews)    │  │
                             │   └──────────────┬─────────────────────────────────┘  │
                             │                  │                                    │
                             │                  v                                    │
                             │   ┌────────────────────────────────────────────────┐  │
  ┌──────────────┐           │   │                                                │  │
  │  Snowflake   │<──────────│───│   SHAKE_SHACK_IQ_AGENT (Cortex Agent)          │  │
  │  Intelligence│           │   │                                                │  │
  │  UI          │           │   │  Tools:                                        │  │
  └──────────────┘           │   │   1. customer_intelligence (text-to-SQL)       │  │
                             │   │   2. channel_financial (text-to-SQL)            │  │
                             │   │   3. menu_lto (text-to-SQL)                    │  │
                             │   │   4. retention_cohort (text-to-SQL)             │  │
                             │   │   5. score_customer (ML procedure)              │  │
                             │   │   6. guest_reviews (Cortex Search)              │  │
                             │   │                                                │  │
                             │   └────────────────────────────────────────────────┘  │
                             │                  ^                                    │
                             │                  │                                    │
                             │   ┌──────────────┴─────────────────────────────────┐  │
                             │   │  ML Infrastructure (SPCS)                      │  │
                             │   │  XGBoost Churn Model (MKT_CHURN_MODEL V1)      │  │
                             │   │  Inference Service (MKT_CHURN_SERVICE)          │  │
                             │   │  Stored Proc (SCORE_CUSTOMER_TOOL)              │  │
                             │   └────────────────────────────────────────────────┘  │
                             └──────────────────────────────────────────────────────┘
```

---

## Snowflake Objects Inventory

### Source Tables

| Object | Fully Qualified Name | Rows | Description |
|---|---|---|---|
| **Locations** | `DEMO_DB.SHAKE_SHACK.MKT_LOCATIONS` | 286 | 237 US + 44 intl + 5 new Midwest drive-thrus |
| **Menu Items** | `DEMO_DB.SHAKE_SHACK.MKT_MENU_ITEMS` | 125 | 86 core + 39 LTO items |
| **Channel Economics** | `DEMO_DB.SHAKE_SHACK.MKT_CHANNEL_ECONOMICS` | 7 | Per-channel cost structure |
| **Commodity Prices** | `DEMO_DB.SHAKE_SHACK.MKT_COMMODITY_PRICES` | 3,288 | 18 months × 6 commodities |
| **Weather Daily** | `DEMO_DB.SHAKE_SHACK.MKT_WEATHER_DAILY` | ~154K | Daily weather by location |
| **Guest Profiles** | `DEMO_DB.SHAKE_SHACK.MKT_GUEST_PROFILES` | 50,000 | Full RFM + behavioral data |
| **LTO Campaigns** | `DEMO_DB.SHAKE_SHACK.MKT_LTO_CAMPAIGNS` | 40 | LTO performance tracking |
| **Marketing Campaigns** | `DEMO_DB.SHAKE_SHACK.MKT_MARKETING_CAMPAIGNS` | 101 | Campaign ROI data (incl. APP135) |
| **Transactions** | `DEMO_DB.SHAKE_SHACK.MKT_TRANSACTIONS` | ~2.02M | Order-level records |
| **Order Items** | `DEMO_DB.SHAKE_SHACK.MKT_ORDER_ITEMS` | ~6M | Line item detail |
| **Guest Reviews** | `DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS` | 9,772 | Reviews from 11 platforms |

### Mart Tables

| Object | Fully Qualified Name | Description |
|---|---|---|
| **Customer Intelligence** | `MKT_CUSTOMER_INTELLIGENCE_MART` | Guest profiles + transaction aggregates (50K rows) |
| **Channel Financial** | `MKT_CHANNEL_FINANCIAL_MART` | Transactions + channel economics + guest segments (2.6M rows) |
| **Menu Performance** | `MKT_MENU_PERFORMANCE_MART` | Order items + menu + weather + commodity data (12.5M rows) |
| **Retention Cohort** | `MKT_GUEST_RETENTION_COHORT` | Per-guest app acquisition retention tracking |

### Semantic Views

| Object | Fully Qualified Name | Tools |
|---|---|---|
| **Customer Intelligence** | `MKT_CUSTOMER_INTELLIGENCE_VIEW` | 8 metrics, 30+ dimensions, 13 VQRs |
| **Channel Financial** | `MKT_CHANNEL_FINANCIAL_VIEW` | 9 metrics, 17 dimensions, 8 VQRs |
| **Menu & LTO** | `MKT_MENU_LTO_VIEW` | 6 metrics, 21 dimensions, 10 VQRs |
| **Retention Cohort** | `MKT_RETENTION_COHORT_VIEW` | 6 metrics, 15 dimensions |

### Search Service

| Object | Fully Qualified Name | Description |
|---|---|---|
| **Review Search** | `MKT_REVIEW_SEARCH_SERVICE` | 9,772 reviews, 11 platforms, Arctic Embed v1.5 |

### ML Objects

| Object | Fully Qualified Name | Description |
|---|---|---|
| **Model** | `MKT_CHURN_MODEL` (V1) | XGBoost churn classifier |
| **Service** | `MKT_CHURN_SERVICE` | SPCS inference service |
| **Procedure** | `SCORE_CUSTOMER_TOOL` | Agent tool wrapper (13 params) |

---

## Data Model

### Guest Segmentation Framework

**CLV Tiers** (by lifetime value):

| Tier | Guest Count | LTV Range | Avg Visits |
|---|---|---|---|
| Platinum | 741 | $1,668–$3,528 | 108 |
| Gold | 5,864 | $556–$3,536 | 83 |
| Silver | 22,617 | $167–$3,333 | 73 |
| Bronze | 20,778 | $13–$999 | 25 |

**RFM Segments**: Champions, Loyal Customers, Potential Loyalists, At Risk, Hibernating, Lost, New Customers, About to Sleep

**Behavioral Segments**: High-Value Delivery Dependent, Digital Power User, Lapsed Loyalist, Super Fan, Promising Newcomer, Brand Ambassador, Delivery First, Young & Digital, Traditional Diner, Casual Visitor

### Store Formats

| Format | Count | Key Markets |
|---|---|---|
| Traditional | ~230 | All markets |
| Drive-Thru | 42 | Midwest (6 new), Southeast, Southwest |
| Stadium | ~8 | NYC, Chicago, Philadelphia |
| Airport | ~6 | JFK, EWR, LAX |

### Channel Economics

| Channel | Commission % | Group |
|---|---|---|
| IN_STORE | 0% | IN_RESTAURANT |
| APP | 0% | DIGITAL_DIRECT |
| WEB | 0% | DIGITAL_DIRECT |
| KIOSK | 0% | IN_RESTAURANT |
| UberEats | 28% | THIRD_PARTY_DELIVERY |
| GrubHub | 25% | THIRD_PARTY_DELIVERY |
| DoorDash | 22% | THIRD_PARTY_DELIVERY |

### App 1-3-5 Value Promotion (Q4 2025)

| Items | Discount | Promo Code |
|---|---|---|
| 1 item | $1 off | APP135 |
| 3 items | $3 off | APP135 |
| 5+ items | $5 off | APP135 |

### Review Platforms (11)

| Platform | Type | Key Topics |
|---|---|---|
| Yelp, Google, TripAdvisor | Traditional review | Food quality, service, value |
| DoorDash, UberEats | Delivery review | Delivery experience, packaging |
| Instagram, TikTok, Twitter | Social media | LTO buzz, viral content |
| App Store iOS, Google Play | App store | UX friction, checkout, push notifications |
| Qualtrics | Post-visit survey | Brand loyalty, competitor comparison, reward preferences |

---

## Semantic Views

### 1. MKT_CUSTOMER_INTELLIGENCE_VIEW
Guest segments, loyalty, churn, CLV, and win-back targeting.

### 2. MKT_CHANNEL_FINANCIAL_VIEW
Channel profitability, delivery commissions, and app migration ROI.

### 3. MKT_MENU_LTO_VIEW
Menu margins, LTO incrementality, weather impact, and commodity costs.

### 4. MKT_RETENTION_COHORT_VIEW
App acquisition retention tracking with promo attribution, format-level and regional breakdowns.

---

## Agent Configuration

**Name**: Shake IQ Agent
**Model**: `claude-sonnet-4-5`
**Budget**: 900 seconds, 400K tokens

### Tools (6)

| # | Tool Name | Type | Target |
|---|---|---|---|
| 1 | customer_intelligence | cortex_analyst_text_to_sql | MKT_CUSTOMER_INTELLIGENCE_VIEW |
| 2 | channel_financial | cortex_analyst_text_to_sql | MKT_CHANNEL_FINANCIAL_VIEW |
| 3 | menu_lto | cortex_analyst_text_to_sql | MKT_MENU_LTO_VIEW |
| 4 | retention_cohort | cortex_analyst_text_to_sql | MKT_RETENTION_COHORT_VIEW |
| 5 | score_customer | generic (procedure) | SCORE_CUSTOMER_TOOL |
| 6 | guest_reviews | cortex_search | MKT_REVIEW_SEARCH_SERVICE |

### Multi-Tool Orchestration

| Question Type | Primary Tool | Supporting Tool |
|---|---|---|
| Promotion impact | retention_cohort | channel_financial |
| App drop-off analysis | retention_cohort | guest_reviews (App Store) |
| Loyalty program design | customer_intelligence | guest_reviews (Qualtrics) |
| LTO evaluation | menu_lto | guest_reviews |
| Churn intervention | score_customer | customer_intelligence |

---

## C-Suite Demo Questions

These four questions were designed and validated for a sequential C-suite demo:

**Q1**: *"What was the incremental impact of our 1-3-5 app promotion on overall guest traffic and digital check averages during the fourth quarter compared to non-app users?"*
→ Uses: retention_cohort + channel_financial

**Q2**: *"Across our newly opened drive-thrus in the Midwest, what percentage of guests acquired through the 1-3-5 promotion returned for a second full-priced visit within 30 days?"*
→ Uses: retention_cohort

**Q3**: *"Why did 40% of those newly acquired app users fail to return for a second visit? Analyze our unstructured App Store reviews, in-app feedback, and Braze push-notification engagement from the last 90 days to determine if the drop-off was caused by digital UI friction or offer-fatigue."*
→ Uses: retention_cohort + guest_reviews (App Store)

**Q4**: *"Based on open-text Qualtrics surveys and social media sentiment from our most frequent digital guests, why do they value our brand over competitors, and what specific reward tiers should we build into our 2026 loyalty program to maximize their lifetime value?"*
→ Uses: customer_intelligence + guest_reviews (Qualtrics)

---

## Deployment

### Quick Start

```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE DEMO_DB;
CREATE SCHEMA IF NOT EXISTS SHAKE_SHACK;
USE SCHEMA SHAKE_SHACK;
USE WAREHOUSE ADMIN_WH;
```

Run SQL files in order:

| Step | File | Purpose |
|---|---|---|
| 1 | `01_create_tables.sql` | DDL for 10 source tables |
| 2 | *(data generation — not included)* | Populate source tables with synthetic data |
| 3 | *(mart creation — not included)* | Build 3 pre-joined mart tables |
| 4 | `02_create_reviews_table.sql` | Create MKT_GUEST_REVIEWS + generate ~8K reviews |
| 5 | `03_create_review_search.sql` | Create Cortex Search Service over reviews |
| 6 | `04_create_retention_data.sql` | Midwest locations + APP135 + retention cohort mart |
| 7 | `04b_create_app_qualtrics_reviews.sql` | App Store + Qualtrics review generation |
| 8 | `03_create_review_search.sql` | Re-run to rebuild search service with new reviews |
| 9 | `09d_retention_cohort_view.sql` | Create retention cohort semantic view |
| 10 | `10_create_agent.sql` | Create agent + profile + grants |

### Semantic View YAML Definitions

These YAML files document the semantic view schemas (the actual views are created as Snowflake objects):

| File | Semantic View |
|---|---|
| `09a_customer_intelligence_view.yaml` | MKT_CUSTOMER_INTELLIGENCE_VIEW |
| `09b_channel_financial_view.yaml` | MKT_CHANNEL_FINANCIAL_VIEW |
| `09c_menu_lto_view.yaml` | MKT_MENU_LTO_VIEW |
| `09d_retention_cohort_view.sql` | MKT_RETENTION_COHORT_VIEW (SQL DDL) |

### Access the Agent

1. Go to **Snowsight → AI & ML → Snowflake Intelligence**
2. Select **"Shake IQ Agent"** (green power icon)
3. Try the C-suite demo questions above

---

## Account Details

| Property | Value |
|---|---|
| **Account** | `ymb98636.us-east-1` |
| **Database** | `DEMO_DB` |
| **Schema** | `SHAKE_SHACK` |
| **Warehouse** | `ADMIN_WH` |
| **Role** | `ACCOUNTADMIN` |
| **Agent** | `DEMO_DB.SHAKE_SHACK.SHAKE_SHACK_IQ_AGENT` |

---

*Last Updated: April 2026*
