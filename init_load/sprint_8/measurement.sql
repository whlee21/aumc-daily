drop table if exists cdmpv532_daily.measurement;;

create table cdmpv532_daily.measurement as
select 
	cast(m1.measurement_id                                       as bigint)         as measurement_id
	, cast(p1.uid                                                  as bigint)         as person_id
	, cast(coalesce(m1.target_concept_id_1, 0)                     as integer)        as measurement_concept_id
	, cast(m1.measurement_dt                                       as date)           as measurement_date
	, cast(m1.measurement_dt                                       as timestamp)      as measurement_datetime
	, cast(coalesce(m2.target_concept_id, 0)                       as integer)        as measurement_type_concept_id
	, cast(m3.target_concept_id                                    as integer)        as operator_concept_id
	, cast(result_num                                              as float)          as value_as_number
	, cast(coalesce(m5.target_concept_id, m1.value_as_concept_id ,0)          as integer)        as value_as_concept_id -- 항생제 민감도 결과 값 우선 
	, cast(m6.target_concept_id                                    as integer)        as unit_concept_id --- 추가함 20200103 이승형
	, cast(m1.normal_min	                                        as float )         as range_low
	, cast(m1.normal_max	                                        as float)	   	   as range_high
	, cast(p2.uid                                                  as bigint)         as provider_id
	, cast(v1.visit_occurrence_id                                  as bigint)         as visit_occurrence_id
	, cast(v1.visit_detail_id                                      as bigint)	       as visit_detail_id
	, cast(m1.local_cd1                                            as varchar(50))    as measurement_source_value
	, cast(coalesce(m1.source_concept_id,0)                        as integer)        as measurement_source_concept_id
	, cast(m1.result_unit                                          as varchar(50))    as unit_source_value
	, cast(m1.result_txt                                           as varchar(50))    as value_source_value
	, m1.medical_dept                                                                 as care_site_source_value ----------------------추가 INSIGHT 용 20200709 BY LSH
  from itfcdmpv532_daily.mt_measurement m1
 inner join itfcdmpv532_daily.mt_person p1
    on m1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.visit_mapping_measurement v1
    on m1.measurement_id = v1.measurement_id
  left join itfcdmpv532_daily.mt_provider p2
    on m1.provider = p2.provider_id and p2.rn=1
  left join mapcdmpv532_daily.map_gb m2
    on m1.reference_gb = m2.source_value
   and m2.idx = 1001
  left join mapcdmpv532_daily.map_gb m3
    on m1.result_operator = m3.source_value
   and m3.idx = 10112
--  left join mapcdmpv532_daily.map_gb m4
--    on m1.bacteria_cd = m4.source_value
--   and m4.idx = 10154
  left join mapcdmpv532_daily.map_gb m5
    on m1.result_category = m5.source_value
   and m5.idx = 10155
  left join mapcdmpv532_daily.map_gb m6    /*추가 20200103 이승형 */
    on m1.result_unit = m6.source_value
   and m6.idx = 10156;-- 임의의 숫자임 겹치는지 모름 확인해야함.

/*****************************************************
INDEX
*****************************************************/
ALTER TABLE cdmpv532_daily.measurement ADD CONSTRAINT xpk_measurement PRIMARY KEY ( measurement_id ) ;;
alter table cdmpv532_daily.measurement alter column person_id set not null;
alter table cdmpv532_daily.measurement alter column measurement_concept_id set not null;
alter table cdmpv532_daily.measurement alter column measurement_date set not null;
alter table cdmpv532_daily.measurement alter column measurement_type_concept_id set not null;
CREATE INDEX idx_measurement_person_id  ON cdmpv532_daily.measurement  (person_id ASC);;
CLUSTER cdmpv532_daily.measurement  USING idx_measurement_person_id ;;
CREATE INDEX idx_measurement_concept_id ON cdmpv532_daily.measurement (measurement_concept_id ASC);;
CREATE INDEX idx_measurement_visit_id ON cdmpv532_daily.measurement (visit_occurrence_id ASC);;
