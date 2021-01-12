drop table if exists itfcdmpv532_daily.mt_drug_exposure; 

create table itfcdmpv532_daily.mt_drug_exposure as --12046270
select row_number() over(order by d.uid) as drug_exposure_id 
     , d.*
  from (
        --create table itfcdmpv532_daily.mt_drug_exposure_main as
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
             , d2.verbatim_end_date
             , d2.lot_number
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
           and (d2.target_domain_id = 'Drug' or d2.target_domain_id is null) 
        
        union all
        
        --create table itfcdmpv532_daily.mt_device_to_drug as    
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
             , d2.verbatim_end_date 
             , d2.lot_number             
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
           and d2.target_domain_id = 'Drug'

         
        union all
        
        --create table itfcdmpv532_daily.mt_order_to_drug as 
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
             , o2.verbatim_end_date
             , o2.lot_number             
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
           and o2.target_domain_id = 'Drug'  
) d ;
