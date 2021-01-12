/*****************************************************
프로그램명  : itf_visit_temp.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-04
수정일      : 
소스 테이블(기본) : aoopdlst(외래예약내역), mpreceit(검진접수내역), apipdlst(입원내역)
소스 테이블(참조) : apmovett(전과전실)
프로그램 설명 : 입원에서 한번이상 이동한 경우 전과전실 테이블에서 넣고 이동없이 끝난경우 입원내역에서만 넣음.

cnt : 
time : 
*****************************************************/

DROP TABLE if exists ods_daily.visit_temp;;

create table ods_daily.visit_temp as
select
          row_number() over (order by patient_id, coalesce(medical_dt::date, visit_dt2::date), case when visit_gb_new='O' then 1 when visit_gb_new='E' then 2 else 3 end)::bigint as visit_detail_id
        , row_number() over (order by patient_id, coalesce(medical_dt::date, visit_dt2::date), case when visit_gb_new='O' then 1 when visit_gb_new='E' then 2 else 3 end)::bigint as visit_occurrence_id
        , patient_id
        , medical_dt::timestamp
        , visit_dt2
        , discharge_yn
        , discharge_dt
        , medical_dept
        , icu_yn
        , medical_dr
        , admission_charge_dr
        , visit_path
        , visit_way
        , visit_gb
        , visit_gb_new
        , division_gb
        , medical_yn
        , transform_dt
        , cancel_yn
        , cancel_dt
        , discharge_type
        , discharge_path
        , transform_institution
        , reference_gb
        , lastupdate_dt
  from
( 

    select  --O
          patno as patient_id           --환자id
        , medtime as medical_dt         --내원일시
        , null as visit_dt2             --내원일시2
        , null as discharge_yn          --퇴원여부
        , null as discharge_dt          --퇴원일시
        , meddept as medical_dept       --진료과
        , null as icu_yn
        , meddr as medical_dr           --진료의
        , null as admission_charge_dr   --입원주치의
        , null as visit_path            --내원경로
        , null as visit_way             --내원수단
        , 'O' as visit_gb               --내원구분
        , 'O' as visit_gb_new           --내원구분_new
        , 'A' as division_gb              --분류구분
        , medyn as medical_yn           --진료여부
        , null as transform_dt          --응급입원전환일시
        , null as cancel_yn --취소일시
        , rejttime as cancel_dt --취소일시
        , null as discharge_type        --퇴원형태
        , null as discharge_path        --퇴원경로
        , null as transform_institution
        , '외래예약내역' as reference_gb
        , edittime as lastupdate_dt
    from ods_daily.aoopdlst   --외래예약내역    
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno

union all   --I,E

    select 
          patient_id                    --환자id
        , admission_dt as medical_dt    --내원일시
        , null as visit_dt2             --내원일시2
        , case when discharge_dt::date ='2999-12-31'::date
               then 'N'
               else 'Y' end as discharge_yn          --퇴원여부
        , discharge_dt                  --퇴원일시
        , medical_dept                  --진료과
        , wardno as icu_yn
        , charge_dr as medical_dr       --진료의사
        , null as admission_charge_dr   --입원주치의
        , admission_path as visit_path  --내원경로
        , null as visit_way             --내원수단
        , visit_gb                      --내원구분
        , visit_gb  as visit_gb_new     --내원구분_new 
        , 'A' as division_gb            --분류구분    
        , 'Y' as medical_yn             --진료여부
        , null as transform_dt          --응급입원전환일시
        , null as cancel_yn --취소일시
        , cancel_dt --취소일시
        , null as discharge_type        --퇴원형태
        , discharge_path                --퇴원경로
        , null as transform_institution
        , '입원내역' as reference_gb
        , null as lastupdate_dt
        from ods_daily.itf_visit_ei
        where 
            (de_patfg='I' 
           and visit_gb='E'
           and admission_dt2_e is not null
           and (cancel_dt is null and de_cancel_dt is null))=false 
        and (pre_patfg='E' 
            and visit_gb='I'
            and admission_dt2_i is not null
            and (cancel_dt is null and pre_cancel_dt is null))=false

union all    --E - EI

select 
   patient_id                   --환자id
 , admission_dt2_e as medical_dt--내원일시
 , admission_dt as visit_dt2    --내원일시2
 , case when discharge_dt::date ='2999-12-31'::date
       then 'N'
       else 'Y' end as discharge_yn --퇴원여부
 , discharge_dt                 --퇴원일시
 , medical_dept                 --진료과
 , wardno as icu_yn
 , charge_dr as medical_dr      --진료의사
 , null as admission_charge_dr  --입원주치의
 , admission_path as visit_path --내원경로
 , null as visit_way            --내원수단
 , visit_gb                     --내원구분 
 , 'EI' as visit_gb_new         --내원구분_new 
 , 'A' as division_gb           --분류구분    
 , 'Y' as medical_yn            --진료여부
 , admission_dt2_e as transform_dt         --응급입원전환일시
 , null as cancel_yn --취소일시
 , cancel_dt --취소일시
 , null as discharge_type       --퇴원형태
 , discharge_path               --퇴원경로
 , null as transform_institution
 , '입원내역' as reference_gb
 , null as lastupdate_dt
 from ods_daily.visit_ei
 where de_patfg='I' 
   and visit_gb='E'
   and admission_dt2_e is not null
   and (cancel_dt is null and de_cancel_dt is null)
    
union all    --I - EI

    select 
           patient_id                   --환자id
         , admission_dt as medical_dt--내원일시
         , admission_dt2_i as visit_dt2    --내원일시2
         , case when discharge_dt::date ='2999-12-31'::date
               then 'N'
               else 'Y' end as discharge_yn --퇴원여부
         , discharge_dt                 --퇴원일시
         , medical_dept                 --진료과
         , wardno as icu_yn
         , charge_dr as medical_dr      --진료의사
         , null as admission_charge_dr  --입원주치의
         , admission_path as visit_path --내원경로
         , null as visit_way            --내원수단
         , visit_gb                     --내원구분 
         , 'EI' as visit_gb_new         --내원구분_new 
         , 'A' as division_gb           --분류구분    
         , 'Y' as medical_yn            --진료여부
         , admission_dt as transform_dt --응급입원전환일시
         , null as cancel_yn --취소일시
         , cancel_dt --취소일시
         , null as discharge_type       --퇴원형태
         , discharge_path               --퇴원경로
         , null as transform_institution
         , '입원내역' as reference_gb
         , null as lastupdate_dt
         from ods_daily.visit_ei
         where pre_patfg='E' 
           and visit_gb='I'
           and admission_dt2_i is not null
           and (cancel_dt is null and pre_cancel_dt is null)
            
union all   -- 건강검진

  select distinct
          patno as patient_id           --환자id
        , case when ods_daily.is_timestamp2(odt_::date::text||' '||coalesce(otm,'00:00')||':00') 
                then odt_::date::text||' '||coalesce(otm,'00:00')||':00'
            else odt_
        end as  medical_dt              --내원일시
        , null as visit_dt2             --내원일시2
        , null as discharge_yn          --퇴원여부
        , null as discharge_dt          --퇴원일시
        , 'INDM' as medical_dept        --진료과
        , null as icu_yn
        , null as medical_dr            --진료의사
        , null as admission_charge_dr   --입원주치의
        , null as visit_path            --내원경로
        , null as visit_way             --내원수단
        , 'M' as visit_gb               --내원구분                
        , 'M' as visit_gb_new           --내원구분_new
        , 'A' as division_gb            --분류구분
        , 'Y' as medical_yn             --진료여부
        , null as transform_dt          --응급입원전환일시
        , null as cancel_yn --취소일시
        , candt_::date as cancel_dt --취소일시
        , null as discharge_type        --퇴원형태
        , null as discharge_path        --퇴원경로
        , null as transform_institution
        , '건강검진' as reference_gb
        , edittime_::date as lastupdate_dt
    from ods_daily.mpreceit  --검진접수내역 
   inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno

   union all    -- 산업검진

  select distinct
          patno as patient_id           --환자id
        , case when ods_daily.is_timestamp2(odt::date::text||' '||coalesce(otm,'00:00')||':00') 
                then odt::date::text||' '||coalesce(otm,'00:00')||':00'
            else odt
        end as  medical_dt              --내원일시
        , null as visit_dt2             --내원일시2
        , null as discharge_yn          --퇴원여부
        , null as discharge_dt          --퇴원일시
        , 'INDM' as medical_dept        --진료과
        , null as icu_yn
        , null as medical_dr            --진료의사
        , null as admission_charge_dr   --입원주치의
        , null as visit_path            --내원경로
        , null as visit_way             --내원수단
        , 'G' as visit_gb               --내원구분
        , 'G' as visit_gb_new           --내원구분_new
        , 'A' as division_gb            --분류구분
        , 'Y' as medical_yn             --진료여부
        , null as transform_dt          --응급입원전환일시
        , null as cancel_yn --취소일시
        , candt::date as cancel_dt --취소일시
        , null as discharge_type        --퇴원형태
        , null as discharge_path        --퇴원경로
        , null as transform_institution
        , '산업검진' as reference_gb
        , edittime::date as lastupdate_dt
    from ods_daily.mireceit a --접수내역  
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno

union all -- I,E 전과전실

select
          a.patno as patient_id         --환자id
        , a.admtime::text as medical_dt    --내원일시
        , substr(fromdate::text,0,12)||'23:59:59' as visit_dt2             --내원일시2
        , case when todate::date ='2999-12-31'::date
               then 'N'
               else 'Y' end as discharge_yn          --퇴원여부
        , todate::text as discharge_dt        --퇴원일시
        , meddept as medical_dept       --진료과
        , wardno as icu_yn
        , chadr as medical_dr       --진료의사
        , null as admission_charge_dr   --입원주치의
        , null as visit_path  --내원경로
        , null as visit_way             --내원수단
        , patfg as visit_gb             --내원구분
        , patfg as visit_gb_new         --내원구분_new
        , 'A' as division_gb            --분류구분    
        , 'Y' as medical_yn             --진료여부
        , null as transform_dt          --응급입원전환일시
        , null as cancel_yn --취소일시
        , null as cancel_dt             --취소일시
        , null as discharge_type        --퇴원형태
        , dschfg as discharge_path      --퇴원경로
        , null as transform_institution
        , '전과전실' as reference_gb
        , a.edittime as lastupdate_dt
  FROM ods_daily.apmovett a
       inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
       left join ods_daily.mnoutrpt b 
        on a.patno = b.patno
        and a.admtime = b.admtime
 where (a.patno ,a.admtime ) in (select patno,admtime from ods_daily.apmovett 
                                    group by patno,admtime having  count(*)>1)

) AS A
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'visit_temp' , 'visit_temp', count(*) as cnt
from itfcdmpv532_daily.visit_temp ;
