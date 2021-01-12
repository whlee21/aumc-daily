drop table if exists itfcdmpv532_daily.mt_visit_detail;

create table itfcdmpv532_daily.mt_visit_detail as
select v2.visit_detail_id
     , v2.visit_occurrence_id
     , v2.visit_no
     , v2.patient_id 
     , v2.medical_dt
     , v2.medical_dept
     , v2.medical_dr     
     , v2.visit_start_dt
     , v2.visit_end_dt
     , v2.provider
     , v2.discharge_yn
     , v2.visit_path
     , v2.discharge_path
     , v2.visit_gb
     , v2.visit_gb_div
     , v2.reference_gb
     , v2.preceding_visit_detail_id
  from itfcdmpv532_daily.mt_rule_visit v2 
 where v2.filtering = 'N'
;
