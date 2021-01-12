drop table if exists itfcdmpv532_daily.mt_rule_device_exposure;

create table itfcdmpv532_daily.mt_rule_device_exposure as
select d.uid, d.patient_id, d.order_day, d.order_cd, d.target_concept_id_1, d.source_concept_id, d.source_domain_id, d.target_domain_id, d.target_concept_seq
     , d.device_start_dt, d.device_end_dt, d.provider, d.reference_gb, d.method_cd, d.self_drug_yn
     , d.visit_no, d.order_no, d.medical_dt, d.visit_gb, d.visit_gb_div, d.remark, d.medical_dept, d.unit, d.stop_reason, d.order_dt
     , d.order_dr, d.bill_order_gb, d.verbatim_end_date, d.lot_number
     , case when lower(d.target_domain_id) = 'drug'  and d.quantity > 0 then d.quantity  --약인 경우에 0초과인 경우 그대로 가져오고
            when (lower(d.target_domain_id) <> 'drug' or d.target_domain_id IS NULL) and d.quantity >= 1 then d.quantity else 1 end quantity -- 약이 아닌 경우 1 이하이거나 null라면  1로 대체, 약이어도 음수이거나 null인 경우 1로 대체
            --(target null 포함 by lsh 20200618)
	 , case when d.device_start_dt is null                               then 'H'  --시작일자가 null인 경우
            when d.device_start_dt::date > d.device_end_dt::date    then 'I'  --시작일자가 종료일자보다 나중인 경우
            when d.device_start_dt::date < d.birth_dt::date         then 'J'  --시작일자가 생년월일보다 먼저인 경우
            when d.patient_id is null                               then 'K'  --환자번호가 없는 경우
            when d.order_cd is null                                 then 'L'  --처방코드가 없는 경우
            when extract(year from d.device_start_dt)::integer - extract(year from d.birth_dt)::integer > 150 then 'M' --시작일자가 생년월일+150년보다 더 나중인 경우
            else d.filtering end as filtering
     , d.ward_cd
  from (select t2.uid, t2.patient_id, t2.order_day, t2.order_cd , t2.target_concept_id_1, t2.source_concept_id, t2.source_domain_id, t2.target_domain_id, t2.target_concept_seq
             , t2.device_start_dt, t2.provider, t2.quantity, t2.reference_gb, t2.method_cd, t2.self_drug_yn, t2.birth_dt, t2.filtering
             , t2.visit_no, t2.order_no, t2.medical_dt, t2.visit_gb, t2.visit_gb_div, t2.remark, t2.medical_dept, t2.unit, t2.stop_reason, t2.order_dt
             , t2.order_dr, t2.bill_order_gb, t2.verbatim_end_date, t2.lot_number              
             , case when coalesce(d2.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd')) < t2.device_end_dt                   then d2.death_datetime --사망일자가 종료일자보다 먼저일 경우 종료일자를 사망일자로 대체함
                    when (t2.device_end_dt is null or t2.device_end_dt::date = '9999-12-31'::date) and d2.death_datetime is not null then d2.death_datetime --종료일자가 불분명한 경우에 사망일자가 명확한 케이스에 한 하여 사망일자로 대체함
                    when t2.device_end_dt is not null and t2.device_end_dt > now()                                                   then now()
                    else t2.device_end_dt end as device_end_dt
             , t2.ward_cd
          from ( select case when t1.visit_gb_div in ('9201', '9203', '32037') and discharge_drug_yn <> 'Y' --입원 또는 응급이면서 퇴원약이 아닌 경우  
                           then t1.device_start_dt --1 day 처방
                           else t1.device_start_dt + (interval '1 day' * (t1.order_day - 1)) end as device_end_dt --기존  t1.drug_start_dt를 date로 형변환하면 시간 데이터가 loss되어 로직 변경함 
                      , case when t1.tot_order_qty is not null  --처방량 마스터 개념
                           then t1.tot_order_qty 
                           when t1.visit_gb_div in ('9201', '9203', '32037') and t1.rad_qty is null and t1.discharge_drug_yn <> 'Y' --입원 또는 응급이면서 방사선처방과 퇴원약 처방이 아닌 경우  
                           then t1.order_qty1 * t1.order_cnt
                           when t1.rad_qty is not null 
                           then t1.rad_qty
                           else t1.order_qty1 * t1.order_cnt * t1.order_day end as quantity 
                      , t1.* 
                  from (
                        select d1.uid 
                             , p2.patient_id 
                             , lh.local_cd_hash as order_cd
                             , d1.discharge_drug_yn
                             , d1.visit_no
                             , d1.order_no
                             , d1.medical_dt
                             , d1.visit_gb
                             , d1.remark
                             , d1.medical_dept
                             , d1.unit  
                             , d1.stop_reason
                             , d1.order_dt
                             , d1.order_dr
                             , d1.lot_number
                             , d1.bill_order_gb
                             , d1.verbatim_end_date
                             , d1.order_cnt
                             , d1.order_qty1
                             , d1.order_qty2
                             , d1.order_day
                             , p2.uid as person_id 
                             , p2.birth_dt
                             , m1.target_concept_id_1
                             , m1.source_concept_id
                             , m1.source_domain_id 
                             , m1.target_domain_id
                             , m1.seq as target_concept_seq
                             , c2.target_value as visit_gb_div
                             , c4.target_value as reference_gb
                             , c5.target_value as method_cd
                             , c6.target_value as self_drug_yn
                             , case when c1.target_value = '1113'  --수술
                                    then coalesce(d1.operation_dt, d1.start_dt, d1.act_dt, d1.order_dt)
                                    when c1.target_value = '1114'  --마취
                                    then coalesce(d1.anesthesia_dt, d1.start_dt, d1.act_dt, d1.order_dt)
                                    else coalesce(d1.start_dt, d1.act_dt, d1.order_dt) end as device_start_dt   
                             , case when c1.target_value = '1113'  --수술
                                    then coalesce(d1.operation_dr, d1.act_provider, d1.act_dr, d1.order_dr, d1.charge_dr)
                                    when c1.target_value = '1114'  --마취 
                                    then coalesce(d1.anesthesia_dr, d1.act_provider, d1.act_dr, d1.order_dr, d1.charge_dr) 
                                    else coalesce(d1.act_provider, d1.act_dr, d1.order_dr, d1.charge_dr) end as provider
                             , case when c1.target_value = '1118' then d1.order_qty2 - d1.order_qty1 end as rad_qty  --방사선량
                             , case when d1.tot_order_yn = 'Y' then d1.tot_order_qty end as tot_order_qty
                             , case when d1.dc_yn1 = 'Y'        or d1.dc_yn2 = 'Y' /*or d1.dc_order_seq is not null 삭제 BY LSH 20200617*/ then 'A'----DC 관련
                                    when d1.cancel_yn = 'Y'     or d1.cancel_dt is not null                       then 'B'----CANCEL 관련
                                    when d1.prn_order_yn = 'Y' and d1.prn_act_yn = 'N'                            then 'C'----PRN 관련
                                    when d1.pre_order_yn = 'Y' and d1.pre_order_act_yn = 'N'                      then 'D'----PRE 관련
                                    when d1.act_yn is not null and d1.act_yn = 'N'                                then 'E'----ACT 관련
                                    when c3.target_value = '9999'                                                 then 'F'----not 정규처방
                                    when d1.order_cnt  < 0 or d1.order_qty1 < 0 or d1.order_qty2 < 0 
                                         or d1.order_day < 0 or d1.tot_order_qty < 0                              then 'G'----음수값
                                    else 'N' end as filtering
                             , d1.ward_cd                        
                          from itfcdmpv532_daily.itf_device_exposure d1 
                          left join itfcdmpv532_daily.itf_person p2 
                            on d1.patient_id = p2.patient_id -- and p2.rn=1
                           left join mapcdmpv532_daily.local_hash lh
                            on nullif(trim(d1.order_cd),'') = lh.local_cd1 and lh.source_domain_id = 'Device'
                           left join mapcdmpv532_daily.map_main_hash m1
                            on lh.local_cd_hash = m1.local_cd_hash
                          left join mapcdmpv532_daily.constant c1 
                            on d1.order_class_gb = c1.source_value 
                           and c1.idx = 4003
                          left join mapcdmpv532_daily.constant c2 
                            on d1.visit_gb = c2.source_value 
                           and c2.idx = 4004
                          left join mapcdmpv532_daily.constant c3 
                            on d1.order_gb = c3.source_value
                           and c3.idx = 4002
                          left join mapcdmpv532_daily.constant c4 
                            on d1.reference_gb = c4.source_value 
                           and c4.idx = 4001
                          left join mapcdmpv532_daily.constant c5 
                            on d1.method_cd = c5.source_value 
                           and c5.idx = 4005  
                          left join mapcdmpv532_daily.constant c6 
                            on d1.self_drug_yn = c6.source_value 
                           and c6.idx = 4006
                       ) t1 ) t2 left join cdmpv532_daily.death d2 on t2.person_id = d2.person_id --mt_death에는 동일환자 다른 환자번호 일 때 한 환자번호에서 사망시간이 없는  레코드 있기 때문에 death를 조인하여 사망시간을 가져옴
       