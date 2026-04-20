----------------------------------------------------------------------
-- Shake Shack Marketing Intelligence Agent
-- Task: Create Cortex Search Service over MKT_GUEST_REVIEWS
-- Created: 2026-04-20
----------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ADMIN_WH;
USE DATABASE DEMO_DB;
USE SCHEMA SHAKE_SHACK;

----------------------------------------------------------------------
-- CREATE CORTEX SEARCH SERVICE
----------------------------------------------------------------------
CREATE OR REPLACE CORTEX SEARCH SERVICE DEMO_DB.SHAKE_SHACK.MKT_REVIEW_SEARCH_SERVICE
  ON REVIEW_TEXT
  ATTRIBUTES PLATFORM, SENTIMENT_LABEL, LTO_ITEM_REFERENCED, IS_LTO_REVIEW, LOCATION_MARKET, TOPICS
  WAREHOUSE = ADMIN_WH
  TARGET_LAG = '1 day'
  AS (
    SELECT
      REVIEW_ID,
      REVIEW_TEXT,
      PLATFORM,
      REVIEW_DATE::VARCHAR AS REVIEW_DATE,
      RATING::VARCHAR AS RATING,
      SENTIMENT_LABEL,
      SENTIMENT_SCORE::VARCHAR AS SENTIMENT_SCORE,
      LTO_ITEM_REFERENCED,
      COALESCE(IS_LTO_REVIEW, FALSE)::VARCHAR AS IS_LTO_REVIEW,
      MENU_ITEMS_MENTIONED,
      LOCATION_MARKET,
      TOPICS,
      LOCATION_ID
    FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS
  );

----------------------------------------------------------------------
-- VERIFY
----------------------------------------------------------------------
SHOW CORTEX SEARCH SERVICES LIKE 'MKT_REVIEW_SEARCH_SERVICE' IN SCHEMA DEMO_DB.SHAKE_SHACK;
