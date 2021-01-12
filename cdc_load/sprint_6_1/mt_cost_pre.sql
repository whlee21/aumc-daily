drop table if exists itfcdmpv532_daily.mt_cost_pre;;

create table itfcdmpv532_daily.mt_cost_pre as
select uid
     , c1.patient_id
     , c1.total_pay_amt 
     , c1.total_payer_amt
     , c1.total_patient_amt 
     , c1.insurance_gb
     , (select lh.local_cd_hash from mapcdmpv532_daily.local_hash lh
         where lh.source_domain_id in ('Device','Drug','Order','Procedure')
        and c1.order_cd = lh.local_cd1 ) as order_cd 
     , c1.order_no
     , c1.order_dt
     , c1.visit_no
     , case when c1.drg_gb = 'Y' then c1.drg_cd end as drg_cd
     , c1.cost_gb
     , c1.reference_gb
     , c1.currency_gb
     , c1.cancel_yn
     , (select p2.uid from itfcdmpv532_daily.mt_payer_plan_period p2 
                    where c1.patient_id = p2.patient_id 
                      and c1.visit_no = p2.visit_no
                      and c1.insurance_gb = p2.insurance_gb limit 1) as payer_plan_period_id
     , (select v1.visit_occurrence_id 
         from itfcdmpv532_daily.mt_visit_detail v1 
        where c1.patient_id = v1.patient_id 
          and cast_date(c1.medical_dt) = cast_date(v1.medical_dt) 
          and case when c1.visit_no is not null then c1.visit_no = v1.visit_no else c1.visit_gb = v1.visit_gb and c1.medical_dept = v1.medical_dept end
          order by v1.visit_detail_id limit 1)as cost_event_id
     , 'Visit' as cost_domain_id
  from  itfcdmpv532_daily.itf_cost c1
;
