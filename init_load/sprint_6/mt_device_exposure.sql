drop table if exists itfcdmpv532_daily.mt_device_exposure;

create table itfcdmpv532_daily.mt_device_exposure as 
select row_number() over(order by d.uid) as device_exposure_id
     , d.*
  from(
       --create table itfcdmpv532_daily.mt_device_exposure_main as 
       select d2.uid
            , d2.patient_id
            , d2.visit_no
            , d2.order_no
            , d2.medical_dt
            , d2.visit_gb
            , d2.visit_gb_div
            , d2.remark
            , d2.medical_dept
            , d2.unit  
            , d2.stop_reason
            , d2.order_dt
            , d2.order_dr
            , d2.bill_order_gb
            , d2.device_start_dt
            , d2.device_end_dt
            , d2.self_drug_yn
            , d2.method_cd
            , d2.order_cd
            , d2.target_concept_id_1
            , d2.source_concept_id
            , d2.quantity
            , d2.order_day
            , d2.provider
            , d2.reference_gb
            , d2.source_domain_id
            , d2.target_domain_id
            , d2.target_concept_seq
            , d2.ward_cd
         from itfcdmpv532_daily.mt_rule_device_exposure d2 
        where d2.filtering = 'N' 
          and (d2.target_domain_id = 'Device' or d2.target_domain_id is null) 

          
       union all 
       
       --create table itfcdmpv532_daily.mt_drug_to_device as    
       select d2.uid
            , d2.patient_id
            , d2.visit_no
            , d2.order_no
            , d2.medical_dt
            , d2.visit_gb
            , d2.visit_gb_div
            , d2.remark
            , d2.medical_dept
            , d2.unit  
            , d2.stop_reason
            , d2.order_dt
            , d2.order_dr
            , d2.bill_order_gb
            , d2.drug_start_dt
            , d2.drug_end_dt
            , d2.self_drug_yn
            , d2.method_cd
            , d2.order_cd
            , d2.target_concept_id_1
            , d2.source_concept_id
            , d2.quantity
            , d2.order_day
            , d2.provider
            , d2.reference_gb
            , d2.source_domain_id
            , d2.target_domain_id
            , d2.target_concept_seq
            , d2.ward_cd
         from itfcdmpv532_daily.mt_rule_drug_exposure d2 
        where d2.filtering = 'N'
          and d2.target_domain_id = 'Device' 
        
       union all
         
       --create table itfcdmpv532_daily.mt_condition_to_device as 
       select c2.uid                 as uid
            , c2.patient_id          as patient_id
            , c2.visit_no            as visit_no
            , null                   as order_no
            , c2.medical_dt          as medical_dt
            , c2.visit_gb            as visit_gb
            , NULL                   as visit_gb_div
            , null                   as remark
            , c2.medical_dept        as medical_dept
            , null                   as drug_unit  
            , null                   as stop_reason
            , null                   as order_dt
            , c2.medical_dr          as order_dr
            , null                   as bill_order_gb
            , c2.condition_start_dt  as procedure_start_dt
            , c2.condition_end_dt    as procedure_end_dt
            , null                   as self_drug_yn
            , null                   as method_cd
            , c2.diagnosis_cd        as order_cd
            , c2.target_concept_id_1 as target_concept_id_1
            , c2.source_concept_id   as source_concept_id
            , 1                      as quantity  --null을 1로 대체
            , null                   as order_day
            , c2.medical_dr          as provider
            , '1'                   as reference_gb--EHR order list entry로 왔다는 의미로 고정해줌
            , c2.source_domain_id    as source_domain_id
            , c2.target_domain_id    as target_domain_id
            , c2.target_concept_seq
            , null                   as ward_cd
         from itfcdmpv532_daily.mt_rule_condition_occurrence c2 
        where c2.filtering = 'N'
          and c2.target_domain_id = 'Deivce'           
          
       union all
       
       --create table itfcdmpv532_daily.mt_procedure_to_device as  
       select p2.uid
            , p2.patient_id
            , p2.visit_no
            , p2.order_no
            , p2.medical_dt
            , p2.visit_gb
            , p2.visit_gb_div
            , p2.remark
            , p2.medical_dept
            , p2.unit  
            , p2.stop_reason
            , p2.order_dt
            , p2.order_dr
            , p2.bill_order_gb
            , p2.procedure_start_dt
            , p2.procedure_end_dt
            , p2.self_drug_yn
            , p2.method_cd
            , p2.order_cd
            , p2.target_concept_id_1
            , p2.source_concept_id
            , p2.quantity
            , p2.order_day
            , p2.provider
            , p2.reference_gb
            , p2.source_domain_id
            , p2.target_domain_id
            , p2.target_concept_seq
            , p2.ward_cd
         from itfcdmpv532_daily.mt_rule_procedure_occurrence p2 
        where p2.filtering = 'N'
          and p2.target_domain_id = 'Device'  
          
       union all
       
       --create table itfcdmpv532_daily.mt_order_to_device as    
       select o2.uid
            , o2.patient_id
            , o2.visit_no
            , o2.order_no
            , o2.medical_dt
            , o2.visit_gb
            , o2.visit_gb_div
            , o2.remark
            , o2.medical_dept
            , o2.unit  
            , o2.stop_reason
            , o2.order_dt
            , o2.order_dr
            , o2.bill_order_gb 
            , o2.order_start_dt
            , o2.order_end_dt
            , o2.self_drug_yn
            , o2.method_cd
            , o2.order_cd
            , o2.target_concept_id_1
            , o2.source_concept_id
            , o2.quantity
            , o2.order_day
            , o2.provider
            , o2.reference_gb
            , o2.source_domain_id
            , o2.target_domain_id
            , o2.target_concept_seq
            , o2.ward_cd
         from itfcdmpv532_daily.mt_rule_order o2 
        where o2.filtering = 'N'
          and o2.target_domain_id = 'Device' 
) d;  