drop table if exists itfcdmpv532_daily.mt_specimen;;

create table itfcdmpv532_daily.mt_specimen as
select row_number() over(order by s2.uid) as specimen_id
     , s2.uid                   
     , s2.patient_id                     
     , s2.medical_dt      	      
     , s2.specimen_no     
     , s2.specimen_cd    
     , s2.specimen_dt
     , s2.quantity 	 
     , s2.site            
     , s2.unit                    
     , s2.examination_rslt
     , s2.reference_gb 
	 , s2.target_concept_id_1
	 , s2.source_concept_id
     , s2.source_domain_id
     , s2.target_domain_id	 
  from itfcdmpv532_daily.mt_rule_specimen s2 
 where s2.filtering = 'N'
   and (s2.target_domain_id = 'Specimen' or s2.target_domain_id is null)
 ;;
