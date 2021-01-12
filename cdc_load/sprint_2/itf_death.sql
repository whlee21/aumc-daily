/*****************************************************
프로그램명  : ITF_DEATH.sql
작성자      : 원종복
수정자      : 
최초 작성일 : 2020-12-07
수정일      : 
소스 테이블(기본) : ITF_DEATH(사망증명서 관련 view)
소스 테이블(참조) : 
프로그램 설명 : 사망관련 !!!!!!!!!!!!!!! regit_seq 1 인 것만 써야함.!!!!!!!!!!!
cnt : 
*****************************************************/


insert into itfcdmpv532_daily.itf_death 
SELECT * FROM (
	select
	  (b.uid::int + row_number() OVER (ORDER BY null) )::bigint as uid
	, patno :: varchar(50) AS patient_id
	, DIEDATE :: timestamp AS death_dt
	, dideadrs :: varchar(50) AS direct_cause
	, middeadrs :: varchar(50) AS mid_cause
	, predeadrs :: varchar(50) AS pre_cause
	, regtime :: timestamp AS regit_dt
	, row_number() OVER (PARTITION BY patno ORDER BY regtime) :: int AS death_seq
	, '사망증명서':: varchar(10) as reference_gb
	, a.edittime::timestamp as lastupdate_dt
	FROM (  SELECT patno
	        , diedate
	        , certyp
	        , dideadrs
	        , middeadrs
	        , predeadrs
	        , regtime
	        , edittime
	     FROM ods_daily.mmcermst
	    WHERE diedate IS NOT NULL
	      and certyp = '2' 
	      ) A , (select max(uid) as uid from itfcdmpv532_daily.itf_death ) b
) A WHERE death_seq = 1
and not exists (select 1 from itfcdmpv532_daily.itf_death c where a.patno = c.patno);;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_death' , 'itf_death', count(*) as cnt
from itfcdmpv532_daily.itf_death ;