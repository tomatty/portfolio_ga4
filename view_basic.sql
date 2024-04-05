----分析に使用するメインフィールドを取得----

WITH master AS
(
SELECT event_date
      ,FORMAT_TIMESTAMP("%H:%M:%S",TIMESTAMP_MICROS(event_timestamp)) AS event_timestamp_UTC --UNIXエポックからH:M:S形式に変換
      ,FORMAT_TIMESTAMP("%H",TIMESTAMP_MICROS(event_timestamp)) AS event_hour_UTC --UNIXエポックからH:M:S形式に変換
      ,event_name
      ,event_params
      ,event_previous_timestamp
      ,event_bundle_sequence_id
      ,user_pseudo_id
      ,FORMAT_TIMESTAMP("%H:%M:%S",TIMESTAMP_MICROS(user_first_touch_timestamp)) AS user_first_touch_timestamp --UNIXエポックからH:M:S形式に変換
      ,device
      ,geo
      ,traffic_source
      ,platform
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
)

----ネスト構造からフラットテーブルに変換----
SELECT event_date
      ,master.event_timestamp_UTC AS time_stamp_UTC
      ,master.event_hour_UTC AS hour_UTC
      ,event_name
      --event_prams--
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "page_location") AS page_location
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "page_title") AS page_title
      ,(SELECT value.int_value FROM UNNEST(event_params) WHERE key = "percent_scrolled") AS percent_scrolled
      ,(SELECT value.int_value FROM UNNEST(event_params) WHERE key = "engagement_time_msec") AS engagement_time_msec
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "page_referrer") AS page_referrer
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "search_term") AS search_term
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "link_domain") AS link_domain
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "link_url") AS link_url
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "coupon") AS coupon
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "promotion_name") AS promotion_name
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "session_engaged") AS session_engaged
      ,(SELECT value.int_value FROM UNNEST(event_params) WHERE key = "engaged_session_event") AS engaged_session_event
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "campaign") AS utm_campaign
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "source") AS utm_source
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "medium") AS utm_medium
      ,(SELECT value.string_value FROM UNNEST(event_params) WHERE key = "term") AS utm_term
      ,(SELECT value.int_value FROM UNNEST(event_params) WHERE key = "ga_session_number") AS ga_session_number
      ,(SELECT value.int_value FROM UNNEST(event_params) WHERE key = "ga_session_id") AS ga_session_id
      ----
      ,event_previous_timestamp
      ,event_bundle_sequence_id
      ,user_pseudo_id
      ,user_first_touch_timestamp
      --device start--
      ,device.category
      ,device.mobile_brand_name
      ,device.mobile_model_name
      ,device.mobile_os_hardware_model
      ,device.operating_system
      ,device.language
      ,device.web_info.browser
      ----
      --geo--
      ,geo.continent
      ,geo.sub_continent
      ,geo.country
      ,geo.region
      ,geo.city
      ----
      --traffic--
      ,traffic_source.medium
      ,traffic_source.name
      ,traffic_source.source
      ----
      ,platform

FROM master
