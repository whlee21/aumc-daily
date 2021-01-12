drop table if exists cdmpv532_daily.fact_relationship;

create table cdmpv532_daily.fact_relationship as
select a.target_concept_id_1::integer    as domain_concept_id_1
      ,a.measurement_id::integer         as fact_id_1
      ,b.target_concept_id_1::integer    as domain_concept_id_2
      ,b.measurement_id::integer         as fact_id_2
      ,32443::integer                    as relationship_concept_id
  from itfcdmpv532_daily.mt_fact_bacteria a
 inner join itfcdmpv532_daily.mt_fact_anti b
    on a.relation_no = b.relation_no and a.patient_id=b.patient_id
    and a.target_concept_id_1 is not null and b.target_concept_id_1 is not null;
    
    
    
alter table cdmpv532_daily.fact_relationship alter column domain_concept_id_1 set not null;
alter table cdmpv532_daily.fact_relationship alter column fact_id_1 set not null;
alter table cdmpv532_daily.fact_relationship alter column domain_concept_id_2 set not null;
alter table cdmpv532_daily.fact_relationship alter column fact_id_2 set not null;
alter table cdmpv532_daily.fact_relationship alter column relationship_concept_id set not null;
CREATE INDEX idx_fact_relationship_id_1 ON cdmpv532_daily.fact_relationship (domain_concept_id_1 ASC);
CREATE INDEX idx_fact_relationship_id_2 ON cdmpv532_daily.fact_relationship (domain_concept_id_2 ASC);
CREATE INDEX idx_fact_relationship_id_3 ON cdmpv532_daily.fact_relationship (relationship_concept_id ASC);
