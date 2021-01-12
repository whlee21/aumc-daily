/*****************************************************
프로그램명  : itf_condition_occurrence.sql
작성자      : Won Jong Bok
수정자      :  
최초 작성일 : 2020-12-07
수정일      : 
소스 테이블(기본) : mmpdiagt(환자진단내역), smddiagt(퇴원진단명), smcancht(암환자등록)
소스 테이블(참조) : AOOPDLST(외래예약내역), APIPDLST(입원내역)
프로그램 설명 : 입원,외래 환자의진단 관련 데이터 적재 
            
*****************************************************/


DROP TABLE if exists itfcdmpv532_daily.itf_condition_occurrence;;



CREATE  TABLE itfcdmpv532_daily.itf_condition_occurrence as
   SELECT
        ROW_NUMBER() OVER (ORDER BY null) :: BIGINT AS uid
            , NULL ::   varchar(50) AS visit_no
            , a.patno :: varchar(50) AS patient_id
            , diagnosis_cd::varchar(20) as diagnosis_cd
            , null ::text  as symptom
            , null ::timestamp as  diag_dt
            , A.medical_dt ::   timestamp
            , A.admission_dt :: timestamp
            , coalesce(A.discharge_dt::timestamp, now() ) ::    timestamp as discharge_dt
            , coalesce(A.main_yn,'N') :: varchar(1) as main_yn
            , A.chadr:: varchar(50) AS medical_dr
            , A.medical_dept :: varchar(50) medical_dept
            , A.cancel_yn :: varchar(1) cancel_yn
            , A.cancel_dt :: timestamp cancel_dt
            , A.visit_gb :: varchar(1) visit_gb
            , A.stop_reason :: varchar(20) stop_reason
            , A.rule_out_yn :: varchar(1) rule_out_yn
            , A.discharge_diag_yn   :: varchar(1) discharge_diag_yn
            , condition_gb
            , reference_gb
            , lastupdate_dt
            , now() as etl_dt
FROM (
    SELECT
        A.PATNO
        ,A.DIAGCODE AS diagnosis_cd
        ,a.meddate::varchar AS medical_dt
        ,NULL::varchar AS admission_dt
        ,NULL::varchar AS discharge_dt
        ,A.MAINYN AS main_yn
        ,A.CHADR
        ,A.MEDDEPT AS medical_dept
        ,CASE WHEN NULLIF(B.REJTTIME::varchar, '') IS NULL THEN 'N' ELSE 'Y' END cancel_yn
        ,B.REJTTIME::varchar AS cancel_dt
        ,A.PATFG AS visit_gb
        ,NULL AS stop_reason
        ,CASE WHEN A.impressyn = 'Y' THEN 'Y' ELSE 'N' END AS rule_out_yn
        ,A.dscdiayn AS discharge_diag_yn
        , 'ICD10' condition_gb
        , '환자진단내역' reference_gb
        , a.edittime::timestamp as lastupdate_dt
    FROM ods_daily.mmpdiagt A
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
    LEFT JOIN ods_daily.aoopdlst B ON A.patno = B.patno AND A.meddate = B.meddate AND A.meddept = B.meddept AND A.chadr = B.meddr
        --and  B.MEDTIME < '2020-06-01'
    WHERE A.PATFG IN ('G','H','M','O')

    UNION ALL

    SELECT
        A.PATNO
        ,A.DIAGCODE AS diagnosis_cd
        ,A.meddate::varchar  AS medical_dt
        ,case when A.patfg in ('I','D', 'E') then coalesce(B.admtime,A.meddate) end ::varchar AS admission_dt
        ,B.dschtime::varchar AS discharge_dt
        ,A.MAINYN AS main_yn
        ,A.CHADR
        ,A.MEDDEPT AS medical_dept
        ,CASE WHEN B.REJTTIME::varchar IS NULL THEN 'N' ELSE 'Y' END cancel_yn
        ,B.REJTTIME::varchar AS cancel_dt
        ,A.PATFG AS visit_gb
        ,NULL AS stop_reason
        ,CASE WHEN A.impressyn = 'Y' THEN 'Y' ELSE 'N' END AS rule_out_yn
        ,A.dscdiayn AS discharge_diag_yn
        , 'ICD10' condition_gb
        , '환자진단내역' reference_gb
        , a.edittime::timestamp as lastupdate_dt
    FROM ods_daily.mmpdiagt A
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
    LEFT JOIN ods_daily.apipdlst B ON A.patno = B.patno AND A.meddate = B.admtime AND A.patfg = B.patfg
    WHERE A.PATFG IN ('I','E','D')

    UNION ALL

    SELECT
        A.PATNO
        ,A.DIAGCODE AS diagnosis_cd
        ,B.admtime::varchar AS medical_dt
        ,B.admtime::varchar AS admission_dt
        ,B.dschtime::varchar AS discharge_dt
        ,A.MAINYN AS main_yn
        ,A.CHADR
        ,A.deptcode AS medical_dept
        ,CASE WHEN B.REJTTIME IS NULL THEN 'N' ELSE 'Y' END cancel_yn
        , B.REJTTIME ::varchar AS cancel_dt
        ,'I' AS visit_gb
        ,NULL AS stop_reason
        ,'N' AS rule_out_yn
        ,'Y' AS discharge_diag_yn
        , 'ICD10' condition_gb
        , '퇴원진단명' reference_gb
        , a.edittime::timestamp as lastupdate_dt
    FROM ods_daily.smddiagt A
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
    LEFT JOIN ods_daily.apipdlst B ON A.patno = B.patno AND A.deptcode = B.meddept AND a.dschdate::date = B.dschtime::date

    union all

    select
        patno
        , substring(replace(diagcode,'M',''),1, 4)||'/'||substring(replace(diagcode,'M',''),5,1)  ||'-'|| organcd AS diagnosis_cd
        --, diagcode
        ,case when admdate is not null then admdate
          else dschdate  end AS medical_dt
        , case when admdate is not null then admdate
               else dschdate end AS admission_dt
        , dschdate AS discharge_dt
        , null AS main_yn
        , chadr
        , deptcode AS medical_dept
        , 'N' AS cancel_yn
        , null AS cancel_dt
        , patfg AS visit_gb
        , null AS stop_reason
        , 'N' AS rule_out_yn
        , 'N' AS discharge_diag_yn
        , 'ICD-O-3' condition_gb
        , '암환자등록' reference_gb
        , edittime::timestamp as lastupdate_dt
      from ods_daily.smcancht a
      inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
) A
;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_condition_occurrence' , 'itf_condition_occurrence', count(*) as cnt
from itfcdmpv532_daily.itf_condition_occurrence ;
