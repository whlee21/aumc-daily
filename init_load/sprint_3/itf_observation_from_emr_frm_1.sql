DROP TABLE IF EXISTS iitfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_1;;

CREATE TABLE itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_1 AS
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
,observation_item1
,unnest(array['asthma','cancer','dm','dyslipidemia','hepatitis','htn','tb','stroke','mi']) AS observation_item2
,'' AS observation_item3
, unnest(array[asthma,cancer,dm,dyslipidemia,hepatitis,htn,tb,stroke,mi]) AS result_cd_txt
, null as result_num
FROM (
SELECT
DISTINCT
patno
,medical_dt
,record_dt
,order_dt
,visit_gb
,insert_type
,form_nm
,medical_dept
,medical_dr
,CASE
    WHEN item = '현병력' THEN item
    WHEN item LIKE '%PHx' THEN '과거력'
    WHEN item LIKE '%FHx' OR item LIKE '%가족력' THEN '가족력'
END AS observation_item1
,CASE WHEN result_data like '%asthma%' OR result_data like '%천식%' THEN 'Y' END AS asthma
,CASE WHEN result_data like '%cancer%' OR result_data like '%암%' THEN 'Y' END AS cancer
,CASE WHEN result_data like '%DM%' OR result_data like '%diabetes mellitus%' OR result_data like '%당뇨%' OR result_data like '%당뇨병%' THEN 'Y' END AS DM
,CASE WHEN result_data like '%dyslipidemia%' OR result_data like '%고지혈증%' OR result_data like '%이상고지혈증%' THEN 'Y' END AS dyslipidemia
,CASE WHEN result_data like '%hepatitis%' OR result_data like '%간염%' THEN 'Y' END AS hepatitis
,CASE WHEN result_data like '%HTN%' OR result_data like '%hypertension%' OR result_data like '%고혈압%' THEN 'Y' END AS HTN
,CASE WHEN result_data like '%TB%' OR result_data like '%Tuberculosis%' OR result_data like '%결핵%' OR result_data like '%폐결핵%' THEN 'Y' END AS TB
,CASE WHEN result_data like '%뇌졸중%' OR result_data like '%중풍%' OR result_data like '%stroke%' THEN 'Y' END AS stroke
,CASE WHEN result_data like '%심근경색%' OR result_data like '%협심증%' OR result_data like '%angina%' OR result_data like '%MI%' OR result_data like '%myocardial infarction%' THEN 'Y' END AS MI
FROM ods_daily.itf_emr_frm_1
WHERE (item = '현병력' OR item LIKE '%PHx' OR item LIKE '%FHx' OR item LIKE '%가족력')
) A ) B WHERE B.result_cd_txt IS NOT NULL
UNION ALL
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
    WHEN lower(item) LIKE '%allergy' OR item LIKE '%알러지' THEN 'Allergy'
  WHEN item LIKE '%흡연' THEN '흡연'
  WHEN item LIKE '%음주%' THEN '음주'
    END AS observation_item1
,CASE
  WHEN (lower(item) LIKE '%allergy' OR item LIKE '%알러지') THEN item
  WHEN item LIKE '%흡연' THEN '흡연'
  WHEN item = '음주' THEN '음주여부'
  WHEN item = '음주량' THEN '음주량'
    END AS observation_item2
,CASE
  WHEN item = '음주량' THEN
    CASE
      WHEN gubun like '%병/일' THEN '병/일'
      WHEN gubun like '%병/회' THEN '병/회'
      WHEN gubun is null and result_data like '%병%' THEN '병/회'
      WHEN gubun is null and result_data like '%잔%' THEN '잔/회'
      WHEN gubun is null and result_data like '%캔%' THEN '캔/회'
      WHEN gubun is null and result_data like '%cc%' THEN 'CC/회'
    END
    ELSE '' END  AS observation_item3
,CASE
  WHEN (lower(item) LIKE '%allergy' OR item LIKE '%알러지') AND result_data = '무' THEN 'N'
  WHEN (lower(item) LIKE '%allergy' OR item LIKE '%알러지') AND result_data <> '무' THEN 'Y'
  WHEN item LIKE '%흡연'
         AND (result_data LIKE '%금연%' or lower(result_data) LIKE '%quit%' or lower(result_data) LIKE 'never%' or lower(result_data) LIKE '%stop%') then 'N'
    WHEN item LIKE '%흡연'
         AND NOT (result_data LIKE '%금연%' or lower(result_data) LIKE '%quit%' or lower(result_data) LIKE 'never%' or lower(result_data) LIKE '%stop%') then 'Y'
  WHEN item = '음주' AND (result_data like '%no%' or result_data like '%안%' or result_data like '%않%' or result_data like '%금주%') THEN 'N'
  WHEN item = '음주' AND NOT (result_data like '%no%' or result_data like '%안%' or result_data like '%않%' or result_data like '%금주%') THEN 'Y'
    END AS result_cd_txt
,CASE
  WHEN item = '음주량' AND gubun is not null and ods_daily.is_numeric(result_data) = TRUE THEN result_data
    WHEN item = '음주량' AND gubun is null and
         ods_daily.is_numeric(replace(replace(replace(replace(replace(replace(replace(replace(result_data,'병',''),'캔',''),'잔',''),'cc',''),'정도',''),'이상',''),'이하',''),'-','.')) = TRUE
        THEN replace(replace(replace(replace(replace(replace(replace(replace(result_data,'병',''),'캔',''),'잔',''),'cc',''),'정도',''),'이상',''),'이하',''),'-','.') END AS result_num
FROM ods_daily.itf_emr_frm_1
  ) A WHERE result_cd_txt IS NOT NULL or (OBSERVATION_ITEM2 = '음주량' and result_num is not null);;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation_from_emr_frm_1' , 'itf_observation_from_emr_frm_1', count(*) as cnt
from itfcdmpv532_daily.itf_observation_from_emr_frm_1 ;
