drop table if exists itfcdmpv532_daily.mt_measurement;; 

create table itfcdmpv532_daily.mt_measurement as
select row_number() over(order by m.uid) as measurement_id
     , m.*
    from(
         --create table itfcdmpv532_daily.mt_measurement_main as
         select m2.uid
              , m2.patient_id
              , m2.visit_no
              , m2.order_no
              , m2.order_dt
              , m2.order_dr
              , m2.medical_dt
              , m2.medical_dept
              , m2.specimen_no
              , m2.relation_no
              , m2.result_num
              , m2.result_txt
              , m2.result_unit
              , m2.normal_max
              , m2.normal_min
              , m2.visit_gb
              , m2.measurement_dt
              , m2.local_cd1
              , m2.local_cd2
              , m2.local_cd3 -----------------추가 20200103 이승형
              , m2.provider
              , m2.result_operator
              , m2.result_category
              , m2.antibiotic_yn
              , m2.value_as_concept_id
              , m2.target_concept_id_1
              , m2.source_concept_id
              , m2.reference_gb
              , m2.source_domain_id
              , m2.target_domain_id
           from itfcdmpv532_daily.mt_rule_measurement m2
          where m2.filtering = 'N'
            and (m2.target_domain_id in ('Measurement', 'Meas Value') or m2.target_domain_id is null) 
			
         union all
         
         --create table itfcdmpv532_daily.mt_procedure_to_measurement as
         select p2.uid                 as uid
              , p2.patient_id          as patient_id
              , p2.visit_no            as visit_no
              , p2.order_no            as order_no
              , p2.order_dt            as order_dt
              , p2.order_dr            as order_dr
              , p2.medical_dt          as medical_dt
              , p2.medical_dept        as medical_dept
              , null                   as specimen_no
              , null                   as relation_no
              , null                   as result_num
              , null                   as result_txt
              , null                   as result_unit
              , null                   as normal_max
              , null                   as normal_min
              , p2.visit_gb            as visit_gb
              , p2.procedure_start_dt  as measurement_dt
              , p2.order_cd            as local_cd1
              , null                   as local_cd2
              , null                   as local_cd3
              , p2.provider            as provider
              , null                   as result_operator
              , null                   as result_category
              , null                   as antibiotic_yn
              , null                   as value_as_concept_id
              , p2.target_concept_id_1 as target_concept_id_1
              , p2.source_concept_id   as source_concept_id
              , p2.reference_gb        as reference_gb
              , p2.source_domain_id    as source_domain_id
              , p2.target_domain_id    as target_domain_id
           from itfcdmpv532_daily.mt_rule_procedure_occurrence p2
          where p2.filtering = 'N'
            and p2.target_domain_id = 'Measurement'
         
         union all
         
		 --create table itfcdmpv532_daily.mt_condition_to_measurement as
         select c2.uid                  as uid
              , c2.patient_id           as patient_id
              , c2.visit_no             as visit_no
              , null                    as order_no
              , null                    as order_dt
              , c2.medical_dr           as order_dr
              , c2.medical_dt           as medical_dt
              , c2.medical_dept         as medical_dept
              , null                    as specimen_no
              , null                    as relation_no
              , null                    as result_num
              , null                    as result_txt
              , null                    as result_unit
              , null                    as normal_max
              , null                    as normal_min
              , c2.visit_gb             as visit_gb
              , c2.condition_start_dt   as measurement_dt
              , c2.diagnosis_cd         as local_cd1
              , null                    as local_cd2
              , null                    as local_cd3
              , c2.medical_dr           as provider
              , null                    as result_operator
              , null                    as result_category
              , null                    as antibiotic_yn
              , c2.target_concept_id_2  as value_as_concept_id
              , c2.target_concept_id_1  as target_concept_id_1
              , c2.source_concept_id    as source_concept_id
              , null                    as reference_gb
              , c2.source_domain_id     as source_domain_id
              , c2.target_domain_id     as target_domain_id
           from itfcdmpv532_daily.mt_rule_condition_occurrence c2
          where c2.filtering = 'N'
            and c2.target_domain_id = 'Measurement' 
         
         union all
         
		 --create table itfcdmpv532_daily.mt_observation_to_measurement as
         select o2.uid                  as uid
              , o2.patient_id           as patient_id
              , o2.visit_no             as visit_no
              , null                    as order_no
              , null                    as order_dt
              , o2.medical_dr           as order_dr
              , o2.medical_dt           as medical_dt
              , o2.medical_dept         as medical_dept
              , null                    as specimen_no
              , null                    as relation_no
              , null                    as result_num
              , null                    as result_txt
              , null                    as result_unit
              , null                    as normal_max
              , null                    as normal_min
              , o2.visit_gb             as visit_gb
              , o2.observation_start_dt as measurement_dt
              , o2.observation_source_value as local_cd1
              , null                    as local_cd2
              , null                    as local_cd3
              , o2.medical_dr           as provider
              , null                    as result_operator
              , null                    as result_category
              , null                    as antibiotic_yn
              , null                    as value_as_concept_id
              , o2.target_concept_id_1  as target_concept_id_1
              , o2.source_concept_id    as source_concept_id
              , null                    as reference_gb
              , o2.source_domain_id     as source_domain_id
              , o2.target_domain_id     as target_domain_id
           from itfcdmpv532_daily.mt_rule_observation o2
          where o2.filtering = 'N'
            and o2.target_domain_id in ('Measurement', 'Meas Value')
    )m;
