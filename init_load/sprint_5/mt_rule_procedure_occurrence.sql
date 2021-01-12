drop table if exists itfcdmpv532_daily.mt_rule_procedure_occurrence;

create table itfcdmpv532_daily.mt_rule_procedure_occurrence as  
select p.uid, p.patient_id, p.order_day, p.order_cd, p.target_concept_id_1, p.source_concept_id, p.source_domain_id, p.target_domain_id, p.target_concept_seq
     , p.procedure_start_dt, p.procedure_end_dt, p.provider, p.reference_gb, p.method_cd, p.self_drug_yn
     , p.visit_no, p.order_no, p.medical_dt, p.visit_gb, p.visit_gb_div, p.remark, p.medical_dept, p.unit, p.stop_reason, p.order_dt
     , p.order_dr, p.bill_order_gb, p.verbatim_end_date, p.lot_number
     , case when lower(p.target_domain_id) = 'drug' and p.quantity > 0 then p.quantity  ----약인 경우에 0초과인 경우 그대로 가져오고
            when (lower(p.target_domain_id) <> 'drug' OR p.target_domain_id IS NULL)  and p.quantity >= 1 then p.quantity else 1 end quantity -- 약이 아닌 경우 1 이하이거나 null라면  1로 대체, 약이어도 음수이거나 null인 경우 1로 대체
            -- TARGET NULL 포함 20200618 BY LSH
     , case when p.procedure_start_dt is null                           then 'H' --시작일자가 null인 경우
            when p.procedure_start_dt::date > p.procedure_end_dt::date  then 'I' --시작일자가 종료일자보다 나중인 경우
            when p.procedure_start_dt::date < p.birth_dt::date          then 'J' --시작일자가 생년월일보다 먼저인 경우
            when p.patient_id is null                                   then 'K' --환자번호가 없는 경우
            when p.order_cd is null                                     then 'L' --처방코드가 없는 경우
            when extract(year from p.procedure_start_dt)::integer - extract(year from p.birth_dt)::integer > 150 then 'M'  --시작일자가 생년월일+150년보다 더 나중인 경우
            else p.filtering end as filtering
     , p.ward_cd
  from (select t2.uid, t2.patient_id, t2.order_day, t2.order_cd , t2.target_concept_id_1, t2.source_concept_id, t2.source_domain_id, t2.target_domain_id, t2.target_concept_seq
             , t2.procedure_start_dt, t2.provider, t2.quantity, t2.reference_gb, t2.method_cd, t2.self_drug_yn, t2.birth_dt, t2.filtering
             , t2.visit_no, t2.order_no, t2.medical_dt, t2.visit_gb, t2.visit_gb_div, t2.remark, t2.medical_dept, t2.unit, t2.stop_reason, t2.order_dt
             , t2.order_dr, t2.bill_order_gb, t2.verbatim_end_date, t2.lot_number             
             , case when coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd')) < t2.procedure_end_dt                      then d1.death_datetime --사망일자가 종료일자보다 먼저일 경우 종료일자를 사망일자로 대체함
                    when (t2.procedure_end_dt is null or t2.procedure_end_dt::date = '9999-12-31'::date) and d1.death_datetime is not null then d1.death_datetime --종료일자가 불분명한 경우에 사망일자가 명확한 케이스에 한 하여 사망일자로 대체함
                    when t2.procedure_end_dt is not null and t2.procedure_end_dt > now()                                                   then now()
                    else t2.procedure_end_dt end as procedure_end_dt
             , t2.ward_cd
         from (select case when t1.visit_gb_div in ('9201', '9203', '32037') and discharge_drug_yn <> 'Y' --외래 또는 응급이면서 퇴원약이 아닌 경우
                           then t1.procedure_start_dt --1 day 
                           else t1.procedure_start_dt + (interval '1 day' * (t1.order_day - 1)) end as procedure_end_dt --기존  t1.drug_start_dt를 date로 형변환하면 시간 데이터가 loss되어 로직 변경함
                    , case when t1.tot_order_qty is not null 
                           then t1.tot_order_qty 
                           when t1.visit_gb_div in ('9201', '9203', '32037') and t1.rad_qty is null and t1.discharge_drug_yn <> 'Y'  --입원 또는 응급이면서 방사선처방과 퇴원약 처방이 아닌 경우
                           then t1.order_qty1 * t1.order_cnt
                           when t1.rad_qty is not null 
                           then t1.rad_qty
                           else t1.order_qty1 * t1.order_cnt * t1.order_day end as quantity 
                    , t1.* 
                 from (select p1.uid
                            , p2.patient_id 
                            , lh.local_cd_hash as order_cd
                            , p1.discharge_drug_yn
                            , p1.visit_no
                            , p1.order_no
                            , p1.medical_dt
                            , p1.visit_gb
                            , p1.remark
                            , p1.medical_dept
                            , p1.unit  
                            , p1.stop_reason
                            , p1.order_dt
                            , p1.order_dr
                            , p1.bill_order_gb
                            , p1.verbatim_end_date
                            , p1.lot_number
                            , p1.order_cnt
                            , p1.order_qty1
                            , p1.order_qty2
                            , p1.order_day
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
                                   then coalesce(p1.operation_dt, p1.start_dt, p1.act_dt, p1.order_dt, p1.order_dt)
                                   when c1.target_value = '1114'  --마취
                                   then coalesce(p1.anesthesia_dt, p1.start_dt, p1.act_dt, p1.order_dt, p1.order_dt)
                                   else coalesce(p1.start_dt, p1.act_dt, p1.order_dt) end as procedure_start_dt   
                            , case when c1.target_value = '1113'  --수술
                                   then coalesce(p1.operation_dr, p1.act_provider, p1.act_dr, p1.order_dr, p1.charge_dr)
                                   when c1.target_value = '1114'  --마취
                                   then coalesce(p1.anesthesia_dr, p1.act_provider, p1.act_dr, p1.order_dr, p1.charge_dr) 
                                   else coalesce(p1.act_provider, p1.act_dr, p1.order_dr, p1.charge_dr) end as provider
                            , case when c1.target_value = '1118' then p1.order_qty2 - p1.order_qty1 end as rad_qty  --방사선량
                            , case when p1.tot_order_yn = 'Y' then p1.tot_order_qty end as tot_order_qty
                            , case when p1.dc_yn1 = 'Y'        or p1.dc_yn2 = 'Y' /*or p1.dc_order_seq is not null 삭제 BY LSH 20200617*/ then 'A'   ----DC 처방인 경우
                                   when p1.cancel_yn = 'Y'     or p1.cancel_dt is not null                       then 'B'   ----처방 취소인 경우
                                   when p1.prn_order_yn = 'Y' and p1.prn_act_yn = 'N'                            then 'C'   ----PRN처방인 경우
                                   when p1.pre_order_yn = 'Y' and p1.pre_order_act_yn = 'N'                      then 'D'   ----PRE처방인 경우
                                   when p1.act_yn is not null and p1.act_yn = 'N'                                then 'E'   ----처방을 실시하지 않은 경우
                                   when c3.target_value = '9999'                                                 then 'F'   ----정규처방이 아닌 경우
                                   when p1.order_cnt  < 0 or p1.order_qty1 < 0 or p1.order_qty2 < 0
                                        or p1.order_day < 0 or p1.tot_order_qty < 0                              then 'G'   ----처방량이 음수인 경우
                                   else 'N' end as filtering
                            , p1.ward_cd
                         from itfcdmpv532_daily.itf_procedure_occurrence p1 
                         left join itfcdmpv532_daily.mt_person p2 on p2.rn=1
                           and p1.patient_id = p2.patient_id 
                         left join mapcdmpv532_daily.local_hash lh
                            on nullif(trim(p1.order_cd),'') = lh.local_cd1 and lh.source_domain_id = 'Procedure'
                           left join mapcdmpv532_daily.map_main_hash m1
                            on lh.local_cd_hash = m1.local_cd_hash
                         left join mapcdmpv532_daily.constant c1 
                           on p1.order_class_gb = c1.source_value 
                          and c1.idx = 2203
                         left join mapcdmpv532_daily.constant c2 
                           on p1.visit_gb = c2.source_value 
                          and c2.idx = 2204  
                         left join mapcdmpv532_daily.constant c3 
                           on p1.order_gb = c3.source_value
                          and c3.idx = 2202
                         left join mapcdmpv532_daily.constant c4 
                           on p1.reference_gb = c4.source_value
                          and c4.idx = 2201
                         left join mapcdmpv532_daily.constant c5 
                           on p1.method_cd = c5.source_value 
                          and c5.idx = 2205
                         left join mapcdmpv532_daily.constant c6
                           on p1.self_drug_yn = c6.source_value 
                          and c6.idx = 2206
                      ) t1 ) t2 left join cdmpv532_daily.death d1 on t2.person_id = d1.person_id  --mt_death에는 동일환자 다른 환자번호 일 때 한 환자번호에서 사망시간이 없는  레코드 있기 때문에 death를 조인하여 사망시간을 가져옴 
                      ) p
;