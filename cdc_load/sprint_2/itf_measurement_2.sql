/*****************************************************
프로그램명  : ITF_MEASUREMENT_2.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      : 
소스 테이블(기본) : SPCOLLMT(검체채취내역), SPCOLLDT(검체채취처방내역), MMCOMRQT(통합검사의뢰서), SLTRSTMT(통합검사결과내역)
소스 테이블(참조) :  VIEW_PROVIDER(의료진정보), SLDSPCCT(지정검체코드관리),  SLREFERT(검사결과기준치관리)
프로그램 설명 :  병리검사 결과를 선적재 한다.
cnt:
*****************************************************/

DROP TABLE IF EXISTS ITFCDMPV532_daily.ITF_MEASUREMENT_2;;

CREATE TABLE ITFCDMPV532_daily.ITF_MEASUREMENT_2
as
 SELECT
      a.patno                               as patient_id
    , b.ordseqno                            as order_no
    , b.ordcode                             as order_cd
    , a.patfg                               as visit_gb
    , a.meddate                             as medical_dt
    , a.orddate                             as order_dt
    , a.spcdate                             as execute_dt
    , coalesce(c.regtime ,b.regtime )       as record_dt
    , a.meddept                             as medical_dept
    , b.ordcode                             as exam_cd
    , null                                  as exam_sub_cd
    , a.spcno                               as specimen_no
    , c.optvalue4                           as specimen_cd
    , 'N'                                   as antibiotic_yn
    , null                                  as antibiotic_cd
    , null                                  as examination_gb
    , null                                  as relation_no
    , a.orddr                               as order_dr
    , a.collid                              as act_dr
    , coalesce(c.regid ,b.regid )           as recorder
    , 'N'                                   as prn_order_yn
    , 'N'                                   as prn_act_yn
    , case when a.procstat = '*' then 'Y' else 'N' end as cancel_yn
    , null                                  as cancel_dt
    , 'Y'                                   as valid_yn
    ,null                                   as result_operator 
    ,null                                   AS RESULT_NUM
    ,CASE WHEN trim(D.RSLTTEXT) = 'Positive' THEN 'Positive'
          WHEN trim(D.RSLTTEXT) = 'Negative' THEN 'Negative'
      END                                   as result_category
    ,null                                   as bacteria_cd
    ,D.RSLTTEXT                             as result_txt
    ,null                                   as result_unit
    ,null                                   as normal_max
    ,null                                   as normal_min
    ,'병리검사'                               as reference_gb
    , c.edittime                            as lastupdate_dt
  FROM ods_daily.SPCOLLMT A
  inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
  INNER JOIN ods_daily.SPCOLLDT B
        ON B.SPCDATE = A.SPCDATE
           AND B.SPCNO = A.SPCNO
           AND B.SPCSEQ = A.SPCSEQ
  LEFT JOIN ods_daily.MMCOMRQT C
        ON B.PATNO = C.PATNO
            AND B.ORDDATE = C.ORDDATE
            AND B.ORDSEQNO = C.ORDSEQNO
            AND '6' = C.REQTYPE
  LEFT JOIN ods_daily.SLTRSTMT D
        ON D.PATNO = B.PATNO
            AND D.ORDDATE = B.ORDDATE
            AND D.ORDSEQNO = B.ORDSEQNO
            AND D.EXAMCODE = B.ORDCODE
--  inner join ods_daily.itf_person  e
--        on a.patno = e.patno 
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_measurement_2' , 'itf_measurement_2', count(*) as cnt
from ITFCDMPV532_daily.itf_measurement_2 ;
