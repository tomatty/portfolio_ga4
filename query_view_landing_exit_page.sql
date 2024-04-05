--# ランディングページ別：ランディングページ、離脱ページ、セッション数

WITH
master AS(
      SELECT event_date
            ,user_pseudo_id
            ,ga_session_id
            ,page_location
            ,FIRST_VALUE(page_location) OVER(PARTITION BY user_pseudo_id,ga_session_id ORDER BY time_stamp_UTC) AS landing_page
            ,LAST_VALUE(page_location) OVER(PARTITION BY user_pseudo_id,ga_session_id ORDER BY time_stamp_UTC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS exit_page
      FROM river-octagon-379701.portfolio_ga4.basic_view
)


SELECT CONCAT(landing_page,"  -->  ",exit_page) AS landing_and_exit
      ,COUNT(*) AS number_of_session
FROM(
      SELECT event_date
            ,user_pseudo_id
            ,ga_session_id
            ,MAX(landing_page) AS landing_page
            ,MAX(exit_page) AS exit_page
      FROM master
      GROUP BY event_date
              ,user_pseudo_id
              ,ga_session_id)
      GROUP BY landing_and_exit
      ORDER BY number_of_session DESC