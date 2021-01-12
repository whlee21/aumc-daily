DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_2 ;;
CREATE TABLE itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_2 AS
SELECT * FROM (
SELECT
DISTINCT
patno
,medical_dt
,record_dt
,order_dt
,visit_gb
,insert_type
,trim(form_nm) as form_nm
,medical_dept
,medical_dr
,CASE
    WHEN lower(gubun) LIKE '%phx%' and lower(item) not LIKE '%phx%' THEN '과거력'
    WHEN lower(item) like  '%allergy%' THEN 'Allergy'
  END AS observation_item1
,CASE
  WHEN lower(gubun) LIKE '%phx%' and lower(item) not LIKE '%phx%' THEN item
  WHEN lower(item) like  '%allergy%' THEN item
    END AS observation_item2
,'' AS observation_item3
,CASE
  WHEN lower(gubun) LIKE '%phx%' and lower(item) not LIKE '%phx%' AND result_data LIKE 'N%'THEN 'N'
  WHEN lower(gubun) LIKE '%phx%' and lower(item) not LIKE '%phx%' AND result_data LIKE 'Y%'THEN 'Y'
  WHEN lower(item) LIKE '%allergy%' AND result_data LIKE 'Y%'THEN 'Y'
  WHEN lower(item) LIKE '%allergy%' AND result_data LIKE 'N%'THEN 'N'
    END AS result_cd_txt
,null as result_num
FROM ods_daily.itf_emr_frm_2
  ) A WHERE result_cd_txt IS NOT NULL;;



-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation_from_emr_frm_2' , 'itf_observation_from_emr_frm_2', count(*) as cnt
from itfcdmpv532_daily.itf_observation_from_emr_frm_2 ;
