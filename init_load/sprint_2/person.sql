drop table if exists cdmpv532_daily.person;

create table cdmpv532_daily.person as
select cast(p1.uid                                          as bigint)       as person_id
	 , cast(coalesce(m1.target_concept_id, 0)      	        as integer)      as gender_concept_id
	 , cast(p1.year_of_birth		                        as integer)      as year_of_birth
	 , cast(p1.month_of_birth                               as integer)      as month_of_birth
	 , cast(p1.day_of_birth                                 as integer)      as day_of_birth
	 , cast(p1.birth_dt                                     as timestamp)    as birth_datetime
	 , cast(coalesce(m2.target_concept_id,m3.target_concept_id, 0)               as integer)      as race_concept_id
	 , cast(0                                               as integer)      as ethnicity_concept_id
	 , cast(l1.location_id                                  as integer)      as location_id
	 , cast(null                                            as bigint)       as provider_id
	 , cast((select target_value from mapcdmpv532_daily.constant where idx =9999 ) as bigint)       as care_site_id
	 , cast(p1.patient_id                              	    as varchar(50))  as person_source_value
	 , cast(0	                                      	    as integer)      as gender_source_concept_id
	 , cast(p1.gender                                 	    as varchar(50))  as gender_source_value
	 , cast(p1.race_gb                              	    as varchar(50))  as race_source_value
	 , cast(0	                                      	    as integer)      as race_source_concept_id
	 , cast(null                                    	    as varchar(50))  as ethnicity_source_value
	 , cast(0	                                      	    as integer)      as ethnicity_source_concept_id
  from itfcdmpv532_daily.mt_person p1 
  left join cdmpv532."location" l1 
    on p1.zip_cd = l1.location_source_value
  left join mapcdmpv532_daily.map_gb m1 
    on p1.gender = m1.source_value 
   and m1.idx = 29
  left join mapcdmpv532_daily.map_gb m2 
    on p1.race_gb = m2.source_value 
   and m2.idx = 368
  left join mapcdmpv532_daily.map_gb m3
    on p1.foreigner_gb = m3.source_value 
   and m3.idx = 368
 where p1.rn = 1 
 ;
/*****************************************************
INDEX
*****************************************************/
ALTER TABLE cdmpv532_daily.person ADD CONSTRAINT xpk_person PRIMARY KEY ( person_id );;
alter table cdmpv532_daily.person alter column gender_concept_id set not null;
alter table cdmpv532_daily.person alter column year_of_birth set not null;
alter table cdmpv532_daily.person alter column race_concept_id set not null;
alter table cdmpv532_daily.person alter column ethnicity_concept_id set not null;
CREATE UNIQUE INDEX idx_person_id  ON cdmpv532_daily.person  (person_id ASC);;
CLUSTER cdmpv532_daily.person  USING idx_person_id ;;

