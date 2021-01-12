drop table if exists cdmpv532_daily.specimen;;

create table cdmpv532_daily.specimen as
select cast(s1.specimen_id                       as bigint)       as specimen_id
	 , cast(p1.uid                               as bigint)       as person_id
	 , cast(coalesce(s1.target_concept_id_1, 0)  as integer)      as specimen_concept_id
	 , cast(coalesce(m3.target_concept_id, 0)    as integer)      as specimen_type_concept_id
	 , cast(s1.specimen_dt                       as date)         as specimen_date
	 , cast(s1.specimen_dt                       as timestamp)    as specimen_datetime
	 , cast(s1.quantity                          as float)        as quantity
	 , cast(0	                                 as integer)      as unit_concept_id            --specimen, drug, measurement unit 재정비 예정
	 , cast(0	                                 as integer)      as anatomic_site_concept_id   --map_main에서 target_concept_id_2로 하게 할 예정
	 , cast(0 	                                 as integer)      as disease_status_concept_id
	 , cast(s1.specimen_no                       as varchar(50))  as specimen_source_id
	 , cast(s1.specimen_cd                       as varchar(50))  as specimen_source_value
	 , cast(s1.unit                              as varchar(50))  as unit_source_value
	 , cast(s1.site                              as varchar(50))  as anatomic_site_source_value
	 , cast(s1.examination_rslt                  as varchar(50))  as disease_status_source_value
  from itfcdmpv532_daily.mt_specimen s1
 inner join itfcdmpv532_daily.mt_person p1 
    on s1.patient_id = p1.patient_id and p1.rn=1
--  left join mapcdmpv532_daily.map_gb m1 
--    on s1.unit = m1.source_value
--   and m1.idx =
--  left join mapcdmpv532_daily.map_gb m2 
--    on s1.site = m2.source_value
--   and m2.idx =  
  left join mapcdmpv532_daily.map_gb m3 
    on s1.reference_gb = m3.source_value
   and m3.idx = 901
   ;;

/*************************************************
index
*****************************************************/
alter table cdmpv532_daily.specimen add constraint xpk_specimen primary key ( specimen_id ) ;;
alter table cdmpv532_daily.specimen alter column person_id set not null;
alter table cdmpv532_daily.specimen alter column specimen_concept_id set not null;
alter table cdmpv532_daily.specimen alter column specimen_type_concept_id set not null;
alter table cdmpv532_daily.specimen alter column specimen_date set not null;
create index idx_specimen_person_id  on cdmpv532_daily.specimen  (person_id asc);;
cluster cdmpv532_daily.specimen  using idx_specimen_person_id ;;
create index idx_specimen_concept_id on cdmpv532_daily.specimen (specimen_concept_id asc);;