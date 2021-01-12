drop table if exists itfcdmpv532_daily.mt_observation;;

create table itfcdmpv532_daily.mt_observation as 
select row_number() over(order by o.uid) as observation_id
     , o.*
  from (
--create table cdmpv2.mt_observation_main as 
        select o2.uid
             , o2.patient_id
             , o2.visit_no
             , o2.medical_dt
             , o2.visit_gb
             , o2.medical_dept
             , o2.medical_dr
             , o2.qualifier
             , o2.result_txt
             , o2.result_num 
             , o2.result_unit
             , o2.observation_start_dt
             , o2.observation_source_value
             , o2.value_as_concept_id
             , o2.target_concept_id_1
             , o2.target_concept_id_4
             , o2.target_concept_id_5
             , o2.source_concept_id
             , o2.source_domain_id
             , o2.target_domain_id
             , o2.reference_gb
          from itfcdmpv532_daily.mt_rule_observation o2 
         where o2.filtering = 'N'
           and (o2.target_domain_id = 'Observation' or o2.target_domain_id is null)
        
        union all 
        
        --create table itfcdmpv532_daily.mt_condition_to_observation as
        select c2.uid                               as uid
             , c2.patient_id                        as patient_id
             , c2.visit_no                          as visit_no
             , c2.medical_dt                        as medical_dt
             , c2.visit_gb                          as visit_gb
             , null                                 as medical_dept
             , c2.medical_dr                        as medical_dr
             , null                                 as qualifier
             , ''                                   as result_txt
             , null                                 as result_num 
             , null                                 as result_unit
             , c2.condition_start_dt                as observation_start_dt 
             , c2.diagnosis_cd                      as observation_source_value
             , case when c2.rule_out_yn = 'Y'
                    then coalesce(c2.target_concept_id_1,0)
                    ELSE coalesce(c2.target_concept_id_2,0) end as value_as_concept_id
             , case when c2.rule_out_yn = 'Y' 
                    then 40479411 --RO인 경우 observation으로 보내기 위해서 
                    else c2.target_concept_id_1 end as target_concept_id_1
             , null                                 as target_concept_id_4
             , null                                 as target_concept_id_5
             , c2.source_concept_id                 as source_concept_id
             , c2.source_domain_id                  as source_domain_id
             , c2.target_domain_id                  as target_domain_id
             , '9'                                  as reference_gb --Observation recorded from EHR 
          from itfcdmpv532_daily.mt_rule_condition_occurrence c2 
         where c2.filtering = 'N' 
           and c2.target_domain_id = 'Observation'  
                    
        
        union all 
        
        --create table itfcdmpv532_daily.mt_device_to_observation as    
        select d2.uid                 as uid
             , d2.patient_id          as patient_id
             , d2.visit_no            as visit_no
             , d2.medical_dt          as medical_dt
             , d2.visit_gb            as visit_gb
             , d2.medical_dept        as medical_dept
             , d2.order_dr            as medical_dr
             , null                   as qualifier
             , ''                     as result_txt
             , null                   as result_num 
             , null                   as result_unit
             , d2.device_start_dt     as observation_start_dt
             , d2.order_cd            as observation_source_value
             , null                   as value_as_concept_id
             , d2.target_concept_id_1 as target_concept_id_1
             , null                   as target_concept_id_4
             , null                   as target_concept_id_5
             , d2.source_concept_id   as source_concept_id
             , d2.source_domain_id    as source_domain_id
             , d2.target_domain_id    as target_domain_id
             , d2.reference_gb        as reference_gb
          from itfcdmpv532_daily.mt_rule_device_exposure d2 
         where d2.filtering = 'N'
           and d2.target_domain_id = 'Observation'
       
        union all
        
        --create table itfcdmpv532_daily.mt_procedure_to_observation as    
        select p2.uid                   as uid
             , p2.patient_id            as patient_id
             , p2.visit_no              as visit_no
             , p2.medical_dt            as medical_dt
             , p2.visit_gb              as visit_gb
             , p2.medical_dept          as medical_dept
             , p2.order_dr              as medical_dr
             , null                     as qualifier
             , ''                       as result_txt
             , null                     as result_num 
             , null                     as result_unit
             , p2.procedure_start_dt    as observation_start_dt 
             , p2.order_cd              as observation_source_value
             , null                     as value_as_concept_id
             , p2.target_concept_id_1   as target_concept_id
             , null                     as target_concept_id_4
             , null                     as target_concept_id_5
             , p2.source_concept_id     as source_concept_id
             , p2.source_domain_id      as source_domain_id
             , p2.target_domain_id      as target_domain_id
             , p2.reference_gb          as reference_gb
          from itfcdmpv532_daily.mt_rule_procedure_occurrence p2 
         where p2.filtering = 'N'
           and p2.target_domain_id = 'Observation' 
           
        union all
        
        --create table itfcdmpv532_daily.mt_order_to_observation as    
        select o2.uid	              as uid
             , o2.patient_id	      as patient_id
             , o2.visit_no	          as visit_no
             , o2.medical_dt	      as medical_dt
             , o2.visit_gb	          as visit_gb
             , o2.medical_dept	      as medical_dept
             , o2.order_dr	          as medical_dr
             , null	                  as qualifier
             , ''	                  as result_txt 
             , null	                  as result_num
             , null                   as result_unit
             , o2.order_start_dt	  as observation_start_dt
             , o2.order_cd            as observation_source_value
             , null                   as value_as_concept_id
             , o2.target_concept_id_1 as target_concept_id_1
             , null	                  as target_concept_id_4
             , null	                  as target_concept_id_5
        	 , o2.source_concept_id	  as source_concept_id 
        	 , o2.source_domain_id	  as source_domain_id 
        	 , o2.target_domain_id	  as target_domain_id 
             , o2.reference_gb        as reference_gb
          from itfcdmpv532_daily.mt_rule_order o2 
         where o2.filtering = 'N' 
           and o2.target_domain_id = 'Observation' 
   
        union all 
        
--        create table itfcdmpv532_daily.mt_measurement_to_observation as
        select m2.uid                                                 as uid
             , m2.patient_id                                          as patient_id
             , m2.visit_no                                            as visit_no
             , m2.medical_dt                                          as medical_dt
             , m2.visit_gb                                            as visit_gb
             , m2.medical_dept                                        as medical_dept
             , m2.order_dr                                            as medical_dr
             , null                                                   as qualifier
             , coalesce(m2.result_txt,'')                             as result_txt
             , m2.result_num                                          as result_num
             , m2.result_unit                                         as result_unit
             , m2.measurement_dt                                      as observation_start_dt
             , m2.local_cd1                                           as observation_source_value
             , coalesce(m2.value_as_concept_id, m4.target_concept_id) as value_as_concept_id
             , m2.target_concept_id_1                                 as target_concept_id_1
             , null                                                   as target_concept_id_4
             , null                                                   as target_concept_id_5
             , m2.source_concept_id                                   as source_concept_id
             , m2.source_domain_id                                    as source_domain_id
             , m2.target_domain_id                                    as target_domain_id
             , m2.reference_gb                                        as reference_gb
          from itfcdmpv532_daily.mt_rule_measurement m2
          left join mapcdmpv532_daily.map_gb m4 
            on m2.result_category = m4.source_value 
           and m4.idx = 10155
         where m2.filtering = 'N'
           and m2.target_domain_id ='Observation'
    ) o ;;
