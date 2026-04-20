----------------------------------------------------------------------
-- Shake Shack Marketing Intelligence Agent
-- Task: Create Retention Cohort semantic view
-- Backs the retention_cohort tool in the agent
-- Created: 2026-04-20
----------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ADMIN_WH;
USE DATABASE DEMO_DB;
USE SCHEMA SHAKE_SHACK;

----------------------------------------------------------------------
-- CREATE SEMANTIC VIEW
----------------------------------------------------------------------
CREATE OR REPLACE SEMANTIC VIEW MKT_RETENTION_COHORT_VIEW
  TABLES (
    RETENTION AS DEMO_DB.SHAKE_SHACK.MKT_GUEST_RETENTION_COHORT
      PRIMARY KEY (GUEST_ID)
      COMMENT='Per-guest app acquisition retention cohort with 30-day return tracking and promo attribution.'
  )
  FACTS (
    RETENTION.FIRST_ORDER_TOTAL AS FIRST_ORDER_TOTAL COMMENT='First visit order total',
    RETENTION.FIRST_DISCOUNT AS FIRST_DISCOUNT COMMENT='Discount on first visit',
    RETENTION.SECOND_ORDER_TOTAL AS SECOND_ORDER_TOTAL COMMENT='Second visit order total',
    RETENTION.SECOND_DISCOUNT AS SECOND_DISCOUNT COMMENT='Discount on second visit',
    RETENTION.DAYS_TO_RETURN AS DAYS_TO_RETURN COMMENT='Days between first and second visit',
    RETENTION.CHURN_RISK_SCORE AS CHURN_RISK_SCORE COMMENT='ML churn risk score 0-100'
  )
  DIMENSIONS (
    RETENTION.GUEST_ID AS GUEST_ID COMMENT='Guest identifier',
    RETENTION.FIRST_VISIT_DATE AS FIRST_VISIT_DATE COMMENT='Date of first app visit',
    RETENTION.FIRST_LOCATION_ID AS FIRST_LOCATION_ID COMMENT='Location of first visit',
    RETENTION.FIRST_LOCATION_FORMAT AS FIRST_LOCATION_FORMAT COMMENT='Store format: Traditional, Drive-Thru, Stadium, Airport',
    RETENTION.FIRST_REGION AS FIRST_REGION COMMENT='Region: Northeast, Midwest, Southeast, West, Southwest, International',
    RETENTION.FIRST_MARKET AS FIRST_MARKET COMMENT='Market metro area',
    RETENTION.ACQUISITION_PROMO AS ACQUISITION_PROMO COMMENT='Promo code used on first visit (e.g. APP135 for the 1-3-5 promotion)',
    RETENTION.SECOND_VISIT_DATE AS SECOND_VISIT_DATE COMMENT='Date of second visit',
    RETENTION.SECOND_VISIT_PROMO AS SECOND_VISIT_PROMO COMMENT='Promo code used on second visit',
    RETENTION.RETURNED_WITHIN_30 AS RETURNED_WITHIN_30 COMMENT='Whether guest returned within 30 days (TRUE/FALSE)',
    RETENTION.SECOND_VISIT_FULL_PRICE AS SECOND_VISIT_FULL_PRICE COMMENT='Whether second visit was full price with no promo (TRUE/FALSE)',
    RETENTION.DID_RETURN AS DID_RETURN COMMENT='Whether guest made a second visit at all (TRUE/FALSE)',
    RETENTION.CLV_TIER AS CLV_TIER COMMENT='Customer lifetime value tier: PLATINUM, GOLD, SILVER, BRONZE',
    RETENTION.RFM_SEGMENT AS RFM_SEGMENT COMMENT='RFM segment name',
    RETENTION.LOYALTY_ENROLLED AS LOYALTY_ENROLLED COMMENT='Whether guest is enrolled in loyalty program'
  )
  METRICS (
    RETENTION.TOTAL_ACQUIRED AS COUNT(*) COMMENT='Total guests acquired',
    RETENTION.RETURNED_COUNT AS SUM(CASE WHEN DID_RETURN THEN 1 ELSE 0 END) COMMENT='Guests who made a second visit',
    RETENTION.RETURNED_30D_COUNT AS SUM(CASE WHEN RETURNED_WITHIN_30 THEN 1 ELSE 0 END) COMMENT='Guests who returned within 30 days',
    RETENTION.FULL_PRICE_30D_COUNT AS SUM(CASE WHEN RETURNED_WITHIN_30 AND SECOND_VISIT_FULL_PRICE THEN 1 ELSE 0 END) COMMENT='Guests who returned within 30 days at full price',
    RETENTION.RETENTION_RATE AS ROUND(100.0 * SUM(CASE WHEN RETURNED_WITHIN_30 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) COMMENT='30-day retention rate percentage',
    RETENTION.FULL_PRICE_RETURN_RATE AS ROUND(100.0 * SUM(CASE WHEN RETURNED_WITHIN_30 AND SECOND_VISIT_FULL_PRICE THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) COMMENT='30-day full-price return rate percentage'
  )
  COMMENT='App acquisition retention analysis for Shake Shack. Tracks 1-3-5 promo guest retention by format (Drive-Thru, Traditional), region (Midwest, etc.), and CLV tier. Answers: what % of promo-acquired guests returned within 30 days at full price.';

----------------------------------------------------------------------
-- VERIFY
----------------------------------------------------------------------
SHOW SEMANTIC VIEWS LIKE 'MKT_RETENTION_COHORT_VIEW' IN SCHEMA DEMO_DB.SHAKE_SHACK;
