drop table if exists itfcdmpv532_daily.mt_rule_measurement;;

create table itfcdmpv532_daily.mt_rule_measurement as
select m1.uid, m2.target_concept_id_1, m2.source_concept_id, m2.source_domain_id, m2.target_domain_id, m2.seq as target_concept_seq, m1.patient_id/*, m1.exam_cd*/
     , m1.exam_sub_cd, m1.specimen_cd/*, m1.antibiotic_cd*/, m1.examination_gb, lh2.local_cd_hash AS local_cd1, m1.local_cd2, m1.local_cd3, m1.birth_dt
     , m1.value_as_concept_id, m1.visit_gb, m1.result_operator, m1.result_category, m1.reference_gb, m1.measurement_dt, m1.provider
     , m1.visit_no, m1.order_no, m1.order_dt, m1.order_dr, m1.medical_dt, m1.medical_dept, m1.specimen_no, m1.bacteria_cd
     , m1.relation_no, m1.antibiotic_yn, m1.result_num, m1.result_txt, m1.result_unit, m1.normal_max, m1.normal_min   
     , case when m1.measurement_dt is null                                                                                           then 'D' --시작일자가 null인 경우
            when m1.measurement_dt::date < m1.birth_dt::date                                                                         then 'E' --시작일자가 생년월일보다 먼저인 경우 
            when m1.measurement_dt::date > coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd'))                    then 'F' --시작일자가 사망일자보다 나중인 경우
            when m1.patient_id     is null                                                                                           then 'G' --환자번호가 없는 경우
            when m1.local_cd1      is null                                                                                           then 'H' --measurement_source_value가 null인 경우
            when extract(year from m1.measurement_dt)::integer - extract(year from m1.birth_dt)::integer > 150                       then 'I' --시작일자가 생년월일+150년 보다 나중인 경우
--          when m1.target_concept_id_1 not in (3004959, 3003129, 3007435, 3006277, 3002032, 3012501, 3003396) and m1.result_num < 0 then 'J' --특정 measurement_concept_id를 제외하고 검사 결과값이 음수인 경우/ 음수 결과값 나올 수 있는 검사는 7개 이외에도 더 있어보여서 논의 필요                                                                              then 'J' --검사 결과값이 음수인 경우 
            when m1.local_cd1      is null                                                                                           then 'k' --hash와 연결안됨 or exam_cd null
            else m1.filtering end as filtering
    from( select m1.uid 
               , p2.patient_id, m1.exam_cd, m1.exam_sub_cd, m1.specimen_cd, m1.antibiotic_cd, m1.examination_gb, m1.visit_no
               , m1.order_no, m1.order_dt, m1.order_dr, m1.medical_dt, m1.medical_dept, m1.specimen_no, m1.relation_no, m1.antibiotic_yn
               , m1.result_num, m1.result_txt, m1.result_unit, m1.normal_max, m1.normal_min, m1.visit_gb, m1.bacteria_cd
               , case when m1.antibiotic_yn = 'Y' then m1.antibiotic_cd  else m1.exam_cd end as local_cd1
               , case when m1.antibiotic_yn = 'Y' then m1.examination_gb else coalesce(m1.specimen_cd, m1.exam_sub_cd,'') end as local_cd2
               , case when m1.antibiotic_yn = 'Y' then '' else coalesce(m1.result_unit,'') end as local_cd3 ---- 추가 20200103
               , p2.uid as person_id
               , p2.birth_dt
               , m5.target_concept_id_1 as value_as_concept_id
               , c2.target_value as result_operator
               , c3.target_value as result_category
               , c4.target_value as reference_gb
               , coalesce(m1.execute_dt, m1.record_dt, m1.order_dt, m1.medical_dt)  as measurement_dt
               , coalesce(m1.act_dr, m1.recorder, m1.order_dr) as provider
               , case when m1.valid_yn = 'N'                               then 'A'----valid 관련
                      when m1.cancel_yn = 'Y' or m1.cancel_dt is not null  then 'B'----cancel 관련
                      when m1.prn_order_yn = 'Y' and m1.prn_act_yn = 'N'   then 'C'----prn 관련
                      else 'N' end as filtering
            from itfcdmpv532_daily.itf_measurement m1
            left join itfcdmpv532_daily.mt_person p2
              on m1.patient_id = p2.patient_id and p2.rn=1
            left join (
              select lh.local_cd1, m5.target_concept_id_1
              from mapcdmpv532.local_hash lh,
                    mapcdmpv532.map_main_hash m5
              where lh.source_domain_id = 'Measurement_value'
                and lh.local_cd_hash = m5.local_cd_hash
                and m5.source_domain_id = 'Measurement_value'
          ) m5    
            on   m1.bacteria_cd = m5.local_cd1
            left join mapcdmpv532_daily.constant c2
              on m1.result_operator = c2.source_value
             and c2.idx = 1003
            left join mapcdmpv532_daily.constant c3
              on m1.result_category = c3.source_value
             and c3.idx = 1001
            left join mapcdmpv532_daily.constant c4
              on m1.reference_gb = c4.source_value
             and c4.idx = 1002
        ) m1 left join mapcdmpv532_daily.local_hash lh2
              on nullif(trim(m1.local_cd1),'') = lh2.local_cd1 and m1.local_cd2 = lh2.local_cd2 and m1.local_cd3 = lh2.local_cd3 ---20200103 추가 이승형 검사UNIT
             and lh2.source_domain_id ='Measurement'
             left join mapcdmpv532_daily.map_main_hash m2
              on lh2.local_cd_hash = m2.local_cd_hash
             left join cdmpv532_daily.death d1 on m1.person_id = d1.person_id
            ;