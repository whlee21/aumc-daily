drop table if exists itfcdmpv532_daily.mt_cost;;

create table itfcdmpv532_daily.mt_cost as
SELECT
      row_number() over(order by null) as cost_id 
    , c.patient_id
    , c.total_pay_amt
    , c.total_payer_amt
    , c.total_patient_amt
    , c.insurance_gb
    , c.order_cd
    , c.cost_gb
    , c.paid_ingredient
    , c.paid_dispending
    , c.drg_cd
    , c.reference_gb
    , c.currency_gb
    , c.visit_no
    , c.payer_plan_period_id
    , c.cost_event_id
    , c.cost_domain_id
  from itfcdmpv532_daily.mt_rule_cost c
 where c.filtering='N'
;