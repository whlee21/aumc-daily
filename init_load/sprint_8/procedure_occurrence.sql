drop table if exists cdmpv532_daily.procedure_occurrence;;

create table cdmpv532_daily.procedure_occurrence as
select cast(p1.procedure_occurrence_id           as bigint)         as procedure_occurrence_id
     , cast(p2.uid                               as integer)        as person_id
     , cast(coalesce(p1.target_concept_id_1, 0)  as integer )       as procedure_concept_id
     , cast(p1.procedure_start_dt                as date)           as procedure_date
     , cast(p1.procedure_start_dt                as timestamp)      as procedure_datetime
     , cast(coalesce(m1.target_concept_id, 0)    as integer)        as procedure_type_concept_id
     , cast(0                                   as integer)        as modifier_concept_id
     , cast(p1.quantity                          as integer)        as quantity
     , cast(p3.uid                               as integer)        as provider_id
     , cast(v1.visit_occurrence_id               as integer)        as visit_occurrence_id
     , cast(v1.visit_detail_id                   as integer)        as visit_detail_id
     , cast(p1.order_cd                          as varchar(50))    as procedure_source_value
     , cast(coalesce(p1.source_concept_id,0)     as integer)        as procedure_source_concept_id
     , cast(null                                 as varchar(50))    as modifier_source_value
     , p1.medical_dept ----------------------추가 INSIGHT 용 20200709 BY LSH
     , p1.ward_cd ----------------------추가 중환자실 20200729
  from itfcdmpv532_daily.mt_procedure_occurrence p1
 inner join itfcdmpv532_daily.mt_person p2 
    on p1.patient_id = p2.patient_id and p2.rn=1
  left join itfcdmpv532_daily.mt_provider p3 
    on p1.provider = p3.provider_id and p3.rn=1
  left join mapcdmpv532_daily.map_gb m1 
    on p1.reference_gb = m1.source_value 
   and m1.idx = 2201
  left join itfcdmpv532_daily.visit_mapping_procedure v1 
    on p1.procedure_occurrence_id = v1.procedure_occurrence_id
;;

/*****************************************************
index
*****************************************************/							  
alter table cdmpv532_daily.procedure_occurrence add constraint xpk_procedure_occurrence primary key ( procedure_occurrence_id ) ;;
alter table cdmpv532_daily.procedure_occurrence alter column person_id set not null;
alter table cdmpv532_daily.procedure_occurrence alter column procedure_concept_id set not null;
alter table cdmpv532_daily.procedure_occurrence alter column procedure_date set not null;
alter table cdmpv532_daily.procedure_occurrence alter column procedure_type_concept_id set not null;
create index idx_procedure_person_id  on cdmpv532_daily.procedure_occurrence  (person_id asc);;
cluster cdmpv532_daily.procedure_occurrence  using idx_procedure_person_id ;;
create index idx_procedure_concept_id on cdmpv532_daily.procedure_occurrence (procedure_concept_id asc);;
create index idx_procedure_visit_id on cdmpv532_daily.procedure_occurrence (visit_occurrence_id asc);;
