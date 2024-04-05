--# ページ別：UU/新規ユーザー数/session/PV/エンゲージメントセッション数/エンゲージメント率/平均エンゲージメント時間/スクロール数/スクロール率

SELECT event_date
      ,page_location AS page
      ,COUNT(DISTINCT user_pseudo_id) AS UU
      ,SUM(IF(event_name = "first_visit",1,0)) AS new_visitor
      ,COUNT(CONCAT(user_pseudo_id,ga_session_number)) AS number_of_session
      ,SUM(IF(event_name = "page_view",1,0)) AS PV
      ,ROUND(AVG(engagement_time_msec / 1000),1) AS AVG_engagement_time
      ,SUM(IF(session_engaged <> "",1,0)) AS number_of_engaged_session
      ,ROUND(SUM(IF(session_engaged <> "",1,0)) / COUNT(CONCAT(user_pseudo_id,ga_session_number)),3) AS engaged_session_ratio
      ,SUM(IF(event_name = "scroll",1,0)) AS scroll
      ,ROUND(SUM(IF(event_name = "scroll",1,0)) / SUM(IF(event_name = "page_view",1,0)),3) AS scroll_ratio
FROM river-octagon-379701.portfolio_ga4.basic_view
--1日分のデータしか蓄積されていないため、WHERE句による期間指定はしない--
GROUP BY event_date 
        ,page
ORDER BY number_of_session DESC