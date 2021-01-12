drop table if exists cdmpv532_daily.observation_period;;

create table cdmpv532_daily.observation_period as

with mt_observation_period as (
select row_number() over(order by md5(random()::text || clock_timestamp()::text)) as uid
     , person_id
     , min(start_dt) as start_dt
     , max(end_dt) as end_dt
  from( select person_id, min(visit_start_date) as start_dt, max(coalesce(visit_end_date,visit_start_date)) as end_dt
          from cdmpv532_daily.visit_occurrence
  	     group by person_id

        union all
        
        select person_id, min(procedure_date) as start_dt, max(procedure_date) as end_dt
          from cdmpv532_daily.procedure_occurrence
  	     group by person_id
        
        union all
        
        select person_id, min(observation_date) as start_dt, max(observation_date) as end_dt
          from cdmpv532_daily.observation
  	     group by person_id
        
        union all
        
        select person_id, min(note_date) as start_dt, max(note_date) as end_dt
          from cdmpv532_daily.note
         group by person_id
        
        union all
        
        select person_id, min(measurement_date) as start_dt, max(measurement_date) as end_dt
          from cdmpv532_daily.measurement
         group by person_id
        
        union all
        
        select person_id, min(drug_exposure_start_date) as start_dt, max(coalesce(drug_exposure_end_date,drug_exposure_start_date))  as end_dt
          from cdmpv532_daily.drug_exposure
         group by person_id
        
        union all
        
        select person_id, min(device_exposure_start_date) as start_dt, max(coalesce(device_exposure_end_date,device_exposure_start_date))  as end_dt
          from cdmpv532_daily.device_exposure
         group by person_id
        
        union all

        select person_id, min(condition_start_date) as start_dt, max(coalesce(condition_end_date,condition_start_date)) as end_dt
          from cdmpv532_daily.condition_occurrence
         group by person_id
        
        union all
        
        select person_id, min(death_date) as start_dt, max(death_date) as end_dt
          from cdmpv532_daily.death
         group by person_id
        
        union all
        
        select person_id, min(specimen_date) as start_dt, max(specimen_date) as end_dt
          from cdmpv532_daily.specimen
         group by person_id

        union all
        
        select person_id, min(payer_plan_period_start_date) as start_dt, max(payer_plan_period_end_date) as end_dt
          from cdmpv532_daily.payer_plan_period
         group by person_id		 

       ) a group by person_id
)
select cast(uid                               as integer) as observation_period_id
	 , cast(person_id                         as integer) as person_id
	 , cast(start_dt                          as date)    as observation_period_start_date
	 , cast(end_dt                            as date)    as observation_period_end_date
	 , cast((select target_concept_id 
	          from mapcdmpv532_daily.map_gb 
	         where source_value = '4' 
	           and idx = 1501)                as integer) as period_type_concept_id  --period inferred by algorithm
  from mt_observation_period;;

/*****************************************************
index
*****************************************************/
alter table cdmpv532_daily.observation_period add constraint xpk_observation_period primary key ( observation_period_id ) ;;
alter table cdmpv532_daily.observation_period alter column person_id set not null;
alter table cdmpv532_daily.observation_period alter column observation_period_start_date set not null;
alter table cdmpv532_daily.observation_period alter column observation_period_end_date set not null;
alter table cdmpv532_daily.observation_period alter column period_type_concept_id set not null;
create index idx_observation_period_id  on cdmpv532_daily.observation_period  (person_id asc);;
cluster cdmpv532_daily.observation_period  using idx_observation_period_id ;;
