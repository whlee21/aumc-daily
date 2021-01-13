/*****************************************************
�봽濡쒓렇�옩紐�  : ITF_PROVIDER.sql
�옉�꽦�옄      : Won Jong Bok
�닔�젙�옄      : 
理쒖큹 �옉�꽦�씪 : 2020-12-03
�닔�젙�씪      :
�냼�뒪 �뀒�씠釉�(湲곕낯) : csusermt (吏곸썝�젙蹂�)
�냼�뒪 �뀒�씠釉�(李몄“) : cscomcdt(怨듯넻肄붾뱶) , ps3010(遺��꽌�젙蹂�)
�봽濡쒓렇�옩 �꽕紐� : �쓽猷뚯쭊�젙蹂� 珥덇린 �쟻�옱
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
	    --a.userid :: bigint AS uid
	    a.cdm_userid :: bigint AS uid
	  --, a.userid:: VARCHAR(50) AS provider_id
	  , a.cdm_userid:: VARCHAR(50) AS provider_id
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

