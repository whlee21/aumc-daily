/*****************************************************
프로그램명  : itf_payer_plan_period_temp.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 :  payer plan period 정보 선적재
cnt: 
time: 
*****************************************************/


DROP TABLE IF EXISTS itfcdmpv532_daily.itf_payer_plan_period_temp;;

create table itfcdmpv532_daily.itf_payer_plan_period_temp as
select 
    aa.patno::varchar(50)                 as patient_id       -- 환자번호   
    , (aa.patno||AA.order_dt::varchar||AA.order_seq||AA.order_cd) ::varchar(50) as visit_no        -- 방문고유번호   
    , AA.pattyp ::varchar(10)                   as insurance_gb     -- 보험구분  
    , AA.ins_start_dt    --유효시작일자  
    , AA.ins_end_dt      --유효종료일자    
    from(
        SELECT 
            patno
            ,pattyp
            ,meddate::timestamp as ins_start_dt    --유효시작일자
            ,meddate::timestamp as ins_end_dt      --유효종료일자
            ,ordcode as order_cd
            ,orddate::timestamp as order_dt
            ,ordseqno as order_seq
          from ods_daily.aoopcalt
          WHERE rejttime is null
        union all       
        SELECT 
            a.patno
            ,a.pattyp ::varchar(10) as insurance_gb    --보험구분
            ,a.admtime::timestamp as ins_start_dt    --유효시작일자
            ,case when (select dschtime from ods_daily.apipdlst b where a.patno=b.patno 
                                    and a.admtime = b.admtime::text limit 1)::date='2999-12-31'::date 
                                    or (select dschtime from ods_daily.apipdlst b where a.patno=b.patno 
                                    and a.admtime = b.admtime::text limit 1) is null then a.meddate::Date
                  when (select dschtime::Date from ods_daily.apipdlst b where a.patno=b.patno 
                                    and a.admtime = b.admtime::text limit 1) > c.todate::date then c.todate::date                  
                  else (select dschtime::Date from ods_daily.apipdlst b where a.patno=b.patno 
                                    and a.admtime = b.admtime::text limit 1)
              end ::timestamp as ins_end_dt      --유효종료일자
            ,ordcode as order_cd
            ,orddate::timestamp as order_dt
            ,ordseqno as order_seq
          from ods_daily.apipcalt a
          inner join ods_daily.apchangt c 
          on a.patno = c.patno
          AND a.admtime = c.admtime::text
          AND a.pattyp = c.pattyp
          AND a.typecd = c.typecd
          AND a.execdate::date BETWEEN c.fromdate::date AND c.todate::date
          WHERE rejttime is null
  ) AA
where 1=1
;;



-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_payer_plan_period_temp' , 'itf_payer_plan_period_temp', count(*) as cnt
from itfcdmpv532_daily.itf_payer_plan_period_temp ;  