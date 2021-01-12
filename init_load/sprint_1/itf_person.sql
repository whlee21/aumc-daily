/*****************************************************
프로그램명  : ITF_PERSON.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) : itf_person (환자정보)
소스 테이블(참조) : 
프로그램 설명 : 환자번호생성 - 초기적재
cnt: 
*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_PERSON;

CREATE TABLE itfcdmpv532_daily.ITF_PERSON as
select
	  A.patno :: bigint as uid
	, A.patno :: varchar(50) AS patient_id
	, A.sex::varchar(10) AS gender
	, A.birthday:: TIMESTAMP AS birth_dt
	, case when length(a.zipcode) !=5 then C.new_zip1:: varchar(50) else  SUBSTRING(A.zipcode,1,3) end::varchar(10)  AS zip_cd--, A.zipcode 
	, CASE WHEN A.resno2 IN ('5','6','7','8') THEN  A.resno2 ELSE '1' END AS  FOREIGNER_GB
	, CASE WHEN A.resno2 IN ('5','6','7','8') THEN 'Y' ELSE 'N' END AS FOREIGNER_YN
	, A.frncode::varchar(10) AS race_gb
	, 8200001::int as hospital_id
	, now() as etl_dt
FROM ods_daily.acpatbat  A
LEFT JOIN mapcdmpv532_daily.zip_mapping C ON SUBSTRING(A.zipcode,1,3) = C.old_zip
;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_person' , 'itf_person', count(*) as cnt
from itfcdmpv532_daily.itf_person ;

