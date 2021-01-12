
drop table if exists cdmpv532_daily.condition_occurrence;;

create table cdmpv532_daily.condition_occurrence as
select cast(c1.condition_occurrence_id         as bigint)      as condition_occurrence_id
     , cast(p1.uid                             as bigint)      as person_id
     , cast(coalesce(c1.target_concept_id_1,0) as integer)     as condition_concept_id
     , cast(c1.condition_start_dt              as date)        as condition_start_date
     , cast(c1.condition_start_dt              as timestamp)   as condition_start_datetime
     , cast(c1.condition_end_dt                as date)        as condition_end_date
     , cast(c1.condition_end_dt                as timestamp)   as condition_end_datetime
     , cast(coalesce(m1.target_concept_id,0)   as integer)     as condition_type_concept_id
     , cast(c1.stop_reason                     as varchar(20)) as stop_reason
     , cast(p2.uid                             as bigint)      as provider_id
     , cast(v1.visit_occurrence_id             as bigint)      as visit_occurrence_id
     , cast(v1.visit_detail_id                 as bigint)      as visit_detail_id
     , cast(c1.diagnosis_cd                    as varchar(50)) as condition_source_value
     , cast(coalesce(c1.source_concept_id,0)   as integer)     as condition_source_concept_id
     , cast(c1.diagnosis_status_gb             as varchar(50)) as condition_status_source_value
     , cast(m2.target_concept_id               as integer) 	   as condition_status_concept_id
	 , c1.medical_dept                                         as care_site_source_value ----------------------추가 INSIGHT 용 20200709 BY LSH

  from itfcdmpv532_daily.mt_condition_occurrence c1
 inner join itfcdmpv532_daily.mt_person p1 
    on c1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.mt_provider p2
    on c1.medical_dr = p2.provider_id and p2.rn=1
  left join mapcdmpv532_daily.map_gb m1	
    on c1.main_yn = m1.source_value 
   and m1.idx = 763
  left join mapcdmpv532_daily.map_gb m2	
    on c1.diagnosis_status_gb = m2.source_value 
   and m2.idx = 700
  left join itfcdmpv532_daily.visit_mapping_condition v1 
    on c1.condition_occurrence_id = v1.condition_occurrence_id
;;

/*****************************************************
INDEX
*****************************************************/						      
ALTER TABLE cdmpv532_daily.condition_occurrence ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY ( condition_occurrence_id ) ;;
alter table cdmpv532_daily.condition_occurrence alter column person_id set not null;
alter table cdmpv532_daily.condition_occurrence alter column condition_concept_id set not null;
alter table cdmpv532_daily.condition_occurrence alter column condition_start_date set not null;
alter table cdmpv532_daily.condition_occurrence alter column condition_type_concept_id set not null;
CREATE INDEX idx_condition_person_id  ON cdmpv532_daily.condition_occurrence  (person_id ASC);;
CLUSTER cdmpv532_daily.condition_occurrence  USING idx_condition_person_id ;;
CREATE INDEX idx_condition_concept_id ON cdmpv532_daily.condition_occurrence (condition_concept_id ASC);;
CREATE INDEX idx_condition_visit_id ON cdmpv532_daily.condition_occurrence (visit_occurrence_id ASC);;