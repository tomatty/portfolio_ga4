--#　ランディングページ別：セッション数/直帰数/直帰率/平均エンゲージメント時間/スクロール数/スクロール率

WITH
table1 AS(
      SELECT event_date
            ,user_pseudo_id
            ,ga_session_id
            ,page_location
            ,FIRST_VALUE(page_location) OVER(PARTITION BY user_pseudo_id,ga_session_id ORDER BY time_stamp_UTC) AS landing_page
            ,LAST_VALUE(page_location) OVER(PARTITION BY user_pseudo_id,ga_session_id ORDER BY time_stamp_UTC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS exit_page
            ,event_name
            ,ROUND(engagement_time_msec / 1000,3) AS engagement_time
            ,IF(event_name = "page_view",1,0) AS PV_flag --PVイベントフラグ
            ,IF(event_name = "scroll",1,0)AS scroll_flag --scrollイベントフラグ
      FROM river-octagon-379701.portfolio_ga4.basic_view
),

--ランディングページ別の直帰数を取得--
table2 AS(
      SELECT event_date
            ,landing_page  AS landing_page
            ,COUNT(*) AS bounce --直帰数
      FROM(
            SELECT event_date
                  ,user_pseudo_id
                  ,ga_session_id
                  ,landing_page
                  ,SUM(PV_flag) AS PV_COUNT --セッションごとにPVイベントの数を集計
            FROM table1
            GROUP BY  event_date
                     ,user_pseudo_id
                     ,ga_session_id
                     ,landing_page
            HAVING PV_COUNT = 1) --直帰=PVが1のセッション

      GROUP BY  event_date
               ,landing_page
      ORDER BY bounce DESC
),

--ランディングページ別のセッション数,平均エンゲージメント時間、スクロール数、スクロール率を取得--
table3 AS(
      SELECT event_date
            ,landing_page
            ,SUM(number_of_session) AS number_of_session
            ,ROUND(AVG(AVG_engagement_time),3) AS AVG_engagement_time
            ,SUM(scroll) AS scroll
            ,ROUND(SUM(scroll) / SUM(number_of_session),3) AS scroll_ratio
      FROM(
            SELECT event_date
                  ,user_pseudo_id
                  ,ga_session_id
                  ,landing_page
                  ,COUNT(*) number_of_session
                  ,AVG(engagement_time) AS AVG_engagement_time
                  ,SUM(scroll_flag) AS scroll
            FROM table1
            GROUP BY event_date
                    ,user_pseudo_id
                    ,ga_session_id
                    ,landing_page)
      GROUP BY  event_date
               ,landing_page
)

--ランディングページ/離脱ページ--
/*
table4 AS(
      SELECT CONCAT(landing_page,"  -->  ",exit_page) AS landing_and_exit
            ,MAX(landing_page) AS landing_page
            ,COUNT(*) AS number_of_session
      FROM(
            SELECT event_date
                  ,user_pseudo_id
                  ,ga_session_id
                  ,MAX(landing_page) AS landing_page
                  ,MAX(exit_page) AS exit_page
            FROM table1
            GROUP BY event_date
                  ,user_pseudo_id
                  ,ga_session_id)
            GROUP BY landing_and_exit
            ORDER BY number_of_session DESC
)
*/

SELECT table2.event_date AS event_date
      ,table2.landing_page AS landing_page
      ,table3.number_of_session AS number_of_session 
      ,table2.bounce AS bounce
      ,ROUND(table2.bounce / table3.number_of_session,3) AS bounce_ratio
      ,table3.AVG_engagement_time AS AVG_engagement_time
      ,table3.scroll AS scroll
      ,table3.scroll_ratio AS scroll_ratio
FROM table2
INNER JOIN table3
ON table2.landing_page = table3.landing_page
ORDER BY bounce DESC
