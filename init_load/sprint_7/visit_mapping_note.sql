drop table if exists itfcdmpv532_daily.visit_mapping_note;;

create table itfcdmpv532_daily.visit_mapping_note as
select tt.*
  from(
       select row_number() over(partition by v.note_id order by v.visit_occurrence_id, v.visit_detail_id desc) rank,*
         from(
              select n1.note_id
                   , v1.visit_occurrence_id
                   , v1.visit_detail_id
                from itfcdmpv532_daily.mt_note n1
               inner join itfcdmpv532_daily.mt_visit_detail v1
                  on n1.patient_id = v1.patient_id
                 and case when n1.visit_no = v1.visit_no
                          then n1.visit_no = v1.visit_no
                          else n1.visit_gb = v1.visit_gb
                               and n1.medical_dept = v1.medical_dept
                               and n1.medical_dt::date = v1.medical_dt::date end
              )v
       ) tt
 where tt.rank = 1;;