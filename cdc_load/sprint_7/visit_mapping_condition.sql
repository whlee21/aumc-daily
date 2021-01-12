drop table if exists itfcdmpv532_daily.visit_mapping_condition;

create table itfcdmpv532_daily.visit_mapping_condition as
select tt.*
  from(
       select row_number() over(partition by v.condition_occurrence_id order by v.visit_occurrence_id, v.visit_detail_id desc) rank,*
         from( 
              select c1.condition_occurrence_id
                   , v1.visit_occurrence_id
                   , v1.visit_detail_id
                from itfcdmpv532_daily.mt_condition_occurrence c1
               inner join itfcdmpv532_daily.mt_visit_detail  v1
                  on c1.patient_id = v1.patient_id
                 and case when c1.visit_no = v1.visit_no
                          then c1.visit_no = v1.visit_no
                          else c1.visit_gb = v1.visit_gb
                               and c1.medical_dept = v1.medical_dept
                               and c1.medical_dt::date = v1.medical_dt::date end
                ) v
       ) tt
 where tt.rank = 1;;
