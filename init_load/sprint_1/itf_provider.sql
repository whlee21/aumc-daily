/*****************************************************
프로그램명  : ITF_PROVIDER.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) :csusermt (직원정보)
소스 테이블(참조) : cscomcdt (공통코드), ps3010 (부서정보)
프로그램 설명 : 환자번호생성 - 초기적재
cnt: 
*****************************************************/



DROP TABLE if exists itfcdmpv532_daily.itf_provider;;

CREATE TABLE itfcdmpv532_daily.itf_provider as
select uid
     , provider_id
     , job_category_cd 
     , job_category_nm
     , year_of_birth 
     , gender 
     , dept_cd 
     , verify_yn
     , now() as etl_dt
from ( 
	select  
	    a.cdm_userid :: bigint AS uid
	  , a.cdm_empno :: VARCHAR(50) AS provider_id
	  , case when a.drst is not null then concat(e.spdept ,'/',a.drst) end :: VARCHAR(20) AS job_category_cd
	  , case when a.drst is not null then concat(f.codename ,'/', d.codename) end :: VARCHAR(50) job_category_nm
	  --, a.birth_dt :: INT AS year_of_birth -- All birth_dt were null in ods_daily.csusermt
	  , a.birth_dt :: VARCHAR(50) AS year_of_birth
	  , a.sex :: VARCHAR(10) AS gender
	  , a.deptcode ::varchar(20) AS dept_cd
	  , 'Y'::varchar(1) as verify_yn
	  --, row_number() over(partition by a.userid order by a.enddate) rn
	  , row_number() over(partition by a.cdm_userid order by a.enddate) rn
	FROM ods_daily.csusermt a
	left join ods_daily.cscomcdt d on a.drst  = d.smallgcode and d.midgcode = 'CS080'
	left join ods_daily.ps3010 e on a.deptcode = e.dept_cd 
	left join ods_daily.CSCOMCDT f on f.MIDGCODE ='AI001' and e.spdept =f.smallgcode 
) t 
where rn = 1
;;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_provider' , 'itf_provider', count(*) as cnt
--from itfcdmpv532_daily.itf_order_1 ;
from itfcdmpv532_daily.itf_provider;

