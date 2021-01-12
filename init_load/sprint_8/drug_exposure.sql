drop table if exists cdmpv532_daily.drug_exposure;;

create table cdmpv532_daily.drug_exposure as
select cast(d1.drug_exposure_id                           as bigint)        as drug_exposure_id
	 , cast(p1.uid                                        as bigint)        as person_id
	 , cast(coalesce(d1.target_concept_id_1, 0)           as integer)       as drug_concept_id
	 , cast(d1.drug_start_dt                              as date)          as drug_exposure_start_date
	 , cast(d1.drug_start_dt                              as timestamp)     as drug_exposure_start_datetime
	 , cast(d1.drug_end_dt                                as date)          as drug_exposure_end_date
	 , cast(d1.drug_end_dt                                as timestamp)     as drug_exposure_end_datetime
	 , cast(d1.verbatim_end_date                          as date)          as verbatim_end_date
	 , cast(coalesce(m2.target_concept_id, 0)             as integer)       as drug_type_concept_id
	 , cast(d1.stop_reason                                as varchar(20))   as stop_reason
	 , cast(null                                          as integer)       as refills
	 , cast(d1.quantity                                   as float)         as quantity
	 , cast(coalesce(d1.order_day, 1)                     as integer)       as days_supply -- 20201117 DAYS default 1 추가 LSH
	 , cast(d1.remark                                     as text)          as sig
	 , cast(m1.target_concept_id                          as integer)       as route_concept_id
	 , cast(d1.lot_number                                 as varchar(50))   as lot_number
	 , cast(p2.uid                                        as bigint)        as provider_id
	 , cast(v1.visit_occurrence_id                        as bigint)        as visit_occurrence_id
	 , cast(v1.visit_detail_id                            as bigint)        as visit_detail_id
	 , cast(d1.order_cd                                   as varchar(50))   as drug_source_value
	 , cast(coalesce(d1.source_concept_id,0)              as integer)       as drug_source_concept_id
	 , cast(d1.method_cd                                  as varchar(50))   as route_source_value
	 , cast(d1.unit                                       as varchar(50))   as dose_unit_source_value
     , d1.medical_dept ----------------------추가 INSIGHT 용 20200709 BY LSH
     , d1.ward_cd ----------------------추가 중환자실 20200729
  from itfcdmpv532_daily.mt_drug_exposure d1   
 inner join itfcdmpv532_daily.mt_person p1  
    on d1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.mt_provider p2  
    on d1.order_dr = p2.provider_id and p2.rn=1
  left join itfcdmpv532_daily.visit_mapping_drug v1	
    on d1.drug_exposure_id = v1.drug_exposure_id
  left join mapcdmpv532_daily.map_gb m1
    on d1.method_cd = m1.source_value 
   and m1.idx = 3001
  left join mapcdmpv532_daily.map_gb m2  
    on d1.self_drug_yn = m2.source_value  
   and m2.idx = 3002
  ;;

/*****************************************************
index
*****************************************************/							    
alter table cdmpv532_daily.drug_exposure add constraint xpk_drug_exposure primary key ( drug_exposure_id ) ;;
alter table cdmpv532_daily.drug_exposure alter column person_id set not null;
alter table cdmpv532_daily.drug_exposure alter column drug_concept_id set not null;
alter table cdmpv532_daily.drug_exposure alter column drug_exposure_start_date set not null;
alter table cdmpv532_daily.drug_exposure alter column drug_exposure_end_date set not null;
alter table cdmpv532_daily.drug_exposure alter column drug_type_concept_id set not null;
create index idx_drug_person_id  on cdmpv532_daily.drug_exposure  (person_id asc);;
cluster cdmpv532_daily.drug_exposure  using idx_drug_person_id ;;
create index idx_drug_concept_id on cdmpv532_daily.drug_exposure (drug_concept_id asc);;
create index idx_drug_visit_id on cdmpv532_daily.drug_exposure (visit_occurrence_id asc);;