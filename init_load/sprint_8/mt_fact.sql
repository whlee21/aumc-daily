drop table if exists itfcdmpv532_daily.mt_fact_anti;

create table itfcdmpv532_daily.mt_fact_anti as (
select a.measurement_id, a.patient_id, a.relation_no, a.target_concept_id_1
  from itfcdmpv532_daily.mt_measurement a
 where a.relation_no is not null and a.antibiotic_yn = 'Y'    
    );


drop table if exists itfcdmpv532_daily.mt_fact_bacteria;

create table itfcdmpv532_daily.mt_fact_bacteria as (
select b.measurement_id, b.patient_id, b.relation_no, b.target_concept_id_1
  from itfcdmpv532_daily.mt_measurement b
 where b.relation_no is not null and b.antibiotic_yn = 'N'
    );
