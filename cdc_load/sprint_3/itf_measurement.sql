/*****************************************************
프로그램명  : ITF_MEASUREMENT.SQL
작성자     : Won Jong Bok
수정자     : 
최초 작성일 : 2020-12-07
수정일     : 

cnt : 
time : 
*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_MEASUREMENT;;

CREATE TABLE itfcdmpv532_daily.ITF_MEASUREMENT
AS
SELECT
      ROW_NUMBER() OVER(ORDER BY null)::BIGINT AS UID
    , null              ::varchar(50)               as visit_no         , -- 내원번호
     p.cdm_patno       ::varchar(50)               as patient_id       , -- 환자번호
     a.order_no        ::varchar(50)               as order_no         , -- 처방고유번호
     a.order_cd        ::varchar(50)               as order_cd         , -- 처방코드
     a.visit_gb        ::varchar(20)               as visit_gb         , -- 내원구분
     a.medical_dt      ::timestamp                 as medical_dt       , -- 진료일시
     a.order_dt        ::timestamp                 as order_dt         , -- 처방일시
     a.execute_dt      ::timestamp                 as execute_dt       , -- 검사실시일시
     a.record_dt       ::timestamp                 as record_dt        , -- 기록일시
     a.medical_dept    ::varchar(50)               as medical_dept     , -- 진료과
     a.exam_cd         ::varchar(50)               as exam_cd          , -- 검사코드
     coalesce(a.exam_sub_cd, '') ::varchar(50)     as exam_sub_cd      , -- 검사상세코드
     a.specimen_no     ::varchar(50)               as specimen_no      , -- 검체고유번호
     a.specimen_cd     ::varchar(50)               as specimen_cd      , -- 검체코드
     a.antibiotic_yn   ::varchar(1)                as antibiotic_yn    , -- 항생제검사여부
     a.antibiotic_cd   ::varchar(50)               as antibiotic_cd    , -- 항생제코드
     a.examination_gb  ::varchar(50)               as examination_gb   , -- 항생제검사방법
     a.relation_no     ::varchar(50)               as relation_no      , -- 균항생제연결번호
     e1.cdm_empno      ::varchar(50)               as order_dr         , -- 처방의
     e2.cdm_empno      ::varchar(50)               as act_dr           , -- 시행의
     e3.cdm_empno      ::varchar(50)               as recorder         , -- 기록자
     a.prn_order_yn    ::varchar(1)                as prn_order_yn     , -- prn처방여부
     a.prn_act_yn      ::varchar(1)                as prn_act_yn       , -- prn실시여부
     a.cancel_yn       ::varchar(1)                as cancel_yn        , -- 취소여부
     a.cancel_dt       ::timestamp                 as cancel_dt        , -- 취소일자
     a.valid_yn        ::varchar(50)                as valid_yn         , -- 유효성여부
     a.result_operator ::varchar(50)               as result_operator  , -- 결과(기호)
     a.result_num      ::float                     as result_num       , -- 결과(수치)
     a.result_category ::varchar(50)               as result_category  , --결과(category)
     a.bacteria_cd     ::varchar(50)               as bacteria_cd      , --균코드
     a.result_txt      ::text                      as result_txt       , -- 결과(text)
     a.result_unit     ::varchar(50)               as result_unit      , -- 결과수치단위
     a.normal_max      ::float                     as normal_max       , -- 정상범위(상)
     a.normal_min      ::float                     as normal_min       , -- 정상범위(하)
     a.reference_gb    ::varchar(50)               as reference_gb     , -- 출처구분
     a.lastupdate_dt   ::timestamp                 as lastupdate_dt    -- 최종수정일자
FROM (
    SELECT * FROM (
        SELECT * FROM itfcdmpv532_daily.ITF_MEASUREMENT_1
        UNION ALL
        SELECT * FROM itfcdmpv532_daily.ITF_MEASUREMENT_2
        UNION ALL
        SELECT * FROM itfcdmpv532_daily.ITF_MEASUREMENT_3
--        observation으로 이동 (NEDIS) 뭉침
--        UNION ALL
--        SELECT *FROM itfcdmpv532_daily.ITF_MEASUREMENT_4
--        UNION ALL
--        SELECT *FROM itfcdmpv532_daily.ITF_MEASUREMENT_5
        UNION ALL
        SELECT * FROM itfcdmpv532_daily.ITF_MEASUREMENT_6
        UNION ALL
        SELECT * FROM itfcdmpv532_daily.ITF_MEASUREMENT_7
        UNION ALL  --추가 UACR 요청 안혜리프로 2020.10.28
        select
         -- row_number () over(order by null ) as uid
          --, t1.visit_no
           t1.patient_id
          , t1.order_no
          , 'UACR01' as order_cd
          , t1.visit_gb
          , t1.medical_dt
          , t1.order_dt
          , t1.execute_dt
          , t1.record_dt
          , t1.medical_dept
          , 'UACR01' as exam_cd
          , t1.exam_sub_cd
          , t1.specimen_no
          , t1.specimen_cd
          , t1.antibiotic_yn
          , t1.antibiotic_cd
          , t1.examination_gb
          , t1.relation_no
          , t1.order_dr
          , t1.act_dr
          , t1.recorder
          , t1.prn_order_yn
          , t1.prn_act_yn
          , t1.cancel_yn
          , t1.cancel_dt
          , t1.valid_yn
          , t1.result_operator
         -- , t2.result_num
         -- , t1.result_num  --
          , case when t1.result_num::float > 0 then t1.result_num::float/(t2.result_num::float/1000) else null end::varchar as result_num
          , t1.result_category::varchar
          , t1.bacteria_cd
          , case when t1.result_num::float > 0 then t1.result_num::float/(t2.result_num::float/1000)  else null end::varchar as result_txt
          , '㎍/㎎Cr' result_unit
          , t1.normal_max
          , t1.normal_min
          , t1.reference_gb
          , t1.lastupdate_dt
      from
      (
          select
              *
          from
          itfcdmpv532_daily.itf_measurement_1
          where 1=1
      ) t1 -- Microalbumin (Urine)
      ,
      (
          select * from
          itfcdmpv532_daily.itf_measurement_1
          where 1=1
          and order_cd in (
            'C3750002'
          , 'C3750002'
          , 'C375000201'
          , 'C3750002'
          , 'C3750002A'
          )
      ) t2  -- Creatinine
      where 1=1
      and t1.patient_id = t2.patient_id
      and t1.execute_dt::date = t2.execute_dt::date
      and t1.specimen_cd = t2.specimen_cd
        ) Q
      WHERE COALESCE(execute_dt, record_dt, order_dt, medical_dt)::DATE >= TO_DATE('1994-01-01','YYYY-MM-DD')
) a

;;



-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_measurement' , 'itf_measurement', count(*) as cnt
from itfcdmpv532_daily.itf_measurement ;
