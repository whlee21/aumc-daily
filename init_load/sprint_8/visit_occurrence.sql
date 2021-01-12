drop table if exists cdmpv532_daily.visit_occurrence;;

create table cdmpv532_daily.visit_occurrence as  
select cast(v1.visit_occurrence_id                                  as bigint)           as visit_occurrence_id
     , cast(p1.uid                                                  as bigint)           as person_id
     , cast(coalesce(m1.target_concept_id, 0)                       as integer)          as visit_concept_id
     , cast(v1.visit_start_dt                                       as date)             as visit_start_date
     , cast(v1.visit_start_dt                                       as timestamp)        as visit_start_datetime
     , cast(v1.visit_end_dt                                         as date)             as visit_end_date
     , cast(v1.visit_end_dt                                         as timestamp)        as visit_end_datetime
     , cast(coalesce(m4.target_concept_id, 0)                       as integer)          as visit_type_concept_id
     , cast(p2.uid                                                  as bigint)           as provider_id
     , cast(coalesce(v1.op_care_site::int, c1.uid)                  as bigint)           as care_site_id
     , cast(v1.visit_gb                                         as varchar(50))      as visit_source_value
     , cast(0                                                       as integer)          as visit_source_concept_id
     , cast(m2.target_concept_id                                    as integer)          as admitting_source_concept_id
     , cast(v1.visit_path                                           as varchar(50))      as admitting_source_value
     , cast(m3.target_concept_id                                    as integer)          as discharge_to_concept_id
     , cast(v1.discharge_path                                       as varchar(50))      as discharge_to_source_value
     , cast(v1.preceding_visit_occurrence_id                        as bigint)           as preceding_visit_occurrence_id
  from itfcdmpv532_daily.mt_visit_occurrence v1
 inner join itfcdmpv532_daily.mt_person p1 
    on v1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.mt_provider p2 
    on v1.medical_dr = p2.provider_id and p2.rn=1
  left join itfcdmpv532_daily.mt_care_site c1 
    on v1.medical_dept = c1.dept_cd AND c1.rn=1
  left join mapcdmpv532_daily.map_gb m1 
    on v1.visit_gb_div = m1.source_value 
   and m1.idx = 206
  left join mapcdmpv532_daily.map_gb m2 
    on v1.visit_path = m2.source_value 
   and m2.idx = 20119
  left join mapcdmpv532_daily.map_gb m3 
    on v1.discharge_path = m3.source_value 
   and m3.idx = 20120
  left join mapcdmpv532_daily.map_gb m4 
    on v1.reference_gb = m4.source_value 
   and m4.idx = 207
--  left join mapcdmpv532_daily.map_gb m5 
--    on v1.discharge_yn = m5.source_value 
--   and m5.idx = 208
;;
/*****************************************************
index
*****************************************************/
alter table cdmpv532_daily.visit_occurrence add constraint xpk_visit_occurrence primary key ( visit_occurrence_id ) ;;
alter table cdmpv532_daily.visit_occurrence alter column person_id set not null;
alter table cdmpv532_daily.visit_occurrence alter column visit_concept_id set not null;
alter table cdmpv532_daily.visit_occurrence alter column visit_start_date set not null;
alter table cdmpv532_daily.visit_occurrence alter column visit_end_date set not null;
alter table cdmpv532_daily.visit_occurrence alter column visit_type_concept_id set not null;
create index idx_visit_person_id  on cdmpv532_daily.visit_occurrence  (person_id asc);;
cluster cdmpv532_daily.visit_occurrence  using idx_visit_person_id ;;
create index idx_visit_concept_id on cdmpv532_daily.visit_occurrence (visit_concept_id asc);;