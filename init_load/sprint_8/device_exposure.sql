drop table if exists cdmpv532_daily.device_exposure ;;

create table cdmpv532_daily.device_exposure as
select cast(d1.device_exposure_id               as bigint)           as device_exposure_id
     , cast(p1.uid                              as bigint)           as person_id
     , cast(coalesce(d1.target_concept_id_1, 0) as integer)          as device_concept_id
     , cast(d1.device_start_dt                  as date)             as device_exposure_start_date
     , cast(d1.device_start_dt                  as timestamp)        as device_exposure_start_datetime
     , cast(d1.device_end_dt                    as date)             as device_exposure_end_date
     , cast(d1.device_end_dt                    as timestamp)        as device_exposure_end_datetime
     , cast(coalesce(m1.target_concept_id, 0)   as integer)          as device_type_concept_id
     , cast(null                                as varchar(50))      as unique_device_id
     , cast(d1.quantity                         as integer)          as quantity
     , cast(p2.uid                              as bigint)           as provider_id
     , cast(v1.visit_occurrence_id              as bigint)           as visit_occurrence_id
     , cast(v1.visit_detail_id                  as bigint)           as visit_detail_id
     , cast(d1.order_cd                         as varchar(50))      as device_source_value      
     , cast(coalesce(d1.source_concept_id,0)    as integer)          as device_source_concept_id 
     , d1.medical_dept ----------------------추가 INSIGHT 용 20200709 BY LSH
     , d1.ward_cd ----------------------추가 중환자실 20200729
     , cast(d1.order_day                        as varchar(50))      as  order_day
  from itfcdmpv532_daily.mt_device_exposure d1
 inner join itfcdmpv532_daily.mt_person p1 
    on d1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.mt_provider p2 
    on d1.provider = p2.provider_id  and p2.rn=1
  left join itfcdmpv532_daily.visit_mapping_device v1 
    on d1.device_exposure_id = v1.device_exposure_id
  left join mapcdmpv532_daily.map_gb m1 
    on d1.reference_gb = m1.source_value
   and m1.idx = 4001
;;

/*****************************************************
INDEX
*****************************************************/
alter table cdmpv532_daily.device_exposure add constraint xpk_device_exposure primary key(device_exposure_id ) ;;
alter table cdmpv532_daily.device_exposure alter column person_id set not null;
alter table cdmpv532_daily.device_exposure alter column device_concept_id set not null;
alter table cdmpv532_daily.device_exposure alter column device_exposure_start_date set not null;
alter table cdmpv532_daily.device_exposure alter column device_type_concept_id set not null;
create index idx_device_person_id  on cdmpv532_daily.device_exposure  (person_id asc);;
cluster cdmpv532_daily.device_exposure  using idx_device_person_id ;;
create index idx_device_concept_id on cdmpv532_daily.device_exposure (device_concept_id asc);;
create index idx_device_visit_id on cdmpv532_daily.device_exposure (visit_occurrence_id asc);;

