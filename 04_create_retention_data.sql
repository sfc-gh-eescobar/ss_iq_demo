----------------------------------------------------------------------
-- Shake Shack Marketing Intelligence Agent
-- Task: Create retention cohort data model
-- - 5 new Midwest drive-thru locations
-- - APP 1-3-5 value promotion (APP135) campaign
-- - Q4 2025 APP transaction tagging with APP135
-- - New Midwest drive-thru transactions
-- - MKT_GUEST_RETENTION_COHORT mart table
-- Created: 2026-04-20
----------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ADMIN_WH;
USE DATABASE DEMO_DB;
USE SCHEMA SHAKE_SHACK;

----------------------------------------------------------------------
-- 1. ADD APP 1-3-5 CAMPAIGN
----------------------------------------------------------------------
INSERT INTO DEMO_DB.SHAKE_SHACK.MKT_MARKETING_CAMPAIGNS VALUES (
  'CAMP-APP135', 'App 1-3-5 Value Promotion', 'ACQUISITION', 'APP',
  'All Segments', '2025-10-01', '2025-12-31', 750000, 4500000, 385000,
  62000, 48000, 1850000, 2.47
);

----------------------------------------------------------------------
-- 2. ADD 5 NEW MIDWEST DRIVE-THRU LOCATIONS
----------------------------------------------------------------------
INSERT INTO DEMO_DB.SHAKE_SHACK.MKT_LOCATIONS VALUES
('SS-IL-010', 'Naperville Drive-Thru', 'Chicago', 'Midwest', 'US', 'IL', 'Naperville', 41.7508, -88.1535, 'Drive-Thru', '2025-06-15', TRUE, 'APP,DRIVE_THRU,KIOSK', 2800000, 420, 150000, 112000),
('SS-OH-005', 'Columbus Drive-Thru', 'Columbus', 'Midwest', 'US', 'OH', 'Columbus', 39.9612, -82.9988, 'Drive-Thru', '2025-07-01', TRUE, 'APP,DRIVE_THRU,KIOSK', 2400000, 380, 130000, 78000),
('SS-MI-003', 'Troy Drive-Thru', 'Detroit', 'Midwest', 'US', 'MI', 'Troy', 42.6064, -83.1498, 'Drive-Thru', '2025-08-01', TRUE, 'APP,DRIVE_THRU,KIOSK', 2200000, 350, 95000, 95000),
('SS-MN-002', 'Edina Drive-Thru', 'Minneapolis', 'Midwest', 'US', 'MN', 'Edina', 44.8897, -93.3499, 'Drive-Thru', '2025-07-15', TRUE, 'APP,DRIVE_THRU,KIOSK', 2500000, 390, 120000, 105000),
('SS-IN-001', 'Carmel Drive-Thru', 'Indianapolis', 'Midwest', 'US', 'IN', 'Carmel', 39.9784, -86.1180, 'Drive-Thru', '2025-09-01', TRUE, 'APP,DRIVE_THRU,KIOSK', 2100000, 330, 100000, 88000);

----------------------------------------------------------------------
-- 3. TAG Q4 2025 APP TRANSACTIONS WITH APP135 PROMO
-- Applies to ~15% of eligible Q4 APP transactions
-- Discount tiers: $1 off 1 item, $3 off 3 items, $5 off 5+ items
----------------------------------------------------------------------
UPDATE DEMO_DB.SHAKE_SHACK.MKT_TRANSACTIONS
SET PROMO_CODE = 'APP135',
    DISCOUNT_AMOUNT = CASE
      WHEN ITEM_COUNT <= 1 THEN 1.00
      WHEN ITEM_COUNT <= 3 THEN 3.00
      ELSE 5.00 END
WHERE ORDER_CHANNEL = 'APP'
  AND TRANSACTION_DATE BETWEEN '2025-10-01' AND '2025-12-31'
  AND (PROMO_CODE IS NULL OR PROMO_CODE = '')
  AND ABS(HASH(TRANSACTION_ID)) % 100 < 15;

----------------------------------------------------------------------
-- 4. GENERATE TRANSACTIONS FOR NEW MIDWEST DRIVE-THRUS
-- Creates ~25K transactions across 5 new locations for Q3-Q4 2025
----------------------------------------------------------------------
INSERT INTO DEMO_DB.SHAKE_SHACK.MKT_TRANSACTIONS
WITH new_locations AS (
    SELECT LOCATION_ID, OPEN_DATE
    FROM DEMO_DB.SHAKE_SHACK.MKT_LOCATIONS
    WHERE LOCATION_ID IN ('SS-IL-010','SS-OH-005','SS-MI-003','SS-MN-002','SS-IN-001')
),
guest_pool AS (
    SELECT GUEST_ID, PREFERRED_CHANNEL, AVG_ORDER_VALUE
    FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_PROFILES
    WHERE HOME_MARKET IN ('Chicago','Columbus','Detroit','Minneapolis','Indianapolis')
       OR ABS(HASH(GUEST_ID)) % 100 < 30
),
seq AS (
    SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) AS rn
    FROM TABLE(GENERATOR(ROWCOUNT => 50000))
),
base AS (
    SELECT
        s.rn,
        nl.LOCATION_ID,
        nl.OPEN_DATE,
        gp.GUEST_ID,
        gp.AVG_ORDER_VALUE
    FROM seq s
    CROSS JOIN new_locations nl
    CROSS JOIN guest_pool gp
    WHERE MOD(ABS(HASH(s.rn, nl.LOCATION_ID, gp.GUEST_ID)), 10000) < 3
)
SELECT
    UUID_STRING() AS TRANSACTION_ID,
    b.GUEST_ID,
    b.LOCATION_ID,
    DATEADD('day', MOD(ABS(HASH(b.rn, b.LOCATION_ID)), GREATEST(DATEDIFF('day', b.OPEN_DATE, '2025-12-31'), 1)), b.OPEN_DATE) AS TRANSACTION_DATE,
    TIMEADD('minute', MOD(ABS(HASH(b.rn)), 720) + 600, '00:00:00'::TIME) AS TRANSACTION_TIME,
    CASE
        WHEN MOD(ABS(HASH(b.rn, 'channel')), 100) < 40 THEN 'APP'
        WHEN MOD(ABS(HASH(b.rn, 'channel')), 100) < 55 THEN 'KIOSK'
        WHEN MOD(ABS(HASH(b.rn, 'channel')), 100) < 70 THEN 'IN_STORE'
        WHEN MOD(ABS(HASH(b.rn, 'channel')), 100) < 82 THEN 'UBER_EATS'
        WHEN MOD(ABS(HASH(b.rn, 'channel')), 100) < 92 THEN 'DOORDASH'
        ELSE 'GRUBHUB'
    END AS ORDER_CHANNEL,
    ROUND(b.AVG_ORDER_VALUE * (0.8 + MOD(ABS(HASH(b.rn, 'total')), 40) / 100.0), 2) AS ORDER_TOTAL,
    MOD(ABS(HASH(b.rn, 'items')), 5) + 1 AS ITEM_COUNT,
    0 AS DISCOUNT_AMOUNT,
    NULL AS PROMO_CODE,
    CASE
        WHEN MOD(ABS(HASH(b.rn, 'channel')), 100) >= 70 THEN ROUND(2.99 + MOD(ABS(HASH(b.rn, 'fee')), 400) / 100.0, 2)
        ELSE 0
    END AS DELIVERY_FEE,
    0 AS PLATFORM_COMMISSION,
    0 AS NET_REVENUE,
    CASE
        WHEN MOD(ABS(HASH(b.rn)), 720) + 600 < 690 THEN 'BREAKFAST'
        WHEN MOD(ABS(HASH(b.rn)), 720) + 600 < 840 THEN 'LUNCH'
        WHEN MOD(ABS(HASH(b.rn)), 720) + 600 < 1020 THEN 'AFTERNOON'
        WHEN MOD(ABS(HASH(b.rn)), 720) + 600 < 1200 THEN 'DINNER'
        ELSE 'LATE_NIGHT'
    END AS DAYPART,
    FALSE AS IS_FIRST_VISIT
FROM base b;

----------------------------------------------------------------------
-- 5. TAG APP135 ON NEW MIDWEST DRIVE-THRU Q4 TRANSACTIONS
----------------------------------------------------------------------
UPDATE DEMO_DB.SHAKE_SHACK.MKT_TRANSACTIONS
SET PROMO_CODE = 'APP135',
    DISCOUNT_AMOUNT = CASE
      WHEN ITEM_COUNT <= 1 THEN 1.00
      WHEN ITEM_COUNT <= 3 THEN 3.00
      ELSE 5.00 END
WHERE ORDER_CHANNEL = 'APP'
  AND LOCATION_ID IN ('SS-IL-010','SS-OH-005','SS-MI-003','SS-MN-002','SS-IN-001')
  AND TRANSACTION_DATE BETWEEN '2025-10-01' AND '2025-12-31'
  AND (PROMO_CODE IS NULL OR PROMO_CODE = '')
  AND ABS(HASH(TRANSACTION_ID)) % 100 < 15;

----------------------------------------------------------------------
-- 6. CREATE RETENTION COHORT MART TABLE
-- Tracks first-to-second APP visit for retention analysis
----------------------------------------------------------------------
CREATE OR REPLACE TABLE DEMO_DB.SHAKE_SHACK.MKT_GUEST_RETENTION_COHORT AS
WITH visit_sequence AS (
  SELECT
    t.GUEST_ID,
    t.TRANSACTION_DATE,
    t.LOCATION_ID,
    t.ORDER_CHANNEL,
    t.ORDER_TOTAL,
    t.PROMO_CODE,
    t.DISCOUNT_AMOUNT,
    l.FORMAT AS LOCATION_FORMAT,
    l.REGION,
    l.MARKET,
    ROW_NUMBER() OVER (PARTITION BY t.GUEST_ID ORDER BY t.TRANSACTION_DATE, t.TRANSACTION_TIME) AS visit_num
  FROM DEMO_DB.SHAKE_SHACK.MKT_TRANSACTIONS t
  JOIN DEMO_DB.SHAKE_SHACK.MKT_LOCATIONS l ON t.LOCATION_ID = l.LOCATION_ID
  WHERE t.ORDER_CHANNEL = 'APP'
),
first_visits AS (SELECT * FROM visit_sequence WHERE visit_num = 1),
second_visits AS (SELECT * FROM visit_sequence WHERE visit_num = 2)
SELECT
  f.GUEST_ID,
  f.TRANSACTION_DATE AS FIRST_VISIT_DATE,
  f.LOCATION_ID AS FIRST_LOCATION_ID,
  f.LOCATION_FORMAT AS FIRST_LOCATION_FORMAT,
  f.REGION AS FIRST_REGION,
  f.MARKET AS FIRST_MARKET,
  f.ORDER_TOTAL AS FIRST_ORDER_TOTAL,
  f.PROMO_CODE AS ACQUISITION_PROMO,
  f.DISCOUNT_AMOUNT AS FIRST_DISCOUNT,
  s.TRANSACTION_DATE AS SECOND_VISIT_DATE,
  s.ORDER_TOTAL AS SECOND_ORDER_TOTAL,
  s.PROMO_CODE AS SECOND_VISIT_PROMO,
  s.DISCOUNT_AMOUNT AS SECOND_DISCOUNT,
  DATEDIFF('day', f.TRANSACTION_DATE, s.TRANSACTION_DATE) AS DAYS_TO_RETURN,
  CASE WHEN DATEDIFF('day', f.TRANSACTION_DATE, s.TRANSACTION_DATE) <= 30 THEN TRUE ELSE FALSE END AS RETURNED_WITHIN_30,
  CASE WHEN (s.DISCOUNT_AMOUNT = 0 OR s.DISCOUNT_AMOUNT IS NULL) THEN TRUE ELSE FALSE END AS SECOND_VISIT_FULL_PRICE,
  CASE WHEN s.TRANSACTION_DATE IS NOT NULL THEN TRUE ELSE FALSE END AS DID_RETURN,
  p.CLV_TIER,
  p.RFM_SEGMENT,
  p.CHURN_RISK_SCORE,
  p.LOYALTY_ENROLLED
FROM first_visits f
LEFT JOIN second_visits s ON f.GUEST_ID = s.GUEST_ID
LEFT JOIN DEMO_DB.SHAKE_SHACK.MKT_GUEST_PROFILES p ON f.GUEST_ID = p.GUEST_ID;

----------------------------------------------------------------------
-- 7. VERIFY
----------------------------------------------------------------------
SELECT COUNT(*) AS total_cohort_rows FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_RETENTION_COHORT;
SELECT FIRST_LOCATION_FORMAT, FIRST_REGION, COUNT(*) AS guests,
       ROUND(100.0 * SUM(CASE WHEN DID_RETURN THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate,
       ROUND(100.0 * SUM(CASE WHEN RETURNED_WITHIN_30 THEN 1 ELSE 0 END) / COUNT(*), 1) AS thirty_day_rate
FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_RETENTION_COHORT
WHERE ACQUISITION_PROMO = 'APP135'
GROUP BY FIRST_LOCATION_FORMAT, FIRST_REGION
ORDER BY guests DESC;
