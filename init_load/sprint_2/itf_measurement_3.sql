/*****************************************************
프로그램명  : ITF_MEASUREMENT_3.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      : 
소스 테이블(기본) : mnvitalt(V/S기록)
소스 테이블(참조) : apipdlst(입원내역),aoopdlst (외래예약)
프로그램 설명 :  vital을 선적재 한다.
        기간 적용 및 번호변경, 진료과 추가
        산업검진 추가
    BMI계산해서 적재
cnt : 
time : 
*****************************************************/
DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_MEASUREMENT_3;;

CREATE TABLE itfcdmpv532_daily.ITF_MEASUREMENT_3
AS
select
      patno                         as patient_id       --환자번호
    , null::float                   as order_no
    , null                          as order_cd         --처방코드
    , visit_gb                                          --내원구분
    , null                          as medical_dt       --진료일시
    , odt::text                     as order_dt         --처방일시
    , null                          as execute_dt       --검사실시일시
    , rectime::text                 as record_dt        --기록일시
    , medical_dept                  as medical_dept     --진료과
    , exam_cd                                           --검사코드
    , null                          as exam_sub_cd      --검사상세코드
    , null                          as specimen_no
    , null                          as specimen_cd
    , 'N'                           as antibiotic_yn
    , null                          as antibiotic_cd
    , null                          as examination_gb
    , null                          as relation_no
    , null                          as order_dr         --처방의
    , null                          as act_dr           --시행의
    , regid                         as recorder         --기록자
    , 'N'                           as prn_order_yn
    , 'N'                           as prn_act_yn
    , 'N'                           as cancel_yn
    , null                          as cancel_dt
    , 'Y'                           as valid_yn
    , null                          as result_operator  --결과(기호)
    , result_num::text                                   --결과(수치)
    , null                          as result_category  --결과(Category)
    , null                          as bacteria_cd
    , result_num::text              as result_txt       --결과(text)
    , result_unit                                       --결과수치단위
    , null                          as normal_max       --정상범위(상)
    , null                          as normal_min       --정상범위(하)
    , reference_gb
    , lastupdate_dt::text
    from (
    
        select
            patno
            , null as odt
            , rectime
            , case 
                when gs = 1 then 'BODYTEMP'
                when gs = 2 then 'PULSE'
                when gs = 3 then 'BREATH'
                when gs = 4 then 'BPH'
                when gs = 5 then 'BPL'
                when gs = 6 then 'SAO2'
                when gs = 7 then 'WEIGHT'
                when gs = 8 then 'HEIGHT'
                when gs = 9 then 'BMI'
                else null
            end as exam_cd
            , regid
            , editid
            , visit_gb
            , case 
                when gs = 1 then bodytemp
                when gs = 2 then pulse
                when gs = 3 then breath
                when gs = 4 then bph
                when gs = 5 then bpl
                when gs = 6 then sao2
                when gs = 7 then weight
                when gs = 8 then height
                when gs = 9 then CASE WHEN weight<>'0' AND height<>'0' THEN (weight::NUMERIC/((height::NUMERIC*height::NUMERIC)/10000)) end
                else null
            end as result_num
            , case 
                when gs = 1 then 'Cel'
                when gs = 2 then '/min'
                when gs = 3 then '/min'
                when gs = 4 then 'mm[Hg]'
                when gs = 5 then 'mm[Hg]'
                when gs = 6 then '%'
                when gs = 7 then 'kg'
                when gs = 8 then 'cm'
                when gs = 9 then 'kg/m2'
                else null
            end as result_unit
            , medical_dept
            , '바이탈'  as reference_gb
            ,edittime  as lastupdate_dt
          from (select  distinct
                         q.patno                    
                         ,q.rectime     --기록일시       
                         ,q.bodytemp    --체온         
                         ,q.pulse       --맥박         
                         ,q.breath      --호흡         
                         ,q.bph         --최고혈압       
                         ,q.bpl         --최저혈압       
                         ,q.sao2        --동맥혈산소포화도   
                         ,q.weight      --체중         
                         ,q.height      --신장         
                         ,q.regid       --등록자        
                         ,q.editid      --수정자
                         ,case when w.patno is null then 'O'
                                else  w.patfg
                            end as visit_gb
                         ,coalesce(e.meddept,w.meddept) as medical_dept --진료과
                         ,q.edittime 
                  from ods_daily.mnvitalt q 
                    left join ods_daily.apipdlst w 
                            on q.patno=w.patno 
                            and q.admtime = w.admtime
                    left join ods_daily.aoopdlst e
                            on q.patno = e.patno
                            and q.admtime::timestamp ::text= e.medtime
--                 where q.admtime::date BETWEEN TO_DATE('1999-04-01','YYYY-MM-DD') AND TO_DATE('2019-12-31','YYYY-MM-DD')
            ) a
           , (select gs FROM  generate_series(1, 9) AS gs) b
           
union all --산업검진

select
            patno
            , odt
            , null as rectime
            , case 
                when ocd = 'BTEMP' then 'BODYTEMP'
                when ocd in ('BBOD00021', 'BBOD0003') then 'PULSE'
                when ocd = 'BBOD0001' then 'BPH'
                when ocd = 'BBOD0002' then 'BPL'
                when ocd = 'BBOD0010' then 'WEIGHT'
                when ocd = 'BBOD0009' then 'HEIGHT'
                --when ocd = 'BBOD0016' then 'BMI'
                else null
            end as exam_cd
            , regid
            , editid
            , 'O' as visit_gb
            , case when ods_daily.is_float(rsltfld1) then rsltfld1 end::float as result_num
            , case 
                when ocd = 'BTEMP' then 'Cel'
                when ocd in ('BBOD00021', 'BBOD0003') then '/min'
                when ocd = 'BBOD0001' then 'mm[Hg]'
                when ocd = 'BBOD0002' then 'mm[Hg]'
                when ocd = 'BBOD0010' then 'kg'
                when ocd = 'BBOD0009' then 'cm'
                --when ocd = 'BBOD0016' then 'kg/m2'
                else null
            end as result_unit
            , 'INDM' as medical_dept
            , '산업검진' as reference_gb
            ,edittime  as lastupdate_dt
         from(
           select * from ods_daily.miordrdt
             --where ocd in ('BBOD0001', 'BBOD0002', 'BBOD00021','BBOD0003', 'BTEMP', 'BBOD0009', 'BBOD0010', 'BBOD0016')
             where ocd in ('BBOD0001', 'BBOD0002', 'BBOD00021','BBOD0003', 'BTEMP', 'BBOD0009', 'BBOD0010')
--                and odt::date BETWEEN TO_DATE('1999-04-01','YYYY-MM-DD') AND TO_DATE('2019-12-31','YYYY-MM-DD')
           ) a
           
UNION ALL


-- 같은 날에 키와 몸무게로 BMI계산
select
            patno
            , odt
            , null as rectime
            , 'BMI' as exam_cd
            , regid
            , editid
            , 'O' as visit_gb
            , CASE WHEN ods_daily.is_numeric(weight) AND ods_daily.is_numeric(height) 
                THEN CASE WHEN weight::NUMERIC<>0 and height::NUMERIC<>0 
                        THEN (weight::NUMERIC/((height::NUMERIC*height::NUMERIC)/10000)) END
                END as result_num
            , 'kg/m2' as result_unit
            , 'INDM' as medical_dept
            , '산업검진' as reference_gb
            , a.odt as lastupdate_dt 
         from (
            select
                patno
                , odt
                , regid
                , editid
                , max(CASE WHEN ocd='BBOD0010' THEN rsltfld1 else '' end) AS weight
                , max(CASE WHEN ocd='BBOD0009' THEN rsltfld1 else '' end) AS height
             from ods_daily.miordrdt
             where ocd in ('BBOD0009', 'BBOD0010')
--                and odt::date BETWEEN TO_DATE('1999-04-01','YYYY-MM-DD') AND TO_DATE('2019-12-31','YYYY-MM-DD')
              GROUP BY patno,odt,regid,editid
         ) a
           
    ) A where A.result_num is not null
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_measurement_3' , 'itf_measurement_3', count(*) as cnt
from itfcdmpv532_daily.itf_measurement_3 ;