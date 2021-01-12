
--mt_cost_--
CREATE INDEX mt_payer_plan_period_patient_id_idx ON itfcdmpv532_daily.mt_payer_plan_period (patient_id,visit_no,insurance_gb,uid);
CREATE INDEX itf_cost_order_dt_idx ON itfcdmpv532_daily.itf_cost (order_dt,order_no,order_cd,visit_no); --큰테이블에서 동작안함.
--mt_cost_--



--mt_cost_visit--
create or replace function ods_daily.cast_date(the_date timestamptz )
   returns date
   language sql
   immutable
as
$body$
  select date(the_date);
$body$
;

--CREATE INDEX itf_cost_patient_id_idx ON itfcdmpv532_daily.itf_cost (patient_id,cast_date(medical_dt));
CREATE INDEX mt_visit_detail_patient_id_idx ON itfcdmpv532_daily.mt_visit_detail (patient_id,cast_date(medical_dt));
--mt_cost_visit--