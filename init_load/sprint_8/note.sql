drop table if exists cdmpv532_daily.note;;

create table cdmpv532_daily.note  as
select cast(n1.note_id                   as bigint)              as note_id
     , cast(p1.uid                       as bigint)              as person_id
     , cast(n1.note_start_dt             as date)                as note_date
     , cast(n1.note_start_dt             as timestamp)           as note_datetime
     , cast(m1.target_concept_id         as integer)             as note_type_concept_id
     , cast(0                            as integer)             as note_class_concept_id
     , cast(n1.note_title                as varchar(250))        as note_title
     , cast(n1.txt                       as text)                as note_text
     , cast(m2.target_concept_id         as integer)             as encoding_concept_id
     , cast(m3.target_concept_id         as integer)             as language_concept_id
     , cast(p2.uid                       as bigint)              as provider_id
     , cast(v1.visit_occurrence_id       as bigint)              as visit_occurrence_id
     , cast(v1.visit_detail_id           as bigint)              as visit_detail_id
     , cast(n1.note_title                as varchar(50))         as note_source_value
  from itfcdmpv532_daily.mt_note n1
 inner join itfcdmpv532_daily.mt_person p1 
    on n1.patient_id = p1.patient_id and p1.rn=1
  left join itfcdmpv532_daily.mt_provider p2 
    on n1.medical_dr = p2.provider_id and p2.rn=1
  left join itfcdmpv532_daily.visit_mapping_note v1 
    on n1.note_id = v1.note_id
  left join mapcdmpv532_daily.map_gb m1 
    on n1.form_nm = m1.source_value  
   and m1.idx = 1103 
  left join mapcdmpv532_daily.map_gb m2 
    on n1.encoding_gb = m2.source_value 
   and m2.idx = 1102 
  left join mapcdmpv532_daily.map_gb m3 
    on n1.language_gb = m3.source_value 
   and m3.idx = 1101
;;
/*****************************************************
INDEX
*****************************************************/                                                          
ALTER TABLE cdmpv532_daily.note ADD CONSTRAINT xpk_note PRIMARY KEY ( note_id ) ;;
alter table cdmpv532_daily.note alter column person_id set not null;
alter table cdmpv532_daily.note alter column note_date set not null;
alter table cdmpv532_daily.note alter column note_type_concept_id set not null;
alter table cdmpv532_daily.note alter column note_class_concept_id set not null;
alter table cdmpv532_daily.note alter column encoding_concept_id set not null;
alter table cdmpv532_daily.note alter column language_concept_id set not null;
CREATE INDEX idx_note_person_id  ON cdmpv532_daily.note  (person_id ASC);;
CLUSTER cdmpv532_daily.note  USING idx_note_person_id ;;
CREATE INDEX idx_note_concept_id ON cdmpv532_daily.note (note_type_concept_id ASC);;
CREATE INDEX idx_note_visit_id ON cdmpv532_daily.note (visit_occurrence_id ASC);;