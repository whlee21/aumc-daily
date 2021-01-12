drop table if exists cdmpv532_daily.death;;

create table cdmpv532_daily.death as
select cast(p1.uid                           as bigint)                  as person_id
     , cast(d1.death_dt                      as date)                    as death_date              
     , cast(d1.death_dt                      as timestamp)               as death_datetime          
     , cast(coalesce(m1.target_concept_id,0) as integer)                 as death_type_concept_id   
     , cast(0                               as integer)                 as cause_concept_id        
     , cast(d1.select_cause                  as varchar(50))             as cause_source_value      
     , cast(0                               as integer)                 as cause_source_concept_id 
  from itfcdmpv532_daily.mt_death d1
 inner join itfcdmpv532_daily.itf_person p1 
    on d1.patient_id = p1.patient_id 
  left join mapcdmpv532.map_gb m1 
    on d1.reference_gb = m1.source_value 
   and m1.idx = 401
 where d1.rn = 1
;;

/*****************************************************
INDEX
*****************************************************/
ALTER TABLE cdmpv532_daily.death ADD CONSTRAINT xpk_death PRIMARY KEY ( person_id ) ;;
alter table cdmpv532_daily.death alter column death_date set not null;
alter table cdmpv532_daily.death alter column death_type_concept_id set not null;
CREATE INDEX idx_death_person_id  ON cdmpv532_daily.death  (person_id ASC);;
CLUSTER cdmpv532_daily.death  USING idx_death_person_id ;;


