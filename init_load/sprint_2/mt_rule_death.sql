drop table if exists itfcdmpv532_real.mt_rule_death;

create table itfcdmpv532_real.mt_rule_death as
select t.uid
     , t.patient_id
     , t.death_dt
     , t.select_cause
     , t.reference_gb
     , case when t.death_dt is null      then 'A'  --사망일자가 없는 경우
            when t.death_seq <> 1        then 'B'  --사망건수가 한 건 이상인 경우 한 건만 가져오기 위해서
            when t.death_dt < t.birth_dt then 'C'  --사망일보다 생년월일이 더 나중인 경우
            when t.death_dt::date > cast(to_char(current_date, 'yyyy-mm-dd') as date) then 'D' --사망일자가 오늘자보다 나중인 경우
            when t.patient_id is null    then 'E'  --사망데이터는 있지만 환자 번호가 없는 경우
            else 'N' end as filtering
  from (
        select d1.uid
             , d1.patient_id
             , p1.birth_dt
             , case when coalesce(d1.death_dt, d1.regit_dt)::date = '9999-12-31'::date then null else coalesce(d1.death_dt, d1.regit_dt) end as death_dt
             , d1.death_seq
             , coalesce(d1.direct_cause::varchar, d1.mid_cause::varchar, d1.pre_cause::varchar) as select_cause
             , c1.target_value as reference_gb
          from itfcdmpv532_daily.itf_death d1
          left join
        itfcdmpv532_daily.itf_person p1
        on d1.patient_id = p1.patient_id
        left join mapcdmpv532_daily.constant c1
        on d1.reference_gb = c1.source_value
        and c1.idx = 401
       ) t
;;



-----------------------------check cnt
insert into cdw_real.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'mt_rule_death' , 'mt_rule_death', count(*) as cnt
from itfcdmpv532_daily.mt_rule_death ;
