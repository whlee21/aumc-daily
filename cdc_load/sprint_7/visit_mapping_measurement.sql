drop table if exists itfcdmpv532_daily.visit_mapping_measurement;

create table itfcdmpv532_daily.visit_mapping_measurement as
select tt.*
  from(
       select row_number() over(partition by v.measurement_id order by v.visit_occurrence_id, v.visit_detail_id desc) rank,*
         from(
              select m1.measurement_id
                   , v1.visit_occurrence_id
                   , v1.visit_detail_id
                from itfcdmpv532_daily.mt_measurement m1
               inner join itfcdmpv532_daily.mt_visit_detail  v1
                  on m1.patient_id = v1.patient_id
                 and case when m1.visit_no = v1.visit_no
                          then m1.visit_no = v1.visit_no
                          else m1.visit_gb = v1.visit_gb
                               and m1.medical_dept = v1.medical_dept
                               and m1.medical_dt::date = v1.medical_dt::date end
                ) v
       ) tt
 where tt.rank = 1;;
