----------------------------------------------------------------------
-- Shake Shack Marketing Intelligence Agent
-- Task: Add App Store (iOS/Google Play) and Qualtrics reviews
-- Adds ~1,772 reviews covering digital UX friction, offer fatigue,
-- brand loyalty, competitor comparisons, and reward program feedback
-- Created: 2026-04-20
----------------------------------------------------------------------

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ADMIN_WH;
USE DATABASE DEMO_DB;
USE SCHEMA SHAKE_SHACK;

----------------------------------------------------------------------
-- 1. INSERT APP STORE + QUALTRICS REVIEWS
----------------------------------------------------------------------

INSERT INTO DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS

WITH review_templates AS (
  -- APP_STORE_IOS / GOOGLE_PLAY: Digital UX friction
  SELECT 1 AS tid, 'APP_UX' AS topic_group, 'NEGATIVE' AS sentiment_label, -0.72 AS sentiment_score,
    'App crashes every time I try to customize my order. I have reinstalled twice and still get the spinning wheel at checkout. Fix your app before pushing more promos.' AS review_text, 'APP_UX,CHECKOUT_FRICTION' AS topics, 1.5 AS rating
  UNION ALL SELECT 2, 'APP_UX', 'NEGATIVE', -0.65,
    'The checkout flow takes way too many taps. By the time I get through customization, payment, and pickup time selection, I could have just walked in and ordered at the counter.', 'APP_UX,CHECKOUT_FRICTION', 2.0
  UNION ALL SELECT 3, 'APP_UX', 'NEGATIVE', -0.58,
    'Got logged out mid-order AGAIN. Lost my entire cart including the 1-3-5 promo items. This has happened three times this month. Extremely frustrating.', 'APP_UX,CHECKOUT_FRICTION', 2.0
  UNION ALL SELECT 4, 'APP_UX', 'NEGATIVE', -0.70,
    'The app is painfully slow on my Android phone. Pages take 5-6 seconds to load. The promotion loaded but the menu items would not. Gave up and ordered at the drive-thru instead.', 'APP_UX,CHECKOUT_FRICTION', 1.5
  UNION ALL SELECT 5, 'APP_UX', 'MIXED', 0.10,
    'Love the menu and the 1-3-5 deal but the app experience needs serious work. Crashes on payment, slow load times, and the location finder never works right. Food is great when I can actually complete an order.', 'APP_UX,CHECKOUT_FRICTION', 3.0

  -- APP_STORE: Push notification fatigue
  UNION ALL SELECT 6, 'PUSH_NOTIFICATIONS', 'NEGATIVE', -0.62,
    'I get push notifications from Shake Shack literally every single day. Multiple times a day sometimes. I turned them off and now I miss actual order updates. There needs to be a middle ground.', 'PUSH_NOTIFICATIONS,OFFER_FATIGUE', 2.0
  UNION ALL SELECT 7, 'PUSH_NOTIFICATIONS', 'NEGATIVE', -0.55,
    'The notification spam is out of control. I do not need to know about every new LTO at 7am. I signed up for order tracking not a marketing bombardment.', 'PUSH_NOTIFICATIONS,OFFER_FATIGUE', 2.5
  UNION ALL SELECT 8, 'PUSH_NOTIFICATIONS', 'NEGATIVE', -0.48,
    'Turned off push notifications because they were too aggressive. But then I did not know the 1-3-5 promo was back. Shake Shack needs to let me choose what notifications I get.', 'PUSH_NOTIFICATIONS,OFFER_FATIGUE', 3.0

  -- APP_STORE: Offer fatigue / one-and-done
  UNION ALL SELECT 9, 'OFFER_FATIGUE', 'NEGATIVE', -0.55,
    'Downloaded the app for the 1-3-5 promo, used it once, and have no reason to come back. There is no loyalty program, no points, no reason to keep the app installed. Deleted.', 'OFFER_FATIGUE', 2.0
  UNION ALL SELECT 10, 'OFFER_FATIGUE', 'NEGATIVE', -0.60,
    'The promo got me in the door but there is nothing to keep me coming back. No rewards, no punch card, nothing. One and done. Other burger apps at least have points systems.', 'OFFER_FATIGUE', 2.0
  UNION ALL SELECT 11, 'OFFER_FATIGUE', 'NEGATIVE', -0.50,
    'Used the 1-3-5 deal and it was fine. But without ongoing rewards or a loyalty program I will just go wherever has the best deal that week. Shake Shack needs to give me a reason to stay.', 'OFFER_FATIGUE', 2.5
  UNION ALL SELECT 12, 'OFFER_FATIGUE', 'MIXED', 0.05,
    'Good food, solid promo, but the app offers no value after the first visit. Compare this to Starbucks or Chick-fil-A where every purchase earns something. Shake Shack is leaving money on the table.', 'OFFER_FATIGUE,COMPETITOR_COMPARISON', 3.0

  -- QUALTRICS: Brand loyalty drivers
  UNION ALL SELECT 13, 'BRAND_LOYALTY', 'POSITIVE', 0.85,
    'What keeps me coming back is the ingredient quality. You can taste that the beef is better than Five Guys or Smashburger. The produce is always fresh. I trust Shake Shack to use premium ingredients.', 'BRAND_LOYALTY,COMPETITOR_COMPARISON', 5.0
  UNION ALL SELECT 14, 'BRAND_LOYALTY', 'POSITIVE', 0.80,
    'Shake Shack is my go-to because the experience is consistent. Every location I have visited - New York, Chicago, the new drive-thru in Naperville - the quality is the same. That reliability matters.', 'BRAND_LOYALTY', 4.5
  UNION ALL SELECT 15, 'BRAND_LOYALTY', 'POSITIVE', 0.78,
    'I choose Shake Shack over In-N-Out because the menu has more variety and the shakes are in a different league. Plus the brand feels more transparent about sourcing and sustainability.', 'BRAND_LOYALTY,COMPETITOR_COMPARISON', 4.5
  UNION ALL SELECT 16, 'BRAND_LOYALTY', 'POSITIVE', 0.82,
    'The combination of food quality, clean restaurants, and friendly staff is why I drive past Chipotle and Five Guys to get to Shake Shack. Worth the premium every time.', 'BRAND_LOYALTY,COMPETITOR_COMPARISON', 5.0
  UNION ALL SELECT 17, 'BRAND_LOYALTY', 'POSITIVE', 0.75,
    'Honestly, the frozen custard is what keeps me loyal. No one else in the fast casual space does desserts this well. The seasonal flavors are always creative and delicious.', 'BRAND_LOYALTY,FOOD_QUALITY', 4.5

  -- QUALTRICS: Competitor comparisons
  UNION ALL SELECT 18, 'COMPETITOR', 'POSITIVE', 0.70,
    'Shake Shack vs Five Guys: Shake Shack wins on atmosphere, shakes, and crinkle fries. Five Guys wins on portion size. But overall I prefer the Shake Shack experience - it feels more premium.', 'COMPETITOR_COMPARISON,BRAND_LOYALTY', 4.0
  UNION ALL SELECT 19, 'COMPETITOR', 'MIXED', 0.15,
    'I go to Chick-fil-A for their rewards program and speed. I go to Shake Shack for burger quality. If Shake Shack had Chick-fil-A level loyalty rewards I would switch completely.', 'COMPETITOR_COMPARISON,REWARD_PROGRAM', 3.5
  UNION ALL SELECT 20, 'COMPETITOR', 'POSITIVE', 0.72,
    'Compared to Sweetgreen and Panera, Shake Shack is a better value for the quality. Yes it costs more than McDonalds but the gap in quality is enormous. Premium fast casual done right.', 'COMPETITOR_COMPARISON,VALUE', 4.5

  -- QUALTRICS: Reward program preferences
  UNION ALL SELECT 21, 'REWARD_PROGRAM', 'POSITIVE', 0.68,
    'I would love a 3-tier loyalty program. Something like: Shack Fan (basic perks), Shack Regular (free upgrades), and Shack Insider (early LTO access, birthday rewards). I would absolutely engage with that.', 'REWARD_PROGRAM,LIFETIME_VALUE', 4.0
  UNION ALL SELECT 22, 'REWARD_PROGRAM', 'POSITIVE', 0.72,
    'Please build a loyalty program. I spend $50-60/week at Shake Shack and get nothing for it. Even a simple points-per-dollar system would make me feel valued as a frequent guest.', 'REWARD_PROGRAM,LIFETIME_VALUE', 4.0
  UNION ALL SELECT 23, 'REWARD_PROGRAM', 'POSITIVE', 0.65,
    'The one thing missing from Shake Shack is a proper rewards program. I want early access to LTOs, birthday freebies, and maybe a free shake after every 10 visits. Starbucks has shown this works.', 'REWARD_PROGRAM,COMPETITOR_COMPARISON', 4.0
  UNION ALL SELECT 24, 'REWARD_PROGRAM', 'POSITIVE', 0.80,
    'If Shake Shack launched a tiered loyalty program I would go from 2x/month to weekly easily. Give me points, give me exclusive menu previews, and I am locked in for life.', 'REWARD_PROGRAM,LIFETIME_VALUE', 4.5
  UNION ALL SELECT 25, 'REWARD_PROGRAM', 'MIXED', 0.20,
    'I have been coming to Shake Shack for 3 years and spend over $2000/year. There is zero recognition. Meanwhile Chick-fil-A sends me free food after every 5th visit. Where is the loyalty?', 'REWARD_PROGRAM,COMPETITOR_COMPARISON,LIFETIME_VALUE', 3.0

  -- QUALTRICS: Additional brand / value
  UNION ALL SELECT 26, 'BRAND_VALUE', 'POSITIVE', 0.76,
    'Shake Shack understands premium fast casual. The sourcing transparency, the seasonal LTOs, the clean restaurant design - it all adds up to an experience worth paying for.', 'BRAND_LOYALTY,VALUE', 4.5
  UNION ALL SELECT 27, 'BRAND_VALUE', 'MIXED', 0.30,
    'Great food but the prices keep going up. A burger, fries and shake is pushing $25. I still come but I have cut back from weekly to twice a month. A loyalty discount would bring me back more often.', 'VALUE,REWARD_PROGRAM', 3.5
  UNION ALL SELECT 28, 'BRAND_VALUE', 'POSITIVE', 0.83,
    'I trust Shake Shack more than any other fast casual brand. Antibiotic-free beef, real sugar in the sodas, and they actually care about the community. That is why I pay the premium.', 'BRAND_LOYALTY', 5.0
),

location_pool AS (
    SELECT LOCATION_ID, MARKET AS LOCATION_MARKET
    FROM DEMO_DB.SHAKE_SHACK.MKT_LOCATIONS
    WHERE COUNTRY = 'US'
),

seq AS (
    SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) AS rn
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
),

platform_assign AS (
    SELECT 'APP_STORE_IOS' AS platform, 1 AS p_start, 4000 AS p_end UNION ALL
    SELECT 'GOOGLE_PLAY', 4001, 7000 UNION ALL
    SELECT 'QUALTRICS', 7001, 10000
),

generated AS (
    SELECT
        UUID_STRING() AS REVIEW_ID,
        lp.LOCATION_ID,
        pa.platform AS PLATFORM,
        DATEADD('day', MOD(ABS(HASH(s.rn, t.tid, lp.LOCATION_ID)), 90), '2025-10-01') AS REVIEW_DATE,
        t.rating AS RATING,
        t.review_text AS REVIEW_TEXT,
        NULL AS MENU_ITEMS_MENTIONED,
        NULL AS LTO_ITEM_REFERENCED,
        t.sentiment_label AS SENTIMENT_LABEL,
        t.sentiment_score AS SENTIMENT_SCORE,
        t.topics AS TOPICS,
        lp.LOCATION_MARKET,
        FALSE AS IS_LTO_REVIEW,
        ROW_NUMBER() OVER (ORDER BY HASH(s.rn, t.tid, lp.LOCATION_ID)) AS row_num
    FROM seq s
    CROSS JOIN review_templates t
    CROSS JOIN location_pool lp
    CROSS JOIN platform_assign pa
    WHERE
        MOD(ABS(HASH(s.rn, t.tid, lp.LOCATION_ID)), 10000) BETWEEN pa.p_start AND pa.p_end
        AND MOD(ABS(HASH(s.rn, lp.LOCATION_ID)), 100) < 3
        AND (
            (t.topic_group IN ('APP_UX','PUSH_NOTIFICATIONS','OFFER_FATIGUE') AND pa.platform IN ('APP_STORE_IOS','GOOGLE_PLAY'))
            OR (t.topic_group IN ('BRAND_LOYALTY','COMPETITOR','REWARD_PROGRAM','BRAND_VALUE') AND pa.platform = 'QUALTRICS')
        )
)

SELECT REVIEW_ID, LOCATION_ID, PLATFORM, REVIEW_DATE, RATING, REVIEW_TEXT,
       MENU_ITEMS_MENTIONED, LTO_ITEM_REFERENCED, SENTIMENT_LABEL, SENTIMENT_SCORE,
       TOPICS, LOCATION_MARKET, IS_LTO_REVIEW
FROM generated
WHERE row_num <= 1800;

----------------------------------------------------------------------
-- 2. VERIFY
----------------------------------------------------------------------
SELECT PLATFORM, COUNT(*) AS cnt
FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS
WHERE PLATFORM IN ('APP_STORE_IOS','GOOGLE_PLAY','QUALTRICS')
GROUP BY PLATFORM ORDER BY cnt DESC;

SELECT TOPICS, COUNT(*) AS cnt
FROM DEMO_DB.SHAKE_SHACK.MKT_GUEST_REVIEWS
WHERE PLATFORM IN ('APP_STORE_IOS','GOOGLE_PLAY','QUALTRICS')
GROUP BY TOPICS ORDER BY cnt DESC LIMIT 15;
