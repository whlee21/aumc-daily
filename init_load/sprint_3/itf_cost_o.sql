/*****************************************************
프로그램명  : ITF_COST_O.sql
작성자      : Won Jong Bok
수정자      :  
최초 작성일 : 2020-12-04
수정일      : 
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 : 외래 Cost내역
               
cnt : 
time : 

*****************************************************/

DROP TABLE if exists itfcdmpv532_daily.ITF_COST_O;;

create table itfcdmpv532_daily.ITF_COST_O AS
SELECT
     null::varchar(50) as visit_no -- 방문고유번호
     , a.patno::varchar(50) as patient_id -- 환자번호
     , a.ordtable::varchar as order_tb -- 처방테이블
     , a.meddate::timestamp as medical_dt -- 진료일시
     , a.orddate::timestamp as order_dt -- 처방일시
     , a.ordseqno::varchar(50) as order_seq -- 처방순번
     , a.ordcode::varchar(50) as order_cd -- 처방코드
     , a.sugacode::varchar(50) as order_sub_cd -- 처방상세코드
     , a.pattyp::varchar(10) as insurance_gb -- 보험구분
     , a.patfg::varchar(10) as visit_gb -- 내원구분
     , a.meddept::varchar(50) as medical_dept -- 진료과
     , coalesce (
                  insamt01 * ownrat::decimal / 100
        , 0
       )::numeric as patient_pay_amt -- 환자부담금
     , coalesce (
             (insamt01 + insamt02) - (insamt01) * ownrat::decimal / 100
            + yschaamt::decimal
        , 0
       )::numeric as insurance_pay_amt -- 공단부담금
     , a.rcpamt::numeric as total_pay_amt -- 총액
     , 'O'||LPAD (a.naccucd, 2, '0')::varchar as cost_gb -- 비용구분
/*     , (SELECT codename
          FROM ods.itf_cscomcdt
         WHERE midgcode = 'AO540'
           AND smallgcode = LPAD (a.naccucd, 2, '0'))::varchar as cost_gb -- 비용구분*/
     , 'N'::varchar(50) as drg_gb -- DRG구분
     , null::varchar(50) as drg_cd -- DRG코드
     , 'won'::varchar(10) as currency -- 화폐단위
     , 'N'::varchar(10) as cancel_yn -- 취소여부
     , '외래 계산 내역'::varchar(10) as reference_gb
     , edittime::timestamp as lastupdate_dt
  FROM (SELECT a.patno
             , a.meddate
             , a.ordtable
             , a.orddate
             , a.ordseqno
             , a.ordcode
             , a.sugacode
             , a.naccucd
             , a.rcpamt
             , a.yschaamt
             , a.pattyp
             , a.typecd
             , a.ownrat
             , CASE
                  WHEN a.typecd NOT IN ('ST', '99')
                   AND (a.instyp = '0'
                     OR (a.instyp = '2'
                     AND a.ownrat != '0')
                     OR ( (a.instyp || a.insintyp = '76'
                        OR a.execdate::date >= TO_DATE ('2019-03-01', 'YYYY-MM-DD'))
                     AND a.selrat > 0
                     AND a.largcd IN ('AA', 'BB', 'DD', 'EE'))) THEN
                     a.rcpamt - a.yschaamt::decimal
                  ELSE
                     0
               END
                  insamt01
             , CASE
                  WHEN a.typecd NOT IN ('ST', '99')
                   AND a.instyp = '2'
                   AND a.ownrat = '0' THEN
                     a.rcpamt - a.yschaamt::decimal
                  ELSE
                     0
               END
                  insamt02
             , a.patfg
             , edittime
             , meddept
          FROM (
          select * from itfcdmpv532_daily.ITF_COST_O_1
          union all
          select * from itfcdmpv532_daily.ITF_COST_O_2
          union all
          select * from itfcdmpv532_daily.ITF_COST_O_3
          union all
          select * from itfcdmpv532_daily.ITF_COST_O_4
          )a ) a
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_o' , 'itf_cost_o', count(*) as cnt
from itfcdmpv532_daily.itf_cost_o ;