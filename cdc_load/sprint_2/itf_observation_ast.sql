/*****************************************************
프로그램명  : ITF_OBSERVATION_AST.sql
작성자      : 
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) : mnastmgt (AST:antibiotics skin test)
소스 테이블(참조) : apipdlst
프로그램 설명 : AST 테이블 
cnt: 
*****************************************************/


drop table if exists itfcdmpv532_daily.itf_observation_ast;;


CREATE TABLE itfcdmpv532_daily.itf_observation_ast
AS
SELECT              
	NULL::VARCHAR(50)        AS visit_no
   , A.patno::VARCHAR(50)    AS patient_id
   , 'I' :: VARCHAR(10)           AS visit_gb
   , (select b.meddept from ods_daily.apipdlst b
    where  A.patno = b.patno
    and A.admtime = b.admtime ) :: VARCHAR(50) AS medical_dept
   , null :: VARCHAR(50)  AS medical_dr
   , A.admtime :: TIMESTAMP AS medical_dt
   , A.orddate :: TIMESTAMP AS record_dt
   , A.orddate :: TIMESTAMP AS order_dt
   , 'AST' :: VARCHAR(50) AS form_nm
   , A.ordcode :: VARCHAR(50) AS observation_item1
   , null :: VARCHAR(50) AS observation_item2
   , CASE WHEN a.examrslt = 'P' THEN 'Positive'
              WHEN a.examrslt = 'N' THEN 'Negative'
               END  :: VARCHAR(50) AS observation_item3
   , NULL :: VARCHAR(50)          AS qualifier
   , CASE WHEN a.examrslt = 'P' THEN 'Positive'
              WHEN a.examrslt = 'N' THEN 'Negative'
               END  :: VARCHAR(50)  AS result_txt
   , null ::VARCHAR    AS    result_num
   , NULL :: VARCHAR(50)   AS  result_unit
   , 'AST' :: varchar(10) AS reference_gb
   , null :: timestamp AS  lastupdate_dt
FROM ods_daily.mnastmgt A
inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno;


   -----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation_ast' , 'itf_observation_ast', count(*) as cnt
from itfcdmpv532_daily.itf_observation_ast ;
