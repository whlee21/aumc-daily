drop table if exists cdmpv532_daily.provider;;

create table cdmpv532_daily.provider as
select cast(p1.uid               as bigint)       as provider_id
     , cast(null                 as varchar(255)) as provider_name
     , cast(null                 as varchar(20))  as npi
     , cast(null                 as varchar(20))  as dea
     , cast(m1.target_concept_id as integer)      as specialty_concept_id
     , cast(c1.uid               as bigint)       as care_site_id
     , cast(p1.year_of_birth     as integer)      as year_of_birth
     , cast(m2.target_concept_id as integer)      as gender_concept_id
     , cast(p1.provider_id       as varchar(50))  as provider_source_value
     , cast(p1.job_category_cd   as varchar(50))  as specialty_source_value
     , cast(null                 as integer)      as specialty_source_concept_id
     , cast(p1.gender            as varchar(50))  as gender_source_value
     , cast(0                    as integer)      as gender_source_concept_id --gender source can 0?
     from itfcdmpv532_daily.mt_provider p1
  left join mapcdmpv532_daily.map_gb m1 
    on p1.job_category_cd = m1.source_value 
   and m1.idx  = 2115
  left join mapcdmpv532_daily.map_gb m2 
    on p1.gender = m2.source_value 
   and m2.idx = 39
  left join itfcdmpv532_daily.mt_care_site c1 
    on p1.dept_cd = c1.dept_cd AND c1.rn=1
 where p1.rn = 1
;;
/*********************************************************************
INDEX
***********************************************************************/
ALTER TABLE cdmpv532_daily.provider ADD CONSTRAINT xpk_provider PRIMARY KEY ( provider_id ) ;;

