/*****************************************************
프로그램명  : ITF_CARE_SITE.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      :
소스 테이블(기본) : ps3010 (부서정보)
소스 테이블(참조) : 
프로그램 설명 : 부서정보  - 변경 적재
cnt: 
*****************************************************/

update itfcdmpv532_daily.itf_care_site as a 
set 
	  dept_nm = b.dept_kor_nm
	, meddept_cd = nullif(b.spdept, 'NULL')::varchar(10) 
	, meddept_nm = b.dept_kor_nm
from ods_daily.ps3010 b
where 1=1
and a.dept_cd = b.dept_cd 
;; 

insert into itfcdmpv532_daily.itf_care_site 
SELECT
	 ( b.rn + ROW_NUMBER() over(order by 1) ) :: BIGINT AS uid
	, dept_cd :: varchar(20)
	, dept_kor_nm :: varchar(100) as dept_nm
    , '165' ::  varchar(9) AS zip_code_3
    , nullif(spdept, 'NULL')::varchar(10) as meddept_cd
    , dept_kor_nm :: varchar(100) as meddept_nm
    , now() as etl_dt
FROM ods_daily.ps3010 a, (select max(uid) as uid from itfcdmpv532_daily.itf_care_site) b
where use_fg = 'Y'
and not exists (select 1 from itfcdmpv532_daily.itf_care_site c where 1=1 and a.dept_cd = c.dept_cd)
;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_care_site' , 'itf_care_site', count(*) as cnt
from itfcdmpv532_real.itf_care_site ;
