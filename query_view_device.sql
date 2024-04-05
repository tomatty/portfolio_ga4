--# device別：UU/新規ユーザー数/session/PV/CV/CVR/平均エンゲージメント時間

SELECT event_date
      ,category
      ,platform
      ,operating_system
      ,browser
      ,mobile_brand_name
      ,COUNT(DISTINCT user_pseudo_id) AS UU
      ,SUM(IF(event_name = "first_visit",1,0)) AS new_visitor
      ,COUNT(CONCAT(user_pseudo_id,ga_session_number)) AS number_of_session
      ,SUM(IF(event_name = "page_view",1,0)) AS PV
      ,SUM(IF(event_name = "purchase",1,0)) AS CV
      ,ROUND(SUM(IF(event_name = "purchase",1,0)) / COUNT(DISTINCT CONCAT(user_pseudo_id,ga_session_number)),3) AS CVR
      ,ROUND(AVG(engagement_time_msec / 1000),1) AS AVG_engagement_time
FROM river-octagon-379701.portfolio_ga4.basic_view
--1日分のデータしか蓄積されていないため、WHERE句による期間指定はしない--
GROUP BY event_date 
        ,category
        ,platform
        ,operating_system
        ,browser
        ,mobile_brand_name
ORDER BY category