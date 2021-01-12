drop table if exists itfcdmpv532_daily.visit_mapping_observation;

create table itfcdmpv532_daily.visit_mapping_observation as
select tt.*
  from(
       select row_number() over(partition by v.observation_id order by v.visit_occurrence_id, v.visit_detail_id desc) rank,*
         from( 
              select o1.observation_id
                   , v1.visit_occurrence_id
                   , v1.visit_detail_id
                from itfcdmpv532_daily.mt_observation o1
               inner join itfcdmpv532_daily.mt_visit_detail  v1
                  on o1.patient_id = v1.patient_id
                 and case when o1.visit_no = v1.visit_no
                          then o1.visit_no = v1.visit_no
                          else o1.visit_gb = v1.visit_gb
                               and o1.medical_dept = v1.medical_dept
                               and o1.medical_dt::date = v1.medical_dt::date end
                ) v
       ) tt
 where tt.rank = 1;;