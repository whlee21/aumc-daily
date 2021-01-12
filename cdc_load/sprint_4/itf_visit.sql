/*****************************************************
프로그램명  : ITF_VISIT.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      : 
소스 테이블(기본) : aoopdlst(외래예약내역), mpreceit(검진접수내역), apipdlst(입원내역)
소스 테이블(참조) : apmovett(전과전실)

cnt:

temp  

EI : 

입원내역        총 : 3,009,381
검진접수내역      총 : 867,056
접수내역        총 : 1,824,161
외래예약내역      총 : 31,379,217
전과전실        총 : 3,901,978
*****************************************************/

DROP TABLE if exists itfcdmpv532_daily.itf_visit;;

create table itfcdmpv532_daily.itf_visit as
select
          A.visit_detail_id
        , A.visit_occurrence_id
        , null                  ::varchar(50)   as visit_no
        , B.cdm_patno           ::varchar(50)   as patient_id
        , A.medical_dt          ::timestamp
        , A.visit_dt2           ::timestamp
        , A.discharge_yn        ::varchar(1)
        , A.discharge_dt        ::timestamp
        , A.medical_dept        ::varchar(20)
        , A.icu_yn              ::varchar(20)
        , C.cdm_empno           ::varchar(20)   as medical_dr
        , D.cdm_empno           ::varchar(20)   as admission_charge_dr
        , A.visit_path          ::varchar(10)
        , A.visit_way           ::varchar(10)
        , case when icu_yn IN
              ('091S', '3CCU', '5ICU', 'EICU', 'ICUA'
              , 'ICUB', 'NCUA', 'NCUB', 'NICUA', 'NICUB'
              , 'TICUA', 'TICUB', 'TICUC')
            then 'C'
           when coalesce(F.visit_gb_new, A.visit_gb_new) ='EI' then 'EI'
               else visit_gb end ::varchar(10)  as visit_gb
        , coalesce(F.visit_gb_new, A.visit_gb_new)          ::varchar(10) AS visit_gb_new
        , A.division_gb         ::varchar(2)
        , A.medical_yn          ::varchar(1)
        , A.transform_dt        ::timestamp
        , A.cancel_yn           ::varchar(1)
        , A.cancel_dt           ::timestamp
        , null                  ::int as visit_occurrence_seq
        , A.discharge_type      ::varchar(10)
        , A.discharge_path      ::varchar(10)
        , A.transform_institution ::varchar(10)
        , A.reference_gb        ::varchar(50)
        , A.lastupdate_dt       ::timestamp
  from ods_daily.itf_visit_temp A
    left join (select visit_occurrence_id,'EI' as visit_gb_new from ods_daily.itf_visit_temp where visit_gb_new='EI' and visit_gb='I' group by visit_occurrence_id) F
            on A.visit_occurrence_id = F.visit_occurrence_id
  where  medical_dt >= '1994-01-01'
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_visit' , 'itf_visit', count(*) as cnt
from itfcdmpv532_daily.itf_visit ;
