drop table  if exists cdmpv532_daily.payer_plan_period ;;

create table cdmpv532_daily.payer_plan_period as
select cast(p1.uid                            as integer)      as payer_plan_period_id		 
     , cast(p2.uid   			              as integer)      as person_id					 
     , cast(p1.ins_start_dt                   as date)	       as payer_plan_period_start_date 
     , cast(p1.ins_end_dt                     as date)	       as payer_plan_period_end_date	 
     , cast(m1.target_concept_id              as integer)      as payer_concept_id             
     , cast(p1.payer_source_value  	          as varchar(50))  as payer_source_value	         
     , cast(0                              as integer)      as payer_source_concept_id      
     , cast(0                              as integer)      as plan_concept_id              
     , cast(null            	              as varchar(50))  as plan_source_value			 
     , cast(0                              as integer)      as plan_source_concept_id       
     , cast(0                              as integer)      as sponsor_concept_id           
     , cast(null                              as varchar(50))  as sponsor_source_value         
     , cast(0                              as integer)      as sponsor_source_concept_id    
     , cast(null              	              as varchar(50))  as family_source_value			 
     , cast(0                              as integer)      as stop_reason_concept_id     --athena신청예정
     , cast(p1.stop_reason_source_value       as varchar(50))  as stop_reason_source_value     
     , cast(0                              as integer)      as stop_reason_source_concept_id
  from itfcdmpv532_daily.mt_payer_plan_period p1
 inner join itfcdmpv532_daily.mt_person       p2
    on p1.patient_id = p2.patient_id and p2.rn=1
  left join mapcdmpv532_daily.map_gb          m1
    on p1.payer_source_value = m1.source_value  -- insurance_gb --> payer_source_value 변경 20201125 by lsh
   and m1.idx = 1275
--  left join mapcdmpv532_daily.map_gb          m2  --신청완료되어 컨셉아이디 생기면 채워질 예정
--    on p1.ins_stop_gb = m2.source_value  
--   and m2.idx = 
  ;;

/*****************************************************
INDEX
*****************************************************/                                                  
ALTER TABLE cdmpv532_daily.payer_plan_period ADD CONSTRAINT xpk_payer_plan_period PRIMARY KEY ( payer_plan_period_id ) ;;
alter table cdmpv532_daily.payer_plan_period alter column person_id set not null;
alter table cdmpv532_daily.payer_plan_period alter column payer_plan_period_start_date set not null;
alter table cdmpv532_daily.payer_plan_period alter column payer_plan_period_end_date set not null;
CREATE INDEX idx_period_person_id  ON cdmpv532_daily.payer_plan_period  (person_id ASC);;
CLUSTER cdmpv532_daily.payer_plan_period  USING idx_period_person_id ;;
