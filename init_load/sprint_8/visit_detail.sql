drop table if exists cdmpv532_daily.visit_detail;;

create table cdmpv532_daily.visit_detail as
select cast(v1.visit_detail_id                                      as bigint)                      as visit_detail_id
     , cast(p1.uid                                                  as bigint)                      as person_id
     , cast(coalesce(m1.target_concept_id, 0)                       as integer)                     as visit_concept_id
     , cast(v1.visit_start_dt                                       as date)                        as visit_start_date
     , cast(v1.visit_start_dt                                       as timestamp)                   as visit_start_datetime
     , cast(v1.visit_end_dt                                         as date)                        as visit_end_date
     , cast(v1.visit_end_dt                                         as timestamp)                   as visit_end_datetime
     , cast(coalesce(m4.target_concept_id, 0)                       as integer)                     as visit_type_concept_id
     , cast(p2.uid                                                  as bigint)                      as provider_id
     , cast(c1.uid                                                  as bigint)                      as care_site_id
     , cast(v1.visit_gb                                             as varchar(50))                 as visit_source_value
     , cast(0                                                       as integer)                     as visit_source_concept_id
     , cast(v1.visit_path                                           as varchar(50))                 as admitting_source_value
     , cast(m2.target_concept_id                                    as integer)                     as admitting_source_concept_id
     , cast(v1.discharge_path                                       as varchar(50))                 as discharge_to_source_value
     , cast(m3.target_concept_id                                    as integer)                     as discharge_to_concept_id
     , cast(v1.preceding_visit_detail_id                            as bigint)                      as preceding_visit_detail_id
     , cast(null                                                    as bigint)                      as visit_detail_parent_id
     , cast(v1.visit_occurrence_id                                  as bigint)                      as visit_occurrence_id
  from itfcdmpv532_daily.mt_visit_detail v1
 inner join itfcdmpv532_daily.mt_person p1 
    on v1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.mt_provider p2  
    on v1.medical_dr = p2.provider_id and p2.rn=1
  left join itfcdmpv532_daily.mt_care_site c1 
    on v1.medical_dept = c1.dept_cd AND c1.rn=1
  left join mapcdmpv532_daily.map_gb m1 
    on v1.visit_gb_div = m1.source_value 
   and m1.idx = 56
  left join mapcdmpv532_daily.map_gb m2 
    on v1.visit_path = m2.source_value 
   and m2.idx = 5119
  left join mapcdmpv532_daily.map_gb m3 
    on v1.discharge_path = m3.source_value 
   and m3.idx = 5120
  left join mapcdmpv532_daily.map_gb m4 
    on v1.reference_gb = m4.source_value 
   and m4.idx = 57
--  left join mapcdmpv532_daily.map_gb m5 
--    on v1.discharge_yn = m5.source_value 
--   and m5.idx = 58
   ;;
/*****************************************************
INDEX
*****************************************************/                                          
ALTER TABLE cdmpv532_daily.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY ( visit_detail_id ) ;;
alter table cdmpv532_daily.visit_detail alter column person_id set not null;
alter table cdmpv532_daily.visit_detail alter column visit_concept_id set not null;
alter table cdmpv532_daily.visit_detail alter column visit_start_date set not null;
alter table cdmpv532_daily.visit_detail alter column visit_end_date set not null;
alter table cdmpv532_daily.visit_detail alter column visit_type_concept_id set not null;
alter table cdmpv532_daily.visit_detail alter column visit_occurrence_id set not null; 
CREATE INDEX idx_visit_detail_person_id  ON cdmpv532_daily.visit_detail  (person_id ASC);;
CLUSTER cdmpv532_daily.visit_detail  USING idx_visit_detail_person_id ;;
CREATE INDEX idx_visit_detail_concept_id ON cdmpv532_daily.visit_detail (visit_concept_id ASC);;