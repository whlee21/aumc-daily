drop table if exists itfcdmpv532_daily.visit_mapping_drug;;

create table itfcdmpv532_daily.visit_mapping_drug as
select tt.*
  from(
       select row_number() over(partition by v.drug_exposure_id order by v.visit_gb_mapping,v.visit_occurrence_id, v.visit_detail_id desc) rank,*
         from(
              select d1.drug_exposure_id
                   , v1.visit_occurrence_id
                   , v1.visit_detail_id
                   , case when d1.visit_gb_div= v1.visit_gb_div then 1
                          else 2 end as visit_gb_mapping    --ICU처방끼리 연결, ICU처방인데 ICU방문과 연결 안된다면 다른 방문과 연
                from itfcdmpv532_daily.mt_drug_exposure d1
               inner join itfcdmpv532_daily.mt_visit_detail v1
                  on d1.patient_id = v1.patient_id
                 and case when d1.visit_no = v1.visit_no
                          then d1.visit_no = v1.visit_no
                          else d1.visit_gb = v1.visit_gb
                               and d1.medical_dept = v1.medical_dept
                               and d1.medical_dt::date = v1.medical_dt::date end

              )v
       ) tt
 where tt.rank = 1;;
