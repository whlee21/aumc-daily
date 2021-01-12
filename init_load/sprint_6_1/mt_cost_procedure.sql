CREATE INDEX IF NOT EXISTS mt_procedure_occurrence_patient_id_idx ON itfcdmpv532_daily.mt_procedure_occurrence (patient_id,visit_no,order_no,order_dt);

drop table if exists itfcdmpv532_daily.mt_cost_procedure;;

create table itfcdmpv532_daily.mt_cost_procedure as
select * from (
    select 
          c1.uid
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
        , (select p1.procedure_occurrence_id 
             from itfcdmpv532_daily.mt_procedure_occurrence p1 
             left join mapcdmpv532_daily.local_hash lh
                    on lh.source_domain_id in ('Device','Drug','Order','Procedure')
                   and p1.order_cd = lh.local_cd_hash
            where c1.patient_id = p1.patient_id 
              and c1.order_no = p1.order_no
              and c1.order_dt = p1.order_dt
              and c1.order_cd = lh.local_cd1
              and c1.visit_no = p1.visit_no
              and p1.target_concept_seq = 1) as cost_event_id
        , 'Procedure' as cost_domain_id
          from itfcdmpv532_daily.itf_cost c1 
) a
where a.cost_event_id is not null
;