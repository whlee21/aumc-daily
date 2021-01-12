drop table if exists itfcdmpv532_daily.mt_condition_occurrence;  

create table itfcdmpv532_daily.mt_condition_occurrence as 
select row_number() over(order by c.uid) as condition_occurrence_id
     , c.*
  from(
     --create table itfcdmpv532_daily.mt_condition_occurrence_main as  
       select c2.uid
            , c2.patient_id
            , c2.symptom  
            , c2.rule_out_yn 
            , c2.visit_no
            , c2.medical_dt 
            , c2.medical_dept
            , c2.medical_dr
            , c2.visit_gb
            , c2.stop_reason
            , c2.diagnosis_cd
            , c2.target_concept_id_1
            , c2.source_concept_id
            , c2.main_yn
            , c2.condition_start_dt
            , c2.condition_end_dt
            , c2.diagnosis_status_gb
       	    , c2.source_domain_id
       	    , c2.target_domain_id
         from itfcdmpv532_daily.mt_rule_condition_occurrence c2 
        where c2.filtering = 'N'
          and (c2.target_domain_id = 'Condition' or c2.target_domain_id is null) --소스도메인이나 타겟도메인 없는 상병코드는 condition으로 보냄
          
       union all
       
       --create table itfcdmpv532_daily.mt_procedure_to_condition as 
       select p2.uid                 as uid 
            , p2.patient_id          as patient_id
            , null                   as symptom  
            , null                   as rule_out_yn 
            , p2.visit_no            as visit_no
            , p2.medical_dt          as medical_dt 
            , p2.medical_dept        as medical_dept
            , p2.order_dr            as medical_dr
            , p2.visit_gb            as visit_gb
            , null                   as stop_reason
            , null                   as diagnosis_cd
            , p2.target_concept_id_1 as target_concept_id_1
            , p2.source_concept_id   as source_concept_id
            , null                   as main_yn
            , p2.procedure_start_dt  as condition_start_dt
            , p2.procedure_end_dt    as condition_end_dt
            , null                   as diagnosis_status_gb
       	    , p2.source_domain_id    as source_domain_id
       	    , p2.target_domain_id    as target_domain_id  
         from itfcdmpv532_daily.mt_rule_procedure_occurrence p2 
        where p2.filtering = 'N'  
          and p2.target_domain_id = 'Condition' 
          
       union all
       
       --create table itfcdmpv532_daily.mt_order_to_condition as 
       select o2.uid                  as uid
            , o2.patient_id           as patient_id
            , null                    as symptom    
            , null                    as rule_out_yn
            , o2.visit_no             as visit_no
            , o2.medical_dt           as medical_dt
            , o2.medical_dept         as medical_dept         
            , o2.order_dr             as medical_dr
            , o2.visit_gb             as visit_gb 
            , o2.stop_reason          as stop_reason
            , o2.order_cd             as diagnosis_cd
            , o2.target_concept_id_1  as target_concept_id_1
            , o2.source_concept_id    as source_concept_id
            , null                    as main_yn
            , o2.order_start_dt       as condition_start_dt
            , o2.order_end_dt         as condition_end_dt
            , null                    as diagnosis_status_gb
       	    , o2.source_domain_id     as source_domain_id
       	    , o2.target_domain_id     as target_domain_id 
         from itfcdmpv532_daily.mt_rule_order o2 
        where o2.filtering = 'N'
          and o2.target_domain_id = 'Condition' 
        ) c;
