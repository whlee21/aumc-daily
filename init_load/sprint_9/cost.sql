drop table if exists cdmpv532_daily.cost;;

create table cdmpv532_daily.cost as
select cast(c1.cost_id					as bigint)      as cost_id 
     , cast(c1.cost_event_id            as bigint)      as cost_event_id
     , cast(c1.cost_domain_id           as varchar)     as cost_domain_id
     , cast(m2.target_concept_id        as integer)     as cost_type_concept_id
     , cast(m1.target_concept_id        as integer)     as currency_concept_id
     , cast(null		            	as  float)      as total_charge			    
     , cast(c1.total_pay_amt		    as  float)      as total_cost				    
     , cast(null     			        as  float)      as total_paid			        
     , cast(c1.total_payer_amt	     	as  float)      as paid_by_payer	     	    
     , cast(c1.total_patient_amt        as  float)      as paid_by_patient			    
     , cast(null             		    as  float)      as paid_patient_copay		    
     , cast(null                        as  float)      as paid_patient_coinsurance    
     , cast(null                	    as  float)      as paid_patient_deductible	    
     , cast(null           			    as  float)      as paid_by_primary			    
     , cast(c1.paid_ingredient          as  float)      as paid_ingredient_cost        
     , cast(c1.paid_dispending		    as  float)      as paid_dispensing_fee		    
     , cast(c1.payer_plan_period_id     as  bigint)     as payer_plan_period_id	    
     , cast(null         		        as  float)      as amount_allowed		        
     , cast(m3.target_concept_id        as  integer)    as revenue_code_concept_id     
     , cast(c1.cost_gb                  as  varchar)    as revenue_code_source_value   
     , cast(null        			    as  integer)    as drg_concept_id			  --athena에 신청
     , cast(drg_cd           			as  varchar)    as drg_source_value			
  from itfcdmpv532_daily.mt_cost c1
  left join mapcdmpv532_daily.map_gb m1
    on c1.currency_gb = m1.source_value
   and m1.idx = 1379
  left join mapcdmpv532_daily.map_gb m2
    on c1.reference_gb = m2.source_value
   and m2.idx = 13710
  left join mapcdmpv532_daily.map_gb m3
    on c1.cost_gb = m3.source_value
   and m3.idx = 1378  

;

ALTER TABLE cdmpv532_daily.cost ADD CONSTRAINT xpk_visit_cost PRIMARY KEY ( cost_id ) ;
alter table cdmpv532_daily.cost alter column cost_event_id set not null;
alter table cdmpv532_daily.cost alter column cost_domain_id set not null;
alter table cdmpv532_daily.cost alter column cost_type_concept_id set not null;