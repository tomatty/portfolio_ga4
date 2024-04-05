--# イベント別：イベント数,UU
SELECT event_date
      ,event_name
      ,COUNT(event_name) AS number_of_event
      ,COUNT(DISTINCT user_pseudo_id) AS UU
FROM river-octagon-379701.portfolio_ga4.basic_view
--1日分のデータしか蓄積されていないため、WHERE句による期間指定はしない--
GROUP BY event_date 
        ,event_name
ORDER BY number_of_event DESC