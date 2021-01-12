drop table if exists itfcdmpv532_daily.mt_note;;

create table itfcdmpv532.mt_note as
select row_number() over (order by n2.uid) as note_id
     , n2.patient_id
     , n2.visit_no
     , n2.visit_gb
     , n2.medical_dr     
     , n2.medical_dt
     , n2.medical_dept
     , n2.note_title
     , n2.form_nm
     , n2.note_start_dt
     , n2.encoding_gb 
     , n2.language_gb
     , n2.txt
  from itfcdmpv532_daily.mt_rule_note n2 
 where n2.filtering = 'N'
;;
