drop table if exists itfcdmpv532_daily.mt_rule_cost;;

create table itfcdmpv532_daily.mt_rule_cost as
select
      c.patient_id
    , c.total_pay_amt
    , c.total_payer_amt
    , c.total_patient_amt
    , c.insurance_gb
    , c.order_cd
    , c2.target_value as cost_gb
    , case when c2.target_value = '75'  --의약품 |투약및조제료(재료,약품비) 약에대한 값만 입력 [주사료,마취료등은 해당하지 않음]
           then c.total_pay_amt end as paid_ingredient
    , case when c2.target_value = '63'  --투약료 |투약및조제료(행위) 약을 포장하는 행위등
           then c.total_pay_amt end as paid_dispending
    , c.drg_cd
    , c3.target_value as reference_gb
    , c4.target_value as currency_gb
    , c.visit_no
    , c.payer_plan_period_id
    , coalesce(b.cost_event_id,c.cost_event_id) as cost_event_id
    , coalesce(b.cost_domain_id,c.cost_domain_id) as cost_domain_id
    , case when c.cancel_yn='Y'                                                             then 'A' --CANCEL인 경우
        when c.total_pay_amt = 0 and c.total_payer_amt = 0 and c.total_patient_amt = 0      then 'B' --모든 비용이 0인 경우
        when coalesce(b.cost_event_id,c.cost_event_id) is null                              then 'C' --타도메인과 연결되지 않는 경우
        else 'N' end as filtering
  from itfcdmpv532_daily.mt_cost_pre c
  left join itfcdmpv532_daily.mt_cost_ord_tmp b
         on c.uid = b.uid
  left join mapcdmpv532_daily.constant c2
         on c.cost_gb = c2.source_value
        and c2.idx = 1301
  left join mapcdmpv532_daily.constant c3
         on c.reference_gb = c3.source_value
        and c3.idx = 1303
  left join mapcdmpv532_daily.constant c4
         on c.currency_gb = c4.source_value
        and c4.idx = 1302
;;
