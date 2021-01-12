DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_OBSERVATION_FROM_NEDIS;;
 
CREATE TABLE itfcdmpv532_daily.ITF_OBSERVATION_FROM_NEDIS as
     /* NEDIS 주호소 추가 */
     select
          ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '주호소' as  form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmimnsy observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmimnsy not in ('', '-')
     union all
     /* NEDIS 질병여부 추가 */
     select
          ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '질병여부' as  form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmidgkd observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmidgkd not in ('', '-')
     union all
     /* NEDIS 의도성여부 추가 */
     select
         ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '의도성여부' as  form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmiarcf observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmiarcf not in ('', '-')
     union all
     /* NEDIS 손상기전 추가 */
     select
          ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '손상기전' as  form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmiarcs observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmiarcs not in ('', '-')
     union all
     /* NEDIS 응급실 내원경로 추가 */
     select
          ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '내원경로' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmiinrt observation_item1
        , '' observation_item2
        , '' observation_item3
         , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmiinrt not in ('', '-')
     union all
     /* NEDIS 응급 진료결과 추가 */
     select
          ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '응급 진료결과' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmiemrt observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmiemrt not in ('', '-')
     
     union all
     /* NEDIS 입원 후 결과 추가 */
     select
          ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '입원 후 결과' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmidcrt observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmidcrt not in ('', '-')
     
     union all
     /* NEDIS 발병시간 추가 */
     select
         ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '발병시간' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , '' observation_item1
        , '' observation_item2
        , '' observation_item3
        , ptmiaktm as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.ptmiaktm not in ('', '-')
     union all
      /* NEDIS 내원수단 추가 */
     select
         ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '내원수단' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , PTMIINMN observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and a.PTMIINMN not in ('', '-')
     union all
      /* NEDIS 최초 중증도 분류 결과 추가 */
     select
         ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , '최초 중증도 분류 결과' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmikts1 observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and ptmikts1 not in ('' , '-')
     union all
      /* NEDIS AVPU 추가 */
     select
         ptmiidno as patno
        , b.ADMTIME as medical_dt
        , b.ADMTIME as record_dt
        , null as order_dt
        , 'E' as visit_gb
        , 'TE' as INSERT_TYPE
        , 'AVPU' as form_nm
        , ptmidept as medical_dept
        , b.chadr as medical_dr
        , ptmiresp observation_item1
        , '' observation_item2
        , '' observation_item3
        , 'Y' as result_cd_txt
        , null as result_num
     from ods_daily.emihptmi a , ods_daily.APIPDLST b
          , (select patno from ods_daily.target_person group by patno )  tp
     where 1=1
     and a.ptmiidno = tp.patno
     and b.patno = a.ptmiidno
     and b.ADMTIME::timestamp = to_timestamp( concat(ptmiindt ,ptmiintm), 'YYYYMMDDHH24MI')
     and ptmiresp not in ('' , '-')
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation_from_nedis' , 'itf_observation_from_nedis', count(*) as cnt
from itfcdmpv532_daily.itf_observation_from_nedis ;
