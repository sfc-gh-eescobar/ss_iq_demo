----------------------------------------------------------------------
-- Shake Shack Marketing Intelligence Agent
-- Task: Create MKT_GUEST_REVIEWS table with ~8,000 synthetic reviews
-- Platforms: Yelp, Google, TripAdvisor, DoorDash, UberEats, Instagram, TikTok, Twitter
-- Created: 2026-04-20
----------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ADMIN_WH;
USE DATABASE DEMO_DB;
USE SCHEMA SHAKE_SHACK;

----------------------------------------------------------------------
-- 1. CREATE TABLE
----------------------------------------------------------------------
CREATE OR REPLACE TABLE DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS (
    REVIEW_ID               VARCHAR(36)     NOT NULL PRIMARY KEY,
    LOCATION_ID             VARCHAR(20)     NOT NULL,
    PLATFORM                VARCHAR(30)     NOT NULL,
    REVIEW_DATE             DATE            NOT NULL,
    RATING                  NUMBER(2,1),
    REVIEW_TEXT             VARCHAR(4000)   NOT NULL,
    MENU_ITEMS_MENTIONED    VARCHAR(500),
    LTO_ITEM_REFERENCED     VARCHAR(100),
    SENTIMENT_LABEL         VARCHAR(20)     NOT NULL,
    SENTIMENT_SCORE         NUMBER(5,2)     NOT NULL,
    TOPICS                  VARCHAR(200)    NOT NULL,
    LOCATION_MARKET         VARCHAR(50)     NOT NULL,
    IS_LTO_REVIEW           BOOLEAN         NOT NULL DEFAULT FALSE
);

----------------------------------------------------------------------
-- 2. GENERATE SYNTHETIC REVIEW DATA (~8,000 rows)
----------------------------------------------------------------------

-- Step 1: Build a review template table with realistic text
CREATE OR REPLACE TEMPORARY TABLE _REVIEW_TEMPLATES AS

-- === POSITIVE LTO REVIEWS (will be matched to high-sentiment LTOs) ===
SELECT 1 AS template_id, 'LTO_POSITIVE' AS template_type, 'POSITIVE' AS sentiment_label, 0.85 AS sentiment_score,
  'Tried the {LTO_ITEM} today and WOW. This needs to be a permanent menu item. I will absolutely be coming back specifically for this.' AS review_text, 'FOOD_QUALITY,LTO' AS topics, 5.0 AS rating
UNION ALL SELECT 2, 'LTO_POSITIVE', 'POSITIVE', 0.90,
  'The {LTO_ITEM} is hands down the best thing Shake Shack has ever put on the menu. I drove 30 minutes out of my way to get it. Please make this permanent!', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 3, 'LTO_POSITIVE', 'POSITIVE', 0.82,
  'Just had the {LTO_ITEM} for the second time this week. The flavors are incredible and the quality is exactly what I expect from Shake Shack. Already told all my friends about it.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 4, 'LTO_POSITIVE', 'POSITIVE', 0.78,
  'The new {LTO_ITEM} is legit. Great flavor, good portion size, and totally worth the price. Hope they keep it on the menu.', 'FOOD_QUALITY,LTO,VALUE', 4.5
UNION ALL SELECT 5, 'LTO_POSITIVE', 'POSITIVE', 0.88,
  'Came in just to try the {LTO_ITEM} and ended up ordering two. This is exactly the kind of innovation that keeps me coming back to Shake Shack over the competition.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 6, 'LTO_POSITIVE', 'POSITIVE', 0.80,
  'The {LTO_ITEM} exceeded all expectations. Perfect balance of flavors. My whole family loved it. We will be back before it leaves the menu for sure.', 'FOOD_QUALITY,LTO', 4.5
UNION ALL SELECT 7, 'LTO_POSITIVE', 'POSITIVE', 0.75,
  'Solid addition to the menu. The {LTO_ITEM} is creative without being gimmicky. Would definitely order again.', 'FOOD_QUALITY,LTO', 4.0
UNION ALL SELECT 8, 'LTO_POSITIVE', 'POSITIVE', 0.92,
  'I have been obsessed with the {LTO_ITEM}. This is the third time ordering it in two weeks. Shake Shack knocked it out of the park with this one. If they remove it I will riot.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 9, 'LTO_POSITIVE', 'POSITIVE', 0.85,
  'The {LTO_ITEM} is the reason I keep choosing Shake Shack over Five Guys and Smashburger. This is premium fast casual done right.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 10, 'LTO_POSITIVE', 'POSITIVE', 0.79,
  'Finally tried the {LTO_ITEM} everyone has been raving about on TikTok. Lives up to the hype! Great textures, bold flavor, Instagram-worthy presentation.', 'FOOD_QUALITY,LTO', 4.5

-- === NEGATIVE LTO REVIEWS (will be matched to low-sentiment LTOs) ===
UNION ALL SELECT 11, 'LTO_NEGATIVE', 'NEGATIVE', -0.65,
  'The {LTO_ITEM} was a total miss for me. Not worth the upcharge. I should have just gotten the regular ShackBurger like I always do.', 'FOOD_QUALITY,LTO,VALUE', 2.0
UNION ALL SELECT 12, 'LTO_NEGATIVE', 'NEGATIVE', -0.72,
  'Really disappointed by the {LTO_ITEM}. The flavors were muddled, portion felt small for the price. Shake Shack can do better than this.', 'FOOD_QUALITY,LTO,VALUE', 1.5
UNION ALL SELECT 13, 'LTO_NEGATIVE', 'NEGATIVE', -0.55,
  'Tried the {LTO_ITEM} based on all the social media buzz. Honestly? Overrated. It is fine but nothing special. Would not order it again when the classic menu is right there.', 'FOOD_QUALITY,LTO', 2.5
UNION ALL SELECT 14, 'LTO_NEGATIVE', 'NEGATIVE', -0.68,
  'The {LTO_ITEM} looked way better in the photos. What I got was a mess. Flavors did not come together at all. Back to the SmokeShack for me.', 'FOOD_QUALITY,LTO', 2.0
UNION ALL SELECT 15, 'LTO_NEGATIVE', 'NEGATIVE', -0.50,
  'Meh on the {LTO_ITEM}. Not terrible, but definitely not worth switching from my usual order. Felt like a gimmick.', 'FOOD_QUALITY,LTO', 2.5
UNION ALL SELECT 16, 'LTO_NEGATIVE', 'NEGATIVE', -0.60,
  'The concept of the {LTO_ITEM} is cool but the execution was lacking. Soggy, underseasoned, and overpriced. Hard pass.', 'FOOD_QUALITY,LTO,VALUE', 2.0
UNION ALL SELECT 17, 'LTO_NEGATIVE', 'NEGATIVE', -0.45,
  'Had the {LTO_ITEM} and was underwhelmed. It is not bad per se but at Shake Shack prices I expect more. The core menu items are just better.', 'FOOD_QUALITY,LTO,VALUE', 3.0

-- === MIXED LTO REVIEWS ===
UNION ALL SELECT 18, 'LTO_MIXED', 'MIXED', 0.15,
  'The {LTO_ITEM} has potential but needs work. Flavors are interesting but the execution was inconsistent between my two visits. Would try it once but not a repeat buy for me.', 'FOOD_QUALITY,LTO', 3.0
UNION ALL SELECT 19, 'LTO_MIXED', 'MIXED', 0.10,
  'Interesting concept with the {LTO_ITEM}. I can see why some people love it but it is not for me. My wife thought it was amazing though. Worth a try at least once.', 'FOOD_QUALITY,LTO', 3.5
UNION ALL SELECT 20, 'LTO_MIXED', 'MIXED', 0.05,
  'The {LTO_ITEM} is good, not great. I appreciate Shake Shack trying new things but this one is a 6/10 for me. The shake version was better than the burger.', 'FOOD_QUALITY,LTO', 3.0

-- === GENERAL POSITIVE REVIEWS (food quality, service, ambiance) ===
UNION ALL SELECT 21, 'GENERAL_POSITIVE', 'POSITIVE', 0.80,
  'Shake Shack never disappoints. The ShackBurger is consistently one of the best burgers you can get at this price point. Fries were perfectly crispy today.', 'FOOD_QUALITY', 5.0
UNION ALL SELECT 22, 'GENERAL_POSITIVE', 'POSITIVE', 0.75,
  'Great experience as always. Staff was friendly, food came out fast, and everything tasted fresh. The frozen custard is an underrated gem.', 'FOOD_QUALITY,SERVICE', 4.5
UNION ALL SELECT 23, 'GENERAL_POSITIVE', 'POSITIVE', 0.70,
  'First time at this location and it was spotless. Ordered the SmokeShack and cheese fries - both were incredible. Will be a regular here.', 'FOOD_QUALITY,AMBIANCE', 4.5
UNION ALL SELECT 24, 'GENERAL_POSITIVE', 'POSITIVE', 0.65,
  'Love the app ordering. No wait, food was ready right when I walked in, and everything was hot and fresh. This is how fast casual should work.', 'FOOD_QUALITY,SERVICE', 4.0
UNION ALL SELECT 25, 'GENERAL_POSITIVE', 'POSITIVE', 0.72,
  'The quality consistency at Shake Shack is what keeps me coming back. Every single time the burger is perfect, the crinkle cuts are crispy, and the shakes are thick.', 'FOOD_QUALITY', 4.5
UNION ALL SELECT 26, 'GENERAL_POSITIVE', 'POSITIVE', 0.68,
  'Brought the family here for the first time. Kids loved the chicken bites, I had the ShackBurger, and we shared a shake. Everyone was happy. New family spot for sure.', 'FOOD_QUALITY,SERVICE', 4.0
UNION ALL SELECT 27, 'GENERAL_POSITIVE', 'POSITIVE', 0.85,
  'This Shake Shack location is the best one I have been to. Clean, fast, and the burger was absolutely perfect. Crispy lettuce, melty cheese, that ShackSauce... chef kiss.', 'FOOD_QUALITY,SERVICE,AMBIANCE', 5.0
UNION ALL SELECT 28, 'GENERAL_POSITIVE', 'POSITIVE', 0.60,
  'Solid burger joint. Not cheap but you get what you pay for. The ingredients taste premium and the portions are reasonable for the price.', 'FOOD_QUALITY,VALUE', 4.0

-- === GENERAL NEGATIVE REVIEWS (service, wait time, value, delivery) ===
UNION ALL SELECT 29, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.70,
  'Waited 25 minutes for a burger and fries during lunch. The food was fine but that wait time is unacceptable for fast casual. I can get a sit-down meal faster.', 'WAIT_TIME,SERVICE', 2.0
UNION ALL SELECT 30, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.55,
  'The prices have gotten out of control. A burger, fries, and shake is almost $25 now. The food is good but not THAT good. Starting to feel like a ripoff.', 'VALUE', 2.5
UNION ALL SELECT 31, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.65,
  'Ordered through DoorDash and the food arrived cold and soggy. The ShackBurger does NOT travel well. Should have picked it up myself.', 'FOOD_QUALITY,DELIVERY', 2.0
UNION ALL SELECT 32, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.60,
  'The fries were cold and the burger patty was overcooked. For premium prices I expect premium quality. Very inconsistent compared to my usual location.', 'FOOD_QUALITY', 2.0
UNION ALL SELECT 33, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.50,
  'Staff seemed overwhelmed. Order was wrong twice. Had to wait for a remake. I get that they were busy but this is not the experience I am paying extra for.', 'SERVICE,WAIT_TIME', 2.5
UNION ALL SELECT 34, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.72,
  'UberEats delivery was a disaster. Missing items, shake was half melted, and they forgot the sauce packets. Would not order delivery from here again.', 'DELIVERY,SERVICE', 1.5
UNION ALL SELECT 35, 'GENERAL_NEGATIVE', 'NEGATIVE', -0.48,
  'Location was dirty, tables were not wiped down, and the bathroom was out of soap. Food was okay but the overall experience was disappointing.', 'AMBIANCE,SERVICE', 2.5

-- === DELIVERY-SPECIFIC REVIEWS ===
UNION ALL SELECT 36, 'DELIVERY_POSITIVE', 'POSITIVE', 0.65,
  'DoorDash order arrived in 20 minutes and everything was still hot. Packaging was solid. Shake Shack has figured out the delivery game better than most.', 'DELIVERY,FOOD_QUALITY', 4.5
UNION ALL SELECT 37, 'DELIVERY_POSITIVE', 'POSITIVE', 0.60,
  'Love that I can order Shake Shack on UberEats now. The packaging keeps the fries crispy and the burgers are wrapped tight. Almost as good as dining in.', 'DELIVERY,FOOD_QUALITY', 4.0
UNION ALL SELECT 38, 'DELIVERY_NEGATIVE', 'NEGATIVE', -0.55,
  'Delivery prices are absurd. After the delivery fee and service charge the same meal costs $15 more than picking it up. The convenience is not worth that markup.', 'DELIVERY,VALUE', 2.5
UNION ALL SELECT 39, 'DELIVERY_NEGATIVE', 'NEGATIVE', -0.62,
  'The shake was completely melted by the time it arrived via GrubHub. That is $8 for a cup of chocolate milk. Shakes and delivery just do not mix.', 'DELIVERY,FOOD_QUALITY', 2.0

-- === SOCIAL MEDIA STYLE (shorter, more casual - for Instagram/TikTok/Twitter) ===
UNION ALL SELECT 40, 'SOCIAL_POSITIVE', 'POSITIVE', 0.88,
  'the {LTO_ITEM} from shake shack is INSANE. i literally cannot stop thinking about it. going back tomorrow no question', 'FOOD_QUALITY,LTO', NULL
UNION ALL SELECT 41, 'SOCIAL_POSITIVE', 'POSITIVE', 0.82,
  'ok the {LTO_ITEM} hype is REAL. just had it and im shook. shake shack did not have to go this hard', 'FOOD_QUALITY,LTO', NULL
UNION ALL SELECT 42, 'SOCIAL_POSITIVE', 'POSITIVE', 0.75,
  'POV: you finally try the {LTO_ITEM} and realize everything people said was true. absolute game changer', 'FOOD_QUALITY,LTO', NULL
UNION ALL SELECT 43, 'SOCIAL_NEGATIVE', 'NEGATIVE', -0.50,
  'ngl the {LTO_ITEM} was mid af. literally just a regular burger with extra steps. save your money', 'FOOD_QUALITY,LTO,VALUE', NULL
UNION ALL SELECT 44, 'SOCIAL_NEGATIVE', 'NEGATIVE', -0.55,
  'tried the {LTO_ITEM} everyone keeps posting about. its giving... mediocre. the shackburger is still the GOAT', 'FOOD_QUALITY,LTO', NULL
UNION ALL SELECT 45, 'SOCIAL_GENERAL', 'POSITIVE', 0.70,
  'shake shack crinkle fries hit different at 11pm. no notes', 'FOOD_QUALITY', NULL
UNION ALL SELECT 46, 'SOCIAL_GENERAL', 'POSITIVE', 0.78,
  'date night at shake shack >> fancy restaurant. we are simple people and the shackburger is perfection', 'FOOD_QUALITY,AMBIANCE', NULL
UNION ALL SELECT 47, 'SOCIAL_GENERAL', 'NEGATIVE', -0.40,
  'shake shack prices are getting scary ngl. $18 for a burger meal??? in this economy???', 'VALUE', NULL
UNION ALL SELECT 48, 'SOCIAL_GENERAL', 'POSITIVE', 0.65,
  'the frozen custard at shake shack is so underrated. better than most actual ice cream shops imo', 'FOOD_QUALITY', NULL

-- === REPEAT-VISIT INTENT (strong signal for LTO scaling decisions) ===
UNION ALL SELECT 49, 'LTO_REPEAT_INTENT', 'POSITIVE', 0.90,
  'I have had the {LTO_ITEM} four times now and it gets better every time. I am genuinely worried about what I will do when they take it off the menu. Shake Shack PLEASE make this permanent.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 50, 'LTO_REPEAT_INTENT', 'POSITIVE', 0.87,
  'Brought three different friend groups to try the {LTO_ITEM} this month. Everyone was blown away. This is the kind of item that creates new Shake Shack fans.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 51, 'LTO_REPEAT_INTENT', 'POSITIVE', 0.83,
  'Week 3 of ordering the {LTO_ITEM} every time I go to Shake Shack. My usual ShackBurger order has been completely abandoned. That is how good this is.', 'FOOD_QUALITY,LTO', 5.0
UNION ALL SELECT 52, 'LTO_REPEAT_INTENT', 'POSITIVE', 0.78,
  'I was not going to come to Shake Shack today but I saw the {LTO_ITEM} is still available and made a detour. Incremental visit driven entirely by this item.', 'FOOD_QUALITY,LTO', 4.5
;

-- Step 2: Create the LTO-to-review mapping with appropriate sentiment alignment
CREATE OR REPLACE TEMPORARY TABLE _LTO_REVIEW_MAPPING AS
SELECT
    c.LTO_ID,
    c.CAMPAIGN_NAME,
    m.ITEM_NAME AS LTO_ITEM_NAME,
    c.LAUNCH_DATE,
    c.END_DATE,
    c.LAUNCH_REGION,
    c.OUTCOME,
    c.SOCIAL_SENTIMENT_SCORE,
    CASE
        WHEN c.SOCIAL_SENTIMENT_SCORE >= 0.80 THEN 'HIGH_POSITIVE'
        WHEN c.SOCIAL_SENTIMENT_SCORE >= 0.65 THEN 'MODERATE_POSITIVE'
        WHEN c.SOCIAL_SENTIMENT_SCORE >= 0.50 THEN 'MIXED'
        ELSE 'NEGATIVE'
    END AS SENTIMENT_BUCKET
FROM DEMO_DB.SHAKE_SHACK.MKT_LTO_CAMPAIGNS c
JOIN DEMO_DB.SHAKE_SHACK.MKT_MENU_ITEMS m ON c.MENU_ITEM_ID = m.MENU_ITEM_ID;

-- Step 3: Generate the reviews
-- We use a cross-join + filtering approach to generate ~8,000 reviews
INSERT INTO DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS

WITH location_pool AS (
    SELECT LOCATION_ID, MARKET AS LOCATION_MARKET
    FROM DEMO_DB.SHAKE_SHACK.MKT_LOCATIONS
    WHERE COUNTRY = 'US'
),

-- Generate sequence numbers for row creation
seq AS (
    SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) AS rn
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
),

-- Platform distribution weights
platforms AS (
    SELECT 'GOOGLE' AS platform, 1 AS p_start, 3000 AS p_end UNION ALL
    SELECT 'YELP', 3001, 5500 UNION ALL
    SELECT 'DOORDASH', 5501, 6700 UNION ALL
    SELECT 'UBEREATS', 6701, 7500 UNION ALL
    SELECT 'TRIPADVISOR', 7501, 8300 UNION ALL
    SELECT 'INSTAGRAM', 8301, 8800 UNION ALL
    SELECT 'TIKTOK', 8801, 9300 UNION ALL
    SELECT 'TWITTER', 9301, 10000
),

-- === LTO-specific reviews (~3,500 reviews) ===
lto_reviews AS (
    SELECT
        UUID_STRING() AS REVIEW_ID,
        lp.LOCATION_ID,
        p.platform AS PLATFORM,
        DATEADD('day',
            MOD(ABS(HASH(s.rn, lm.LTO_ID)), GREATEST(DATEDIFF('day', lm.LAUNCH_DATE, COALESCE(lm.END_DATE, '2026-04-20')), 1)),
            lm.LAUNCH_DATE
        ) AS REVIEW_DATE,
        CASE
            WHEN p.platform IN ('INSTAGRAM','TIKTOK','TWITTER') THEN NULL
            ELSE t.rating
        END AS RATING,
        REPLACE(t.review_text, '{LTO_ITEM}', lm.LTO_ITEM_NAME) AS REVIEW_TEXT,
        lm.LTO_ITEM_NAME AS MENU_ITEMS_MENTIONED,
        lm.LTO_ITEM_NAME AS LTO_ITEM_REFERENCED,
        t.sentiment_label AS SENTIMENT_LABEL,
        t.sentiment_score AS SENTIMENT_SCORE,
        t.topics AS TOPICS,
        lp.LOCATION_MARKET,
        TRUE AS IS_LTO_REVIEW,
        ROW_NUMBER() OVER (ORDER BY HASH(s.rn, lm.LTO_ID, t.template_id)) AS row_num
    FROM seq s
    CROSS JOIN _LTO_REVIEW_MAPPING lm
    CROSS JOIN _REVIEW_TEMPLATES t
    CROSS JOIN location_pool lp
    CROSS JOIN platforms p
    WHERE
        -- Match sentiment bucket to review template type
        (
            (lm.SENTIMENT_BUCKET = 'HIGH_POSITIVE' AND t.template_type IN ('LTO_POSITIVE','LTO_REPEAT_INTENT','SOCIAL_POSITIVE') AND MOD(ABS(HASH(s.rn, t.template_id)), 100) < 8)
            OR (lm.SENTIMENT_BUCKET = 'MODERATE_POSITIVE' AND t.template_type IN ('LTO_POSITIVE','LTO_MIXED','SOCIAL_POSITIVE') AND MOD(ABS(HASH(s.rn, t.template_id)), 100) < 5)
            OR (lm.SENTIMENT_BUCKET = 'MIXED' AND t.template_type IN ('LTO_MIXED','LTO_NEGATIVE','LTO_POSITIVE') AND MOD(ABS(HASH(s.rn, t.template_id)), 100) < 4)
            OR (lm.SENTIMENT_BUCKET = 'NEGATIVE' AND t.template_type IN ('LTO_NEGATIVE','LTO_MIXED','SOCIAL_NEGATIVE') AND MOD(ABS(HASH(s.rn, t.template_id)), 100) < 6)
        )
        -- Only NA LTOs reviewed on US locations
        AND (lm.LAUNCH_REGION = 'NORTH_AMERICA')
        -- Platform assignment based on hash
        AND MOD(ABS(HASH(s.rn, lm.LTO_ID, lp.LOCATION_ID)), 10000) BETWEEN p.p_start AND p.p_end
        -- Social platforms use social templates, review platforms use review templates
        AND (
            (p.platform IN ('INSTAGRAM','TIKTOK','TWITTER') AND t.template_type LIKE 'SOCIAL%')
            OR (p.platform NOT IN ('INSTAGRAM','TIKTOK','TWITTER') AND t.template_type NOT LIKE 'SOCIAL%')
        )
),

-- Cap LTO reviews at ~3,500
lto_reviews_capped AS (
    SELECT * FROM lto_reviews WHERE row_num <= 3500
),

-- === General reviews (~4,500 reviews) ===
general_reviews AS (
    SELECT
        UUID_STRING() AS REVIEW_ID,
        lp.LOCATION_ID,
        p.platform AS PLATFORM,
        DATEADD('day', MOD(ABS(HASH(s.rn, lp.LOCATION_ID)), 480), '2025-01-01') AS REVIEW_DATE,
        CASE
            WHEN p.platform IN ('INSTAGRAM','TIKTOK','TWITTER') THEN NULL
            ELSE t.rating
        END AS RATING,
        t.review_text AS REVIEW_TEXT,
        CASE
            WHEN t.template_type LIKE '%POSITIVE%' AND MOD(ABS(HASH(s.rn)), 3) = 0 THEN 'ShackBurger'
            WHEN t.template_type LIKE '%POSITIVE%' AND MOD(ABS(HASH(s.rn)), 3) = 1 THEN 'SmokeShack'
            WHEN t.template_type LIKE '%POSITIVE%' THEN 'Crinkle Cut Fries'
            WHEN t.template_type LIKE 'DELIVERY%' THEN 'ShackBurger, Fries'
            ELSE NULL
        END AS MENU_ITEMS_MENTIONED,
        NULL AS LTO_ITEM_REFERENCED,
        t.sentiment_label AS SENTIMENT_LABEL,
        t.sentiment_score AS SENTIMENT_SCORE,
        t.topics AS TOPICS,
        lp.LOCATION_MARKET,
        FALSE AS IS_LTO_REVIEW,
        ROW_NUMBER() OVER (ORDER BY HASH(s.rn, lp.LOCATION_ID, t.template_id)) AS row_num
    FROM seq s
    CROSS JOIN _REVIEW_TEMPLATES t
    CROSS JOIN location_pool lp
    CROSS JOIN platforms p
    WHERE
        t.template_type IN ('GENERAL_POSITIVE','GENERAL_NEGATIVE','DELIVERY_POSITIVE','DELIVERY_NEGATIVE','SOCIAL_GENERAL')
        AND MOD(ABS(HASH(s.rn, t.template_id, lp.LOCATION_ID)), 10000) BETWEEN p.p_start AND p.p_end
        AND MOD(ABS(HASH(s.rn, lp.LOCATION_ID)), 100) < 3
        -- Delivery reviews only on delivery platforms
        AND (
            (t.template_type LIKE 'DELIVERY%' AND p.platform IN ('DOORDASH','UBEREATS'))
            OR (t.template_type LIKE 'SOCIAL%' AND p.platform IN ('INSTAGRAM','TIKTOK','TWITTER'))
            OR (t.template_type LIKE 'GENERAL%' AND p.platform IN ('GOOGLE','YELP','TRIPADVISOR'))
        )
),

-- Cap general reviews at ~4,500
general_reviews_capped AS (
    SELECT * FROM general_reviews WHERE row_num <= 4500
),

-- Combine all reviews
all_reviews AS (
    SELECT REVIEW_ID, LOCATION_ID, PLATFORM, REVIEW_DATE, RATING, REVIEW_TEXT,
           MENU_ITEMS_MENTIONED, LTO_ITEM_REFERENCED, SENTIMENT_LABEL, SENTIMENT_SCORE,
           TOPICS, LOCATION_MARKET, IS_LTO_REVIEW
    FROM lto_reviews_capped
    UNION ALL
    SELECT REVIEW_ID, LOCATION_ID, PLATFORM, REVIEW_DATE, RATING, REVIEW_TEXT,
           MENU_ITEMS_MENTIONED, LTO_ITEM_REFERENCED, SENTIMENT_LABEL, SENTIMENT_SCORE,
           TOPICS, LOCATION_MARKET, IS_LTO_REVIEW
    FROM general_reviews_capped
)

SELECT * FROM all_reviews;

-- Cleanup temp tables
DROP TABLE IF EXISTS _REVIEW_TEMPLATES;
DROP TABLE IF EXISTS _LTO_REVIEW_MAPPING;

----------------------------------------------------------------------
-- 3. VERIFY
----------------------------------------------------------------------
SELECT COUNT(*) AS total_reviews FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS;
SELECT PLATFORM, COUNT(*) AS cnt, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS), 1) AS pct
FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS GROUP BY PLATFORM ORDER BY cnt DESC;
SELECT IS_LTO_REVIEW, COUNT(*) AS cnt FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS GROUP BY IS_LTO_REVIEW;
SELECT SENTIMENT_LABEL, COUNT(*) AS cnt FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS GROUP BY SENTIMENT_LABEL ORDER BY cnt DESC;
SELECT LTO_ITEM_REFERENCED, COUNT(*) AS cnt
FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS
WHERE IS_LTO_REVIEW = TRUE
GROUP BY LTO_ITEM_REFERENCED ORDER BY cnt DESC LIMIT 15;
