-- 수정
update cdmpv532_daily.care_site a set 
  a.care_site_name = c.care_site_name
  , a.place_of_service_concept_id = c.place_of_service_concept_id
  , a.location_id = c.location_id
  , a.care_site_source_value = c.care_site_source_value
  , a.place_of_service_source_value = c.place_of_service_source_value
from (
       select cast(c1.uid               as bigint)       as care_site_id
            , cast(c1.dept_nm           as varchar(255)) as care_site_name
            , cast(m1.target_concept_id as integer)      as place_of_service_concept_id
            , cast(l1.location_id       as integer)      as location_id 
            , cast(c1.dept_cd           as varchar(50))  as care_site_source_value
            , cast(c1.dept_nm           as varchar(50))  as place_of_service_source_value
         from itfcdmpv532_daily.mt_care_site c1
         left join cdmpv532_daily.location l1  
           on c1.zip_cd = l1.location_source_value
         left join mapcdmpv532_daily.map_gb m1 
           on c1.place_of_service = m1.source_value 
          and m1.idx = 153
        where c1.rn = 1
 ) c 
 where 1=1
 and a.care_site_id = c.care_site_id;;


--신규
insert into cdmpv532_daily.care_site as
select c.*
  from(
       select cast(c1.uid               as bigint)       as care_site_id
            , cast(c1.dept_nm           as varchar(255)) as care_site_name
            , cast(m1.target_concept_id as integer)      as place_of_service_concept_id
            , cast(l1.location_id       as integer)      as location_id 
            , cast(c1.dept_cd           as varchar(50))  as care_site_source_value
            , cast(c1.dept_nm           as varchar(50))  as place_of_service_source_value
         from itfcdmpv532_daily.mt_care_site c1
         left join cdmpv532_daily.location l1  
           on c1.zip_cd = l1.location_source_value
         left join mapcdmpv532_daily.map_gb m1 
           on c1.place_of_service = m1.source_value 
          and m1.idx = 153
        where c1.rn = 1
 ) c 
 where 1=1
 and not exists (select 1 from cdmpv532_daily.care_site d where 1=1 and c.care_site_id = d.care_site_id )
;;



