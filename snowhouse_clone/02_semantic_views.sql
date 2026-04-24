USE ROLE SALES_ENGINEER;
USE WAREHOUSE SE_WH;
USE SCHEMA TEMP.EESCOBAR;

--SVIEW:MKT_CUSTOMER_INTELLIGENCE_VIEW
create or replace semantic view MKT_CUSTOMER_INTELLIGENCE_VIEW
	tables (
		CUSTOMER_INTELLIGENCE as TEMP.EESCOBAR.MKT_CUSTOMER_INTELLIGENCE_MART primary key (GUEST_ID) comment='Pre-joined customer intelligence mart with guest demographics, RFM scores, CLV tiers, behavioral segments, and transaction aggregates.'
	)
	facts (
		CUSTOMER_INTELLIGENCE.TOTAL_VISITS as TOTAL_VISITS comment='Total visits by guest',
		CUSTOMER_INTELLIGENCE.AVG_ORDER_VALUE as AVG_ORDER_VALUE comment='Average order value',
		CUSTOMER_INTELLIGENCE.LIFETIME_VALUE as LIFETIME_VALUE comment='Total lifetime value',
		CUSTOMER_INTELLIGENCE.DAYS_SINCE_LAST_VISIT as DAYS_SINCE_LAST_VISIT comment='Days since last visit',
		CUSTOMER_INTELLIGENCE.APP_USAGE_SCORE as APP_USAGE_SCORE comment='App engagement score 0-99',
		CUSTOMER_INTELLIGENCE.PROMO_RESPONSE_RATE as PROMO_RESPONSE_RATE comment='Promo response rate 0-99',
		CUSTOMER_INTELLIGENCE.NPS_SCORE as NPS_SCORE comment='Net promoter score -100 to 100',
		CUSTOMER_INTELLIGENCE.RECENCY_SCORE as RECENCY_SCORE comment='RFM recency score 1-5',
		CUSTOMER_INTELLIGENCE.FREQUENCY_SCORE as FREQUENCY_SCORE comment='RFM frequency score 1-5',
		CUSTOMER_INTELLIGENCE.MONETARY_SCORE as MONETARY_SCORE comment='RFM monetary score 1-5',
		CUSTOMER_INTELLIGENCE.CHURN_RISK_SCORE as CHURN_RISK_SCORE comment='Churn risk score 0-100',
		CUSTOMER_INTELLIGENCE.PREDICTED_CLV as PREDICTED_CLV comment='Predicted next-12-month CLV in dollars',
		CUSTOMER_INTELLIGENCE.LOYALTY_PROPENSITY_SCORE as LOYALTY_PROPENSITY_SCORE comment='Loyalty enrollment propensity 0-100',
		CUSTOMER_INTELLIGENCE.LOYALTY_POINTS_BALANCE as LOYALTY_POINTS_BALANCE comment='Current loyalty points',
		CUSTOMER_INTELLIGENCE.TXN_COUNT as TXN_COUNT comment='Total recorded transactions',
		CUSTOMER_INTELLIGENCE.TOTAL_REVENUE as TOTAL_REVENUE comment='Total gross revenue',
		CUSTOMER_INTELLIGENCE.TOTAL_NET_REVENUE as TOTAL_NET_REVENUE comment='Total net revenue',
		CUSTOMER_INTELLIGENCE.VISITS_LAST_30D as VISITS_LAST_30D comment='Visits in last 30 days',
		CUSTOMER_INTELLIGENCE.VISITS_LAST_60D as VISITS_LAST_60D comment='Visits in last 60 days',
		CUSTOMER_INTELLIGENCE.VISITS_LAST_90D as VISITS_LAST_90D comment='Visits in last 90 days',
		CUSTOMER_INTELLIGENCE.VISITS_LAST_180D as VISITS_LAST_180D comment='Visits in last 180 days',
		CUSTOMER_INTELLIGENCE.VISITS_LAST_365D as VISITS_LAST_365D comment='Visits in last 365 days',
		CUSTOMER_INTELLIGENCE.DELIVERY_ORDER_COUNT as DELIVERY_ORDER_COUNT comment='Third-party delivery orders',
		CUSTOMER_INTELLIGENCE.APP_ORDER_COUNT as APP_ORDER_COUNT comment='App orders',
		CUSTOMER_INTELLIGENCE.DELIVERY_PCT as DELIVERY_PCT comment='Delivery order percentage',
		CUSTOMER_INTELLIGENCE.APP_PCT as APP_PCT comment='App order percentage'
	)
	dimensions (
		CUSTOMER_INTELLIGENCE.GUEST_ID as GUEST_ID comment='Unique guest identifier',
		CUSTOMER_INTELLIGENCE.FIRST_NAME as FIRST_NAME comment='Guest first name',
		CUSTOMER_INTELLIGENCE.ACQUISITION_CHANNEL as ACQUISITION_CHANNEL comment='Channel through which the guest was first acquired',
		CUSTOMER_INTELLIGENCE.FAVORITE_CATEGORY as FAVORITE_CATEGORY comment='Most purchased menu category',
		CUSTOMER_INTELLIGENCE.PREFERRED_CHANNEL as PREFERRED_CHANNEL comment='Preferred ordering channel',
		CUSTOMER_INTELLIGENCE.PREFERRED_DAYPART as PREFERRED_DAYPART comment='Preferred daypart',
		CUSTOMER_INTELLIGENCE.RFM_SEGMENT as RFM_SEGMENT comment='RFM-based customer segment',
		CUSTOMER_INTELLIGENCE.CLV_TIER as CLV_TIER comment='Customer lifetime value tier',
		CUSTOMER_INTELLIGENCE.BEHAVIORAL_SEGMENT as BEHAVIORAL_SEGMENT comment='Behavioral customer segment',
		CUSTOMER_INTELLIGENCE.LOYALTY_ENROLLED as LOYALTY_ENROLLED comment='Whether guest is enrolled in loyalty program',
		CUSTOMER_INTELLIGENCE.LOYALTY_TIER as LOYALTY_TIER comment='Loyalty program tier',
		CUSTOMER_INTELLIGENCE.AGE_GROUP as AGE_GROUP comment='Guest age group',
		CUSTOMER_INTELLIGENCE.HOME_MARKET as HOME_MARKET comment='Guest home market',
		CUSTOMER_INTELLIGENCE.SIGNUP_COHORT as SIGNUP_COHORT comment='Year-quarter signup cohort',
		CUSTOMER_INTELLIGENCE.LOCATION_REGION as LOCATION_REGION comment='Region of home location',
		CUSTOMER_INTELLIGENCE.HOME_IS_NEW_MARKET as HOME_IS_NEW_MARKET comment='Whether home location is in a new market',
		CUSTOMER_INTELLIGENCE.HOME_LOCATION_FORMAT as HOME_LOCATION_FORMAT comment='Format of home location',
		CUSTOMER_INTELLIGENCE.ACQUISITION_DATE as ACQUISITION_DATE comment='Date guest was first acquired',
		CUSTOMER_INTELLIGENCE.LAST_VISIT_DATE as LAST_VISIT_DATE comment='Date of most recent visit'
	)
	metrics (
		CUSTOMER_INTELLIGENCE.TOTAL_GUESTS as COUNT(DISTINCT GUEST_ID) comment='Total unique guests',
		CUSTOMER_INTELLIGENCE.AVG_LIFETIME_VALUE as AVG(LIFETIME_VALUE) comment='Average lifetime value',
		CUSTOMER_INTELLIGENCE.AVG_PREDICTED_CLV as AVG(PREDICTED_CLV) comment='Average predicted CLV',
		CUSTOMER_INTELLIGENCE.AVG_CHURN_RISK as AVG(CHURN_RISK_SCORE) comment='Average churn risk',
		CUSTOMER_INTELLIGENCE.LOYALTY_ENROLLMENT_RATE as AVG(CASE WHEN LOYALTY_ENROLLED THEN 1.0 ELSE 0.0 END) * 100 comment='Loyalty enrollment percentage'
	)
	comment='Customer intelligence semantic view for Shake Shack Marketing Agent. Answers questions about loyalty segmentation, churn cohorts, customer lifetime value, RFM analysis, acquisition channels, and win-back opportunities across 50K guest profiles.'
	with extension (CA='{"tables":[{"name":"CUSTOMER_INTELLIGENCE","dimensions":[{"name":"guest_id"},{"name":"first_name"},{"name":"acquisition_channel","sample_values":["APP","IN_STORE","WEB","UBER_EATS","DOORDASH","GRUBHUB","KIOSK"]},{"name":"favorite_category","sample_values":["BURGERS","CHICKEN","SHAKES","FRIES","DRINKS"]},{"name":"preferred_channel","sample_values":["APP","IN_STORE","KIOSK","UBER_EATS","DOORDASH","GRUBHUB","WEB"]},{"name":"preferred_daypart","sample_values":["LUNCH","DINNER","AFTERNOON","BREAKFAST","LATE_NIGHT"]},{"name":"rfm_segment","sample_values":["Champions","Loyal Customers","New Customers","Potential Loyalists","At Risk","Hibernating","About to Sleep","Lost"]},{"name":"clv_tier","sample_values":["PLATINUM","GOLD","SILVER","BRONZE"]},{"name":"behavioral_segment","sample_values":["High-Value Delivery Dependent","Digital Power User","Lapsed Loyalist","Super Fan","Casual Visitor"]},{"name":"loyalty_enrolled"},{"name":"loyalty_tier","sample_values":["PLATINUM","GOLD","SILVER"]},{"name":"age_group","sample_values":["18-24","25-34","35-44","45-54","55+"]},{"name":"home_market"},{"name":"signup_cohort"},{"name":"location_region","sample_values":["Northeast","Southeast","Midwest","Southwest","West","International"]},{"name":"home_is_new_market"},{"name":"home_location_format","sample_values":["Traditional","Drive-Thru","Stadium","Airport"]}],"facts":[{"name":"total_visits"},{"name":"avg_order_value"},{"name":"lifetime_value"},{"name":"days_since_last_visit"},{"name":"app_usage_score"},{"name":"promo_response_rate"},{"name":"nps_score"},{"name":"recency_score"},{"name":"frequency_score"},{"name":"monetary_score"},{"name":"churn_risk_score"},{"name":"predicted_clv"},{"name":"loyalty_propensity_score"},{"name":"loyalty_points_balance"},{"name":"txn_count"},{"name":"total_revenue"},{"name":"total_net_revenue"},{"name":"visits_last_30d"},{"name":"visits_last_60d"},{"name":"visits_last_90d"},{"name":"visits_last_180d"},{"name":"visits_last_365d"},{"name":"delivery_order_count"},{"name":"app_order_count"},{"name":"delivery_pct"},{"name":"app_pct"}],"metrics":[{"name":"total_guests"},{"name":"avg_lifetime_value"},{"name":"avg_predicted_clv"},{"name":"avg_churn_risk"},{"name":"loyalty_enrollment_rate"}],"filters":[{"name":"high_value_customers","description":"High-value customers","expr":"CLV_TIER IN (''PLATINUM'', ''GOLD'')"},{"name":"at_risk_customers","description":"High churn risk customers","expr":"CHURN_RISK_SCORE >= 60"},{"name":"champions_filter","description":"Champions segment only","expr":"RFM_SEGMENT = ''Champions''"},{"name":"lapsed_customers","description":"Lapsed customers (60+ days)","expr":"DAYS_SINCE_LAST_VISIT >= 60"}],"time_dimensions":[{"name":"acquisition_date"},{"name":"last_visit_date"}]}],"verified_queries":[{"name":"loyalty_enrollment_priority","sql":"SELECT RFM_SEGMENT, CLV_TIER, COUNT(*) AS guest_count, ROUND(AVG(LOYALTY_PROPENSITY_SCORE), 1) AS avg_propensity, ROUND(AVG(PREDICTED_CLV), 2) AS avg_predicted_clv FROM TEMP.EESCOBAR.MKT_CUSTOMER_INTELLIGENCE_MART WHERE LOYALTY_ENROLLED = FALSE GROUP BY RFM_SEGMENT, CLV_TIER ORDER BY avg_predicted_clv DESC LIMIT 15","question":"Which customer segments should we prioritize for loyalty enrollment?","verified_at":1711500000,"verified_by":"demo"},{"name":"churn_by_channel","sql":"SELECT ACQUISITION_CHANNEL, SIGNUP_COHORT, COUNT(*) AS total_guests, SUM(CASE WHEN DAYS_SINCE_LAST_VISIT >= 60 THEN 1 ELSE 0 END) AS churned_guests, ROUND(SUM(CASE WHEN DAYS_SINCE_LAST_VISIT >= 60 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS churn_rate_pct FROM TEMP.EESCOBAR.MKT_CUSTOMER_INTELLIGENCE_MART GROUP BY ACQUISITION_CHANNEL, SIGNUP_COHORT ORDER BY ACQUISITION_CHANNEL, SIGNUP_COHORT","question":"Show me churn cohorts by acquisition channel","verified_at":1711500000,"verified_by":"demo"},{"name":"lapsed_high_freq","sql":"SELECT RFM_SEGMENT, BEHAVIORAL_SEGMENT, COUNT(*) AS lapsed_high_freq_guests, ROUND(AVG(LIFETIME_VALUE), 2) AS avg_ltv, ROUND(AVG(DAYS_SINCE_LAST_VISIT), 0) AS avg_days_inactive FROM TEMP.EESCOBAR.MKT_CUSTOMER_INTELLIGENCE_MART WHERE VISITS_LAST_365D >= 8 AND DAYS_SINCE_LAST_VISIT >= 60 GROUP BY RFM_SEGMENT, BEHAVIORAL_SEGMENT ORDER BY lapsed_high_freq_guests DESC","question":"How many customers visited 8+ times last year but have not been back in 60 days?","verified_at":1711500000,"verified_by":"demo"},{"name":"champions_frequency_lift","sql":"SELECT RFM_SEGMENT, COUNT(*) AS guest_count, ROUND(AVG(TOTAL_VISITS), 1) AS avg_total_visits, ROUND(AVG(FREQUENCY_SCORE), 2) AS avg_frequency_score, ROUND(AVG(PREDICTED_CLV), 2) AS avg_predicted_clv FROM TEMP.EESCOBAR.MKT_CUSTOMER_INTELLIGENCE_MART GROUP BY RFM_SEGMENT ORDER BY avg_predicted_clv DESC","question":"Which loyalty segments should we prioritize for investment?","verified_at":1711500000,"verified_by":"demo"},{"name":"churn_risk_by_tier","sql":"SELECT RFM_SEGMENT, CLV_TIER, COUNT(*) AS at_risk_guests, ROUND(SUM(PREDICTED_CLV), 2) AS total_clv_at_risk FROM TEMP.EESCOBAR.MKT_CUSTOMER_INTELLIGENCE_MART WHERE CHURN_RISK_SCORE >= 60 GROUP BY RFM_SEGMENT, CLV_TIER ORDER BY total_clv_at_risk DESC","question":"How many guests are at risk of churning?","verified_at":1711500000,"verified_by":"demo"}]}');

--SVIEW:MKT_CHANNEL_FINANCIAL_VIEW
create or replace semantic view MKT_CHANNEL_FINANCIAL_VIEW
	tables (
		CHANNEL_FINANCIAL as TEMP.EESCOBAR.MKT_CHANNEL_FINANCIAL_MART primary key (TRANSACTION_ID) comment='Transaction-level financial data with channel economics, customer segments, and location data.'
	)
	facts (
		CHANNEL_FINANCIAL.ORDER_TOTAL as ORDER_TOTAL comment='Gross order total',
		CHANNEL_FINANCIAL.DISCOUNT_AMOUNT as DISCOUNT_AMOUNT comment='Discount applied',
		CHANNEL_FINANCIAL.DELIVERY_FEE as DELIVERY_FEE comment='Delivery fee',
		CHANNEL_FINANCIAL.PLATFORM_COMMISSION as PLATFORM_COMMISSION comment='Third-party platform commission',
		CHANNEL_FINANCIAL.NET_REVENUE as NET_REVENUE comment='Revenue after discounts and commissions',
		CHANNEL_FINANCIAL.TRUE_NET_REVENUE as TRUE_NET_REVENUE comment='True net revenue after all channel costs',
		CHANNEL_FINANCIAL.ORDER_MARGIN_PCT as ORDER_MARGIN_PCT comment='Order margin percentage',
		CHANNEL_FINANCIAL.ITEM_COUNT as ITEM_COUNT comment='Number of items',
		CHANNEL_FINANCIAL.CHANNEL_COMMISSION_PCT as CHANNEL_COMMISSION_PCT comment='Channel commission rate',
		CHANNEL_FINANCIAL.CHANNEL_CAC as CHANNEL_CAC comment='Customer acquisition cost for channel'
	)
	dimensions (
		CHANNEL_FINANCIAL.TRANSACTION_ID as TRANSACTION_ID comment='Unique transaction identifier',
		CHANNEL_FINANCIAL.GUEST_ID as GUEST_ID comment='Guest identifier',
		CHANNEL_FINANCIAL.ORDER_CHANNEL as ORDER_CHANNEL comment='Ordering channel',
		CHANNEL_FINANCIAL.CHANNEL_GROUP as CHANNEL_GROUP comment='Channel grouping',
		CHANNEL_FINANCIAL.DAYPART as DAYPART comment='Time of day',
		CHANNEL_FINANCIAL.CLV_TIER as CLV_TIER comment='Customer lifetime value tier',
		CHANNEL_FINANCIAL.RFM_SEGMENT as RFM_SEGMENT comment='RFM customer segment',
		CHANNEL_FINANCIAL.BEHAVIORAL_SEGMENT as BEHAVIORAL_SEGMENT comment='Behavioral customer segment',
		CHANNEL_FINANCIAL.ACQUISITION_CHANNEL as ACQUISITION_CHANNEL comment='Original acquisition channel',
		CHANNEL_FINANCIAL.LOYALTY_ENROLLED as LOYALTY_ENROLLED comment='Loyalty enrollment status',
		CHANNEL_FINANCIAL.LOCATION_MARKET as LOCATION_MARKET comment='Market where transaction occurred',
		CHANNEL_FINANCIAL.LOCATION_REGION as LOCATION_REGION comment='Region where transaction occurred',
		CHANNEL_FINANCIAL.IS_NEW_MARKET as IS_NEW_MARKET comment='Whether location is in a new market',
		CHANNEL_FINANCIAL.TXN_YEAR_MONTH as TXN_YEAR_MONTH comment='Year-month of transaction',
		CHANNEL_FINANCIAL.TRANSACTION_DATE as TRANSACTION_DATE comment='Date of transaction'
	)
	metrics (
		CHANNEL_FINANCIAL.TOTAL_REVENUE as SUM(ORDER_TOTAL) comment='Total gross revenue',
		CHANNEL_FINANCIAL.TOTAL_NET_REVENUE as SUM(NET_REVENUE) comment='Total net revenue',
		CHANNEL_FINANCIAL.TOTAL_TRUE_NET_REVENUE as SUM(TRUE_NET_REVENUE) comment='Total true net revenue',
		CHANNEL_FINANCIAL.TOTAL_COMMISSIONS as SUM(PLATFORM_COMMISSION) comment='Total delivery platform commissions',
		CHANNEL_FINANCIAL.AVG_ORDER_VALUE as AVG(ORDER_TOTAL) comment='Average order value',
		CHANNEL_FINANCIAL.AVG_MARGIN_PCT as AVG(ORDER_MARGIN_PCT) comment='Average order margin',
		CHANNEL_FINANCIAL.TRANSACTION_COUNT as COUNT(*) comment='Total transactions'
	)
	comment='Channel and financial analytics semantic view for Shake Shack Marketing Agent.
Answers questions about channel profitability, delivery commission impact, app migration
opportunity, and margin optimization across 2M+ transactions.
'
	with extension (CA='{"tables":[{"name":"CHANNEL_FINANCIAL","dimensions":[{"name":"transaction_id"},{"name":"guest_id"},{"name":"order_channel","sample_values":["APP","WEB","KIOSK","IN_STORE","UBER_EATS","DOORDASH","GRUBHUB"]},{"name":"channel_group","sample_values":["THIRD_PARTY_DELIVERY","DIGITAL_DIRECT","IN_RESTAURANT"]},{"name":"daypart","sample_values":["BREAKFAST","LUNCH","AFTERNOON","DINNER","LATE_NIGHT"]},{"name":"clv_tier","sample_values":["PLATINUM","GOLD","SILVER","BRONZE"]},{"name":"rfm_segment"},{"name":"behavioral_segment"},{"name":"acquisition_channel"},{"name":"loyalty_enrolled"},{"name":"location_market"},{"name":"location_region"},{"name":"is_new_market"},{"name":"txn_year_month"}],"facts":[{"name":"order_total"},{"name":"discount_amount"},{"name":"delivery_fee"},{"name":"platform_commission"},{"name":"net_revenue"},{"name":"true_net_revenue"},{"name":"order_margin_pct"},{"name":"item_count"},{"name":"channel_commission_pct"},{"name":"channel_cac"}],"metrics":[{"name":"total_revenue"},{"name":"total_net_revenue"},{"name":"total_true_net_revenue"},{"name":"total_commissions"},{"name":"avg_order_value"},{"name":"avg_margin_pct"},{"name":"transaction_count"}],"filters":[{"name":"delivery_orders","description":"Third-party delivery orders only","expr":"CHANNEL_GROUP = ''THIRD_PARTY_DELIVERY''"},{"name":"direct_orders","description":"Direct/owned channel orders","expr":"CHANNEL_GROUP IN (''DIGITAL_DIRECT'', ''IN_RESTAURANT'')"}],"time_dimensions":[{"name":"transaction_date"}]}],"verified_queries":[{"name":"high_value_channel_mix","sql":"SELECT CHANNEL_GROUP, ORDER_CHANNEL, ROUND(SUM(CASE WHEN CLV_TIER IN (''PLATINUM'',''GOLD'') THEN ORDER_TOTAL ELSE 0 END), 2) AS high_value_revenue, ROUND(SUM(CASE WHEN CLV_TIER IN (''SILVER'',''BRONZE'') THEN ORDER_TOTAL ELSE 0 END), 2) AS standard_revenue, ROUND(AVG(CASE WHEN CLV_TIER IN (''PLATINUM'',''GOLD'') THEN ORDER_MARGIN_PCT END), 2) AS high_value_margin_pct FROM TEMP.EESCOBAR.MKT_CHANNEL_FINANCIAL_MART GROUP BY CHANNEL_GROUP, ORDER_CHANNEL ORDER BY high_value_revenue DESC\\n","question":"Compare high-value customer channel mix versus average customer","verified_at":1711500000,"verified_by":"demo"},{"name":"delivery_commission_loss","sql":"SELECT ORDER_CHANNEL, COUNT(*) AS total_orders, ROUND(SUM(ORDER_TOTAL), 2) AS gross_revenue, ROUND(SUM(PLATFORM_COMMISSION), 2) AS total_commissions, ROUND(AVG(ORDER_MARGIN_PCT), 2) AS avg_margin_pct FROM TEMP.EESCOBAR.MKT_CHANNEL_FINANCIAL_MART WHERE CHANNEL_GROUP = ''THIRD_PARTY_DELIVERY'' GROUP BY ORDER_CHANNEL ORDER BY total_commissions DESC\\n","question":"How much profit are we losing to third-party delivery commissions?","verified_at":1711500000,"verified_by":"demo"},{"name":"avg_order_by_channel","sql":"SELECT ORDER_CHANNEL, CHANNEL_GROUP, COUNT(*) AS total_orders, ROUND(AVG(ORDER_TOTAL), 2) AS avg_order_value, ROUND(AVG(ORDER_MARGIN_PCT), 2) AS avg_margin_pct, ROUND(SUM(ORDER_TOTAL), 2) AS total_revenue FROM TEMP.EESCOBAR.MKT_CHANNEL_FINANCIAL_MART GROUP BY ORDER_CHANNEL, CHANNEL_GROUP ORDER BY avg_order_value DESC\\n","question":"What is the average order value by channel?","verified_at":1711500000,"verified_by":"demo"},{"name":"quarterly_revenue_split","sql":"SELECT CHANNEL_GROUP, ORDER_CHANNEL, COUNT(*) AS transaction_count, ROUND(SUM(ORDER_TOTAL), 2) AS gross_revenue, ROUND(SUM(ORDER_TOTAL) * 100.0 / SUM(SUM(ORDER_TOTAL)) OVER (), 1) AS revenue_share_pct FROM TEMP.EESCOBAR.MKT_CHANNEL_FINANCIAL_MART WHERE TRANSACTION_DATE >= DATEADD(''month'', -3, CURRENT_DATE()) GROUP BY CHANNEL_GROUP, ORDER_CHANNEL ORDER BY gross_revenue DESC\\n","question":"Show me the revenue split by channel for the last quarter","verified_at":1711500000,"verified_by":"demo"},{"name":"delivery_dependency","sql":"SELECT LOCATION_MARKET, LOCATION_ID, COUNT(*) AS total_orders, ROUND(SUM(CASE WHEN CHANNEL_GROUP = ''THIRD_PARTY_DELIVERY'' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS delivery_pct FROM TEMP.EESCOBAR.MKT_CHANNEL_FINANCIAL_MART GROUP BY LOCATION_MARKET, LOCATION_ID HAVING COUNT(*) >= 100 ORDER BY delivery_pct DESC LIMIT 20\\n","question":"Which locations have the highest third-party delivery dependency?","verified_at":1711500000,"verified_by":"demo"}]}');

--SVIEW:MKT_MENU_LTO_VIEW
create or replace semantic view MKT_MENU_LTO_VIEW
	tables (
		MENU_PERFORMANCE as TEMP.EESCOBAR.MKT_MENU_PERFORMANCE_MART primary key (ORDER_ITEM_ID) comment='Order item-level menu performance data with weather, commodity prices, and LTO campaign metrics.',
		LTO_CHANNEL_ATTACH as TEMP.EESCOBAR.MKT_LTO_CHANNEL_ATTACH comment='Pre-aggregated LTO attach rates by item, channel, market, and date. Use this for kiosk-vs-delivery attach rate analysis. Each row is one LTO item on one day at one market through one channel.'
	)
	facts (
		MENU_PERFORMANCE.QUANTITY as QUANTITY comment='Quantity ordered',
		MENU_PERFORMANCE.SOLD_PRICE as SOLD_PRICE comment='Actual sell price',
		MENU_PERFORMANCE.LINE_TOTAL as LINE_TOTAL comment='Line item revenue',
		MENU_PERFORMANCE.BASE_PRICE as BASE_PRICE comment='Standard menu price',
		MENU_PERFORMANCE.FOOD_COST as FOOD_COST comment='Food cost per unit',
		MENU_PERFORMANCE.FOOD_COST_PCT as FOOD_COST_PCT comment='Food cost percentage',
		MENU_PERFORMANCE.ITEM_GROSS_PROFIT as ITEM_GROSS_PROFIT comment='Gross profit for line item',
		MENU_PERFORMANCE.ITEM_MARGIN_PCT as ITEM_MARGIN_PCT comment='Margin percentage for line item',
		MENU_PERFORMANCE.HIGH_TEMP_F as HIGH_TEMP_F comment='High temperature on transaction date',
		MENU_PERFORMANCE.PRECIPITATION_IN as PRECIPITATION_IN comment='Precipitation in inches',
		MENU_PERFORMANCE.PROTEIN_PRICE_INDEX as PROTEIN_PRICE_INDEX comment='Commodity price index for protein',
		MENU_PERFORMANCE.PROTEIN_YOY_CHANGE as PROTEIN_YOY_CHANGE comment='Protein price year-over-year change',
		MENU_PERFORMANCE.LTO_INCREMENTAL_TRAFFIC_PCT as LTO_INCREMENTAL_TRAFFIC_PCT comment='LTO incremental traffic percentage (campaign-level constant)',
		MENU_PERFORMANCE.LTO_ATTACH_RATE as LTO_ATTACH_RATE comment='Campaign-level attach rate constant (20-28 percent). For channel slicing use LTO_CHANNEL_ATTACH table metrics instead.',
		MENU_PERFORMANCE.LTO_SOCIAL_SENTIMENT as LTO_SOCIAL_SENTIMENT comment='LTO social sentiment score',
		MENU_PERFORMANCE.LTO_INCREMENTALITY_SCORE as LTO_INCREMENTALITY_SCORE comment='LTO incrementality score 0-100',
		MENU_PERFORMANCE.LTO_CANNIBALIZATION_PCT as LTO_CANNIBALIZATION_PCT comment='LTO cannibalization percentage',
		MENU_PERFORMANCE.LTO_GUEST_OVERLAP_PCT as LTO_GUEST_OVERLAP_PCT comment='Guest profile overlap between LTOs',
		MENU_PERFORMANCE.LTO_REPEAT_PURCHASE_RATE as LTO_REPEAT_PURCHASE_RATE comment='LTO repeat purchase rate',
		LTO_CHANNEL_ATTACH.LTO_TXNS as LTO_TXNS comment='Transactions containing this LTO item in the channel on this date at this market',
		LTO_CHANNEL_ATTACH.LTO_UNITS as LTO_UNITS comment='Units of this LTO sold in the channel on this date at this market',
		LTO_CHANNEL_ATTACH.LTO_REVENUE as LTO_REVENUE comment='Revenue from this LTO in the channel on this date at this market',
		LTO_CHANNEL_ATTACH.CHANNEL_TOTAL_TXNS as CHANNEL_TOTAL_TXNS comment='Total transactions in this channel on this date at this market (denominator for attach rate)',
		LTO_CHANNEL_ATTACH.CHANNEL_ATTACH_RATE_PCT as CHANNEL_ATTACH_RATE_PCT comment='Pre-computed channel attach rate percentage for this row'
	)
	dimensions (
		MENU_PERFORMANCE.ORDER_ITEM_ID as ORDER_ITEM_ID comment='Unique order item identifier',
		MENU_PERFORMANCE.TRANSACTION_ID as TRANSACTION_ID comment='Parent transaction',
		MENU_PERFORMANCE.GUEST_ID as GUEST_ID comment='Guest identifier',
		MENU_PERFORMANCE.ORDER_CHANNEL as ORDER_CHANNEL comment='Order channel (APP/KIOSK/IN_STORE/WEB/UBER_EATS/DOORDASH/GRUBHUB)',
		MENU_PERFORMANCE.LOCATION_ID as LOCATION_ID comment='Location identifier',
		MENU_PERFORMANCE.ITEM_NAME as ITEM_NAME comment='Menu item name',
		MENU_PERFORMANCE.MENU_CATEGORY as MENU_CATEGORY comment='Menu category',
		MENU_PERFORMANCE.MENU_SUBCATEGORY as MENU_SUBCATEGORY comment='Menu subcategory',
		MENU_PERFORMANCE.MENU_REGION as MENU_REGION comment='Region where item is available',
		MENU_PERFORMANCE.PROTEIN_TYPE as PROTEIN_TYPE comment='Primary protein',
		MENU_PERFORMANCE.IS_LTO as IS_LTO comment='Whether item is an LTO (true/false)',
		MENU_PERFORMANCE.IS_CORE_MENU as IS_CORE_MENU comment='Whether item is core menu',
		MENU_PERFORMANCE.STAGE_GATE_STATUS as STAGE_GATE_STATUS comment='Innovation stage-gate status',
		MENU_PERFORMANCE.PROMOTED_TO_CORE as PROMOTED_TO_CORE comment='Whether LTO promoted to core',
		MENU_PERFORMANCE.WEATHER_CONDITION as WEATHER_CONDITION comment='Weather on transaction date',
		MENU_PERFORMANCE.LTO_CAMPAIGN_NAME as LTO_CAMPAIGN_NAME comment='Associated LTO campaign name',
		MENU_PERFORMANCE.LTO_OUTCOME as LTO_OUTCOME comment='LTO campaign outcome',
		MENU_PERFORMANCE.LOCATION_MARKET as LOCATION_MARKET comment='Market where sold',
		MENU_PERFORMANCE.LOCATION_REGION as LOCATION_REGION comment='Region where sold',
		MENU_PERFORMANCE.TXN_YEAR_MONTH as TXN_YEAR_MONTH comment='Year-month of transaction',
		MENU_PERFORMANCE.TRANSACTION_DATE as TRANSACTION_DATE comment='Date of transaction',
		LTO_CHANNEL_ATTACH.LTO_ITEM_NAME as LTO_ITEM_NAME comment='Name of the LTO item (e.g. Big Shack, Dubai Chocolate Shake)',
		LTO_CHANNEL_ATTACH.LTO_MENU_ITEM_ID as LTO_MENU_ITEM_ID comment='LTO menu item ID',
		LTO_CHANNEL_ATTACH.ATTACH_MENU_CATEGORY as MENU_CATEGORY comment='LTO menu category',
		LTO_CHANNEL_ATTACH.ATTACH_STAGE_GATE_STATUS as STAGE_GATE_STATUS comment='LTO stage-gate status',
		LTO_CHANNEL_ATTACH.ATTACH_LTO_CAMPAIGN_NAME as LTO_CAMPAIGN_NAME comment='LTO campaign name',
		LTO_CHANNEL_ATTACH.ATTACH_ORDER_CHANNEL as ORDER_CHANNEL comment='Order channel for attach row (APP/KIOSK/IN_STORE/WEB/UBER_EATS/DOORDASH/GRUBHUB). Use with attach rate metrics for channel comparison.',
		LTO_CHANNEL_ATTACH.ATTACH_TRANSACTION_DATE as TRANSACTION_DATE comment='Transaction date for attach row',
		LTO_CHANNEL_ATTACH.ATTACH_LOCATION_MARKET as LOCATION_MARKET comment='Market for attach row',
		LTO_CHANNEL_ATTACH.ATTACH_LOCATION_REGION as LOCATION_REGION comment='Region for attach row'
	)
	metrics (
		MENU_PERFORMANCE.TOTAL_UNITS_SOLD as SUM(MENU_PERFORMANCE.QUANTITY) comment='Total units sold',
		MENU_PERFORMANCE.TOTAL_ITEM_REVENUE as SUM(MENU_PERFORMANCE.LINE_TOTAL) comment='Total item revenue',
		MENU_PERFORMANCE.TOTAL_ITEM_PROFIT as SUM(MENU_PERFORMANCE.ITEM_GROSS_PROFIT) comment='Total gross profit',
		MENU_PERFORMANCE.AVG_ITEM_MARGIN as AVG(MENU_PERFORMANCE.ITEM_MARGIN_PCT) comment='Average item margin percentage',
		LTO_CHANNEL_ATTACH.SUM_LTO_TXNS as SUM(LTO_CHANNEL_ATTACH.LTO_TXNS) comment='Sum of LTO transactions across the filtered slice',
		LTO_CHANNEL_ATTACH.SUM_LTO_UNITS as SUM(LTO_CHANNEL_ATTACH.LTO_UNITS) comment='Sum of LTO units across the filtered slice',
		LTO_CHANNEL_ATTACH.SUM_LTO_REVENUE as SUM(LTO_CHANNEL_ATTACH.LTO_REVENUE) comment='Sum of LTO revenue across the filtered slice',
		LTO_CHANNEL_ATTACH.SUM_CHANNEL_TOTAL_TXNS as SUM(LTO_CHANNEL_ATTACH.CHANNEL_TOTAL_TXNS) comment='Sum of channel total transactions across the filtered slice (denominator)',
		LTO_CHANNEL_ATTACH.TRUE_CHANNEL_ATTACH_RATE as 100.0 * SUM(LTO_CHANNEL_ATTACH.LTO_TXNS) / NULLIF(SUM(LTO_CHANNEL_ATTACH.CHANNEL_TOTAL_TXNS), 0) comment='TRUE transaction-level LTO attach rate percentage. Computes (LTO transactions / channel total transactions) after aggregation. Use this to compare attach rates across ORDER_CHANNEL, LOCATION_MARKET, LTO_ITEM_NAME. Example: filter by LTO_ITEM_NAME = ''Big Shack'' and group by ORDER_CHANNEL to see kiosk vs delivery attach.'
	)
	comment='Menu and LTO performance semantic view. Use MENU_PERFORMANCE for item-level metrics. Use LTO_CHANNEL_ATTACH with TRUE_CHANNEL_ATTACH_RATE metric for channel-level attach analysis (kiosk vs delivery).';

--SVIEW:MKT_RETENTION_COHORT_VIEW
create or replace semantic view MKT_RETENTION_COHORT_VIEW
	tables (
		RETENTION as TEMP.EESCOBAR.MKT_GUEST_RETENTION_COHORT primary key (GUEST_ID) comment='Per-guest app acquisition retention cohort with 30-day return tracking and promo attribution.'
	)
	facts (
		RETENTION.FIRST_ORDER_TOTAL as FIRST_ORDER_TOTAL comment='First visit order total',
		RETENTION.FIRST_DISCOUNT as FIRST_DISCOUNT comment='Discount on first visit',
		RETENTION.SECOND_ORDER_TOTAL as SECOND_ORDER_TOTAL comment='Second visit order total',
		RETENTION.SECOND_DISCOUNT as SECOND_DISCOUNT comment='Discount on second visit',
		RETENTION.DAYS_TO_RETURN as DAYS_TO_RETURN comment='Days between first and second visit',
		RETENTION.CHURN_RISK_SCORE as CHURN_RISK_SCORE comment='ML churn risk score 0-100'
	)
	dimensions (
		RETENTION.GUEST_ID as GUEST_ID comment='Guest identifier',
		RETENTION.FIRST_VISIT_DATE as FIRST_VISIT_DATE comment='Date of first app visit',
		RETENTION.FIRST_LOCATION_ID as FIRST_LOCATION_ID comment='Location of first visit',
		RETENTION.FIRST_LOCATION_FORMAT as FIRST_LOCATION_FORMAT comment='Store format: Traditional, Drive-Thru, Stadium, Airport',
		RETENTION.FIRST_REGION as FIRST_REGION comment='Region: Northeast, Midwest, Southeast, West, Southwest, International',
		RETENTION.FIRST_MARKET as FIRST_MARKET comment='Market metro area',
		RETENTION.ACQUISITION_PROMO as ACQUISITION_PROMO comment='Promo code used on first visit (e.g. APP135 for the 1-3-5 promotion)',
		RETENTION.SECOND_VISIT_DATE as SECOND_VISIT_DATE comment='Date of second visit',
		RETENTION.SECOND_VISIT_PROMO as SECOND_VISIT_PROMO comment='Promo code used on second visit',
		RETENTION.RETURNED_WITHIN_30 as RETURNED_WITHIN_30 comment='Whether guest returned within 30 days (TRUE/FALSE)',
		RETENTION.SECOND_VISIT_FULL_PRICE as SECOND_VISIT_FULL_PRICE comment='Whether second visit was full price with no promo (TRUE/FALSE)',
		RETENTION.DID_RETURN as DID_RETURN comment='Whether guest made a second visit at all (TRUE/FALSE)',
		RETENTION.CLV_TIER as CLV_TIER comment='Customer lifetime value tier: PLATINUM, GOLD, SILVER, BRONZE',
		RETENTION.RFM_SEGMENT as RFM_SEGMENT comment='RFM segment name',
		RETENTION.LOYALTY_ENROLLED as LOYALTY_ENROLLED comment='Whether guest is enrolled in loyalty program'
	)
	metrics (
		RETENTION.TOTAL_ACQUIRED as COUNT(*) comment='Total guests acquired',
		RETENTION.RETURNED_COUNT as SUM(CASE WHEN DID_RETURN THEN 1 ELSE 0 END) comment='Guests who made a second visit',
		RETENTION.RETURNED_30D_COUNT as SUM(CASE WHEN RETURNED_WITHIN_30 THEN 1 ELSE 0 END) comment='Guests who returned within 30 days',
		RETENTION.FULL_PRICE_30D_COUNT as SUM(CASE WHEN RETURNED_WITHIN_30 AND SECOND_VISIT_FULL_PRICE THEN 1 ELSE 0 END) comment='Guests who returned within 30 days at full price',
		RETENTION.RETENTION_RATE as ROUND(100.0 * SUM(CASE WHEN RETURNED_WITHIN_30 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) comment='30-day retention rate percentage',
		RETENTION.FULL_PRICE_RETURN_RATE as ROUND(100.0 * SUM(CASE WHEN RETURNED_WITHIN_30 AND SECOND_VISIT_FULL_PRICE THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) comment='30-day full-price return rate percentage'
	)
	comment='App acquisition retention analysis for Shake Shack. Tracks 1-3-5 promo guest retention by format (Drive-Thru, Traditional), region (Midwest, etc.), and CLV tier. Answers: what % of promo-acquired guests returned within 30 days at full price.';

