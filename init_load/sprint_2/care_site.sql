drop table if exists cdmpv532_daily.care_site;;

create table cdmpv532_daily.care_site as
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
           on c1.zip_code_3::integer = l1.location_source_value::integer
         left join mapcdmpv532_daily.map_gb m1 
           on c1.place_of_service = m1.source_value 
          and m1.idx = 153
        where c1.rn = 1
        
        union all 
        
       --select care_site_id::bigint, target_value::varchar, source_value::integer, source_value_nm::varchar, target_value_nm::varchar, source_col::varchar from mapcdmpv532_daily.constant where idx = 9999
       select care_site_id::bigint, target_value_nm ::varchar(255), source_value::integer, 308 as location_id, target_value::varchar(50), target_value_nm::varchar(50) from mapcdmpv532_daily.constant where idx = 9999
 ) c 
;;
/*****************************************************
INDEX
*****************************************************/							 
ALTER TABLE cdmpv532_daily.care_site ADD CONSTRAINT xpk_care_site PRIMARY KEY ( care_site_id ) ;;   
