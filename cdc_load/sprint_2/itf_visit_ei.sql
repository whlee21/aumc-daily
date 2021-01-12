/*****************************************************
프로그램명  : ITF_VISIT_EI.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      : 
소스 테이블(기본) : apipdlst(입원내)
소스 테이블(참조) :
프로그램 설명 :  EI구분용 선적재 테이블, 
    
NEDIS의 내원수단 (입원경로)
1   119 구급차
2   의료기관 구급차
3   기타 구급차
4   경찰차 등 공공차량
5   항공 이송
6   기타 자동차
7   도보
8   기타
9   미상
    
    
cnt:
time: 
*****************************************************/
drop table if exists ods_daily.ITF_VISIT_EI;;

CREATE TABLE ods_daily.ITF_VISIT_EI as
select 
        a.patno ::text as patient_id                --환자id
        , a.admtime ::text as admission_dt      --입원일시
        , case
            when (a.admtime::date - lag(a.admtime) over (partition by a.patno order by a.admtime::timestamp)::date ) < 26 then
                case 
                    when lag(patfg) over(partition by a.patno order by a.admtime::timestamp) ='E' then
                        case
                            when ERTIME is not null then ERTIME
                            when (a.admtime::date - lag(a.admtime) over (partition by a.patno order by a.admtime::timestamp)::date ) < 3 
                                then lag(a.admtime) over (partition by a.patno order by a.admtime::timestamp)
                        else null end
                else null end
            else null
          end ::text as admission_dt2_I     --입원일시2(응급실일시)
        , case
            when (lead(a.admtime) over (partition by a.patno order by a.admtime::timestamp):: date -a.admtime::date ) < 26 then
                case
                    when lead(patfg) over(partition by a.patno order by a.admtime::timestamp) ='I' then
                        case
                            when ERTIME is not null then ERTIME
                            when lead(ertime) over (partition by a.patno order by a.admtime::timestamp) is not null
                                then lead(a.admtime) over (partition by a.patno order by a.admtime::timestamp)
                            when (lead(a.admtime) over (partition by a.patno order by a.admtime::timestamp):: date -a.admtime::date ) < 3
                                then lead(a.admtime) over (partition by a.patno order by a.admtime::timestamp)
                        else null end
                 else null end
            else null
          end ::text as admission_dt2_E         --입원일시2(입원일시)
        , dschtime ::text as discharge_dt       --퇴원일시
        , meddept ::text as medical_dept        --진료과
        , chadr ::text as charge_dr         --주치의
        , case when patfg !='E' then admpath
            else c.ptmiinmn
        end ::text as admission_path    --입원경로
        , patfg ::varchar(1) as visit_gb --내원구분
        , dschfg as discharge_path              --퇴원경로
        , rejttime as cancel_dt  --취소일시
        , lag(patfg) over(partition by a.patno order by a.admtime::timestamp)::text as pre_patfg --이전로우 patfg
        , lead(patfg) over(partition by a.patno order by a.admtime::timestamp)::text as de_patfg  --다음로우 patfg
        , wardno
        , lag(rejttime) over(partition by a.patno order by a.admtime::timestamp)::text as pre_cancel_dt --이전로우 cancel_dt
        , lead(rejttime) over(partition by a.patno order by a.admtime::timestamp)::text as de_cancel_dt --다음로우 cancel_dt
    from ods_daily.apipdlst a
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
        left join ods_daily.mnoutrpt b 
            on a.patno = b.patno
            and a.admtime = b.admtime
        left join ods_daily.emihptmi c
            on a.patno = c.ptmiidno
            and a.admtime::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
  -- where a.admtime::date BETWEEN TO_DATE('1999-04-01','YYYY-MM-DD') AND TO_DATE('2018-12-31','YYYY-MM-DD')
;;

   -----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_visit_ei' , 'itf_visit_ei', count(*) as cnt
from itfcdmpv532_daily.itf_visit_ei ;

