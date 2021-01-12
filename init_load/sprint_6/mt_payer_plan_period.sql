drop table if exists itfcdmpv532_daily.mt_payer_plan_period;; 

create table itfcdmpv532_daily.mt_payer_plan_period as 
select p2.uid
     , p2.patient_id
	 , p2.visit_no
	 , p2.ins_start_dt
	 , p2.insurance_gb
	 , p2.ins_stop_gb
	 , p2.payer_source_value
	 , p2.stop_reason_source_value
	 , p2.ins_end_dt
  from itfcdmpv532_daily.mt_rule_payer_plan_period p2 
 where p2.filtering = 'N'
;;
