/*****************************************************
프로그램명   : ITF_PAYER_PLAN_PERIOD.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일  : 2020-12-04
수정일      : 
소스 테이블(기본) : apipcalt(입원계산내역), AOOPCALT(외래계산내역)
소스 테이블(참조) : 
프로그램 설명 : 
cnt : 
time : 
*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.itf_payer_plan_period;;

create table itfcdmpv532_daily.itf_payer_plan_period as
select 
     ROW_NUMBER() OVER(ORDER BY null)::BIGINT  AS UID
    , patient_id        -- 환자번호
    , visit_no          -- 방문고유번호
    , insurance_gb      -- 보험구분
    , null::varchar(10)                         as ins_stop_gb      -- 보험중단사유구분
    , min(ins_start_dt)                         as ins_start_dt     --유효시작일자
    , case when  max(ins_end_dt) < min(ins_start_dt) then  min(ins_start_dt)
        else   max(ins_end_dt) end              as ins_end_dt       --유효종료일자
    , null::timestamp                           as lastupdate_dt
from itfcdmpv532_daily.itf_payer_plan_period_temp
where 1=1
group by patient_id,visit_no,insurance_gb
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_payer_plan_period' , 'itf_payer_plan_period', count(*) as cnt
from itfcdmpv532_daily.itf_payer_plan_period ;
