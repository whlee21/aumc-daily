/*****************************************************
프로그램명  : ITF_OBSERVATION.sql
작성자      : Won Jong Bok
수정자      :  
최초 작성일 : 2020-12-04
수정일      : 
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 : 

cnt : 
time : 
*****************************************************/



DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_OBSERVATION;;
CREATE TABLE itfcdmpv532_daily.ITF_OBSERVATION AS
SELECT row_number() OVER (ORDER BY null):: bigint AS uid, B.*
FROM (
         SELECT DISTINCT NULL::VARCHAR(50)        AS visit_no
                       , patno::VARCHAR(50) AS patient_id
                       , A.visit_gb :: VARCHAR(10)
                       , A.medical_dept :: VARCHAR(50)
                       , medical_dr :: VARCHAR(50)  AS medical_dr
                       , A.medical_dt :: TIMESTAMP
                       , A.record_dt :: TIMESTAMP
                       , A.form_nm :: VARCHAR(50)
                       , A.observation_item1 :: VARCHAR(50)
                       , A.observation_item2 :: VARCHAR(50)
                       , CASE WHEN source_domain != 'NEDIS' then
                            case  when observation_item2!='음주량' then
                                case WHEN result_num is null
                                    then result_cd_txt else cast(result_num as text) end
                            else '' end
                        ELSE '' END :: VARCHAR(50) as observation_item3
                       , NULL :: VARCHAR(50)         qualifier
                       , A.result_cd_txt :: TEXT AS result_txt
                       , A.result_num :: FLOAT       result_num
                       , NULL :: VARCHAR(50)         result_unit
                       , reference_gb :: varchar(10)
                       , null :: timestamp  lastupdate_dt
         FROM (
                  SELECT *,'Observation' AS source_domain, 'EMR' as reference_gb
                  FROM itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_1
                  UNION ALL
                  SELECT *,'Observation' AS source_domain, 'EMR' as reference_gb
                  FROM itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_2
                  UNION ALL
                  SELECT *,'Observation' AS source_domain, 'EMR' as reference_gb
                  FROM itfcdmpv532_daily.ITF_OBSERVATION_FROM_EMR_FRM_3
                  UNION ALL
                  SELECT patno
                          , medical_dt::varchar
                          , record_dt::varchar
                          , order_dt
                          , visit_gb
                          , insert_type
                          , form_nm
                          , medical_dept
                          , medical_dr
                          , observation_item1
                          , observation_item2
                          , observation_item3
                          , result_cd_txt
                          , result_num
                          ,'NEDIS' AS source_domain, 'NEDIS' as reference_gb
                  FROM itfcdmpv532_daily.ITF_OBSERVATION_FROM_NEDIS
                  UNION ALL
                  SELECT  patient_id
                          , medical_dt::varchar
                          , record_dt::varchar
                          , order_dt
                          , visit_gb
                          , insert_type
                          , form_nm
                          , medical_dept
                          , medical_dr
                          , observation_item1
                          , observation_item2
                          , observation_item3
                          , result_cd_txt
                          , result_num
                      ,'Observation' AS source_domain
                      , 'INDM' as reference_gb
                  FROM itfcdmpv532_daily.itf_observation_from_indm
                  UNION ALL
                  SELECT  patient_id
                          , medical_dt::varchar
                          , record_dt::varchar
                          , order_dt::varchar
                          , visit_gb
                          , '' as insert_type
                          , form_nm
                          , medical_dept
                          , medical_dr
                          , observation_item1
                          , observation_item2
                          , observation_item3
                          , result_txt
                          , result_num
                      ,'Observation' AS source_domain
                      , reference_gb
                  FROM itfcdmpv532_daily.itf_observation_ast

              ) A
              WHERE coalesce(record_dt, medical_dt)  :: DATE >= '1994-01-01'
     ) B ;;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation' , 'itf_observation', count(*) as cnt
from itfcdmpv532_daily.itf_observation ;