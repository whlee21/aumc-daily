DROP TABLE itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_3;;

CREATE TABLE itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_3 AS
SELECT * FROM (
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
,observation_item1
,unnest(array['asthma','cancer','dm','dyslipidemia','hepatitis','htn','tb','stroke','mi']) AS observation_item2
,'' AS observation_item3
, unnest(array[asthma,cancer,dm,dyslipidemia,hepatitis,htn,tb,stroke,mi]) AS result_cd_txt
, NULL AS  result_num
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
,'과거력' AS observation_item1
,CASE WHEN result_data like '%asthma%' OR result_data like '%천식%' THEN 'Y' END AS asthma
,CASE WHEN result_data like '%cancer%' OR result_data like '%암%' THEN 'Y' END AS cancer
,CASE WHEN result_data like '%DM%' OR result_data like '%diabetes mellitus%' OR result_data like '%당뇨%' OR result_data like '%당뇨병%' THEN 'Y' END AS DM
,CASE WHEN result_data like '%dyslipidemia%' OR result_data like '%고지혈증%' OR result_data like '%이상고지혈증%' THEN 'Y' END AS dyslipidemia
,CASE WHEN result_data like '%hepatitis%' OR result_data like '%간염%' THEN 'Y' END AS hepatitis
,CASE WHEN result_data like '%HTN%' OR result_data like '%hypertension%' OR result_data like '%고혈압%' THEN 'Y' END AS HTN
,CASE WHEN result_data like '%TB%' OR result_data like '%Tuberculosis%' OR result_data like '%결핵%' OR result_data like '%폐결핵%' THEN 'Y' END AS TB
,CASE WHEN result_data like '%뇌졸중%' OR result_data like '%중풍%' OR result_data like '%stroke%' THEN 'Y' END AS stroke
,CASE WHEN result_data like '%심근경색%' OR result_data like '%협심증%' OR result_data like '%angina%' OR result_data like '%MI%' OR result_data like '%myocardial infarction%' THEN 'Y' END AS MI
FROM ods_daily.itf_emr_frm_3 
WHERE item = 'PHx'
) A ) B WHERE B.result_cd_txt IS NOT NULL;;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation_from_emr_frm_3' , 'itf_observation_from_emr_frm_3', count(*) as cnt
from itfcdmpv532_daily.itf_observation_from_emr_frm_3 ;