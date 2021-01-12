drop table if exists cdmpv532_daily.observation;; 

create table cdmpv532_daily.observation as
select cast(o1.observation_id                   as bigint)       as observation_id
     , cast(p1.uid                              as integer)      as person_id
     , cast(coalesce(o1.target_concept_id_1, 0) as integer)      as observation_concept_id
     , cast(o1.observation_start_dt             as date)         as observation_date
     , cast(o1.observation_start_dt             as timestamp)    as observation_datetime
     , cast(coalesce(m1.target_concept_id, 0)   as integer)      as observation_type_concept_id
     , cast(o1.result_num                       as float)        as value_as_number
     , cast(o1.result_txt                       as varchar(200)) as value_as_string
     , cast(o1.value_as_concept_id              as integer)      as value_as_concept_id
     , cast(o1.target_concept_id_4              as integer)      as qualifier_concept_id
     , cast(o1.target_concept_id_5              as integer)      as unit_concept_id
     , cast(p2.uid                              as integer)      as provider_id
     , cast(v1.visit_occurrence_id              as integer)      as visit_occurrence_id
     , cast(v1.visit_detail_id                  as integer)      as visit_detail_id
     , cast(o1.observation_source_value         as varchar(250)) as observation_source_value
     , cast(coalesce(o1.source_concept_id,0)    as integer)      as observation_source_concept_id
     , cast(o1.result_unit                      as varchar(50))  as unit_source_value
     , cast(o1.qualifier                        as varchar(50))  as qualifier_source_value
  from itfcdmpv532_daily.mt_observation o1
 inner join itfcdmpv532_daily.mt_person p1 
    on o1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.visit_mapping_observation v1
    on o1.observation_id = v1.observation_id
  left join itfcdmpv532_daily.mt_provider p2 
    on o1.medical_dr = p2.provider_id and p2.rn=1
  left join mapcdmpv532_daily.map_gb m1 
    on o1.reference_gb = m1.source_value
   and m1.idx = 801    
 ;;

/*****************************************************
index
*****************************************************/							 
alter table cdmpv532_daily.observation add constraint xpk_observation primary key ( observation_id ) ;;
alter table cdmpv532_daily.observation alter column person_id set not null;
alter table cdmpv532_daily.observation alter column observation_concept_id set not null;
alter table cdmpv532_daily.observation alter column observation_date set not null;
alter table cdmpv532_daily.observation alter column observation_type_concept_id set not null;
create index idx_observation_person_id on cdmpv532_daily.observation (person_id asc);;
cluster cdmpv532_daily.observation using idx_observation_person_id ;;
create index idx_observation_concept_id on cdmpv532_daily.observation (observation_concept_id asc);;
create index idx_observation_visit_id on cdmpv532_daily.observation (visit_occurrence_id asc);;
