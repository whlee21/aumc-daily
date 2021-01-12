drop table if exists itfcdmpv532_daily.mt_rule_condition_occurrence;

create table itfcdmpv532_daily.mt_rule_condition_occurrence as
select c.*
     , case when (c.cancel_dt is not null or cancel_yn = 'Y')              then 'A'  --취소관련
            when c.condition_start_dt is null                              then 'B'  --시작일자가 null인 경우
            when c.condition_start_dt::date > c.condition_end_dt::date     then 'C'  --시작일자가 종료일자보다 나중인 경우
            when c.condition_start_dt::date < c.birth_dt::date             then 'D'  --시작일자가 생년월일보다 이른 경우
            when c.patient_id is null                                      then 'F'  --환자번호가 없는 경우
            when nullif(c.diagnosis_cd,'') is null                                    then 'G'  --진단코드가 null인 경우
            when extract(year from c.condition_start_dt)::integer - extract(year from c.birth_dt)::integer > 150 then 'H' --시작일자가 생년월일+150년 보다 더 나중인 경우
            else 'N' end as filtering        
  from( select t.uid, t.patient_id, t.condition_start_dt, t.diagnosis_cd, t.target_concept_id_1, t.target_concept_id_2, t.source_concept_id, t.target_concept_seq, t.birth_dt
             , t.diagnosis_status_gb, t.source_domain_id, t.target_domain_id, t.main_yn, t.cancel_dt, t.cancel_yn
             , t.symptom, t.rule_out_yn, t.visit_no, t.medical_dt, t.medical_dept, t.medical_dr, t.visit_gb, t.stop_reason
             , case when t.condition_end_dt > coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd'))                                  then d1.death_datetime --condition_end_dt가 사망일보다 나중이라면 사망일을 condition_end_dt로 대체함
                    when (t.condition_end_dt is null or t.condition_end_dt::date = '9999-12-31'::date) and d1.death_datetime is not null              then d1.death_datetime --종료일자가 불분명한 경우에 사망일자가 명확한 케이스에 한 하여 사망일자로 대체함
                    when t.condition_end_dt is not null and t.condition_end_dt > now()                                                                then now()      --themis에서 현재보다 미래이면 현재로 대체하라고 함
                    when cast(t.condition_end_dt as time) = '00:00:00' and t.condition_start_dt::date::varchar = t.condition_end_dt::date::varchar then t.condition_start_dt
                    else t.condition_end_dt end as condition_end_dt
          from (select c1.uid 
                     , p1.patient_id
                     , c1.cancel_dt
                     , c1.cancel_yn
                     , lh.local_cd_hash as diagnosis_cd
                     , c1.symptom  
                     , c1.rule_out_yn 
                     , c1.visit_no
                     , c1.medical_dt 
                     , c1.medical_dept
                     , c1.medical_dr
                     , c1.visit_gb
                     , c1.stop_reason
                     , case when c2.target_value in ('9201', '9203')  --입원,응급
                            then coalesce(c1.admission_dt, c1.diag_dt)
                            else coalesce(c1.diag_dt, c1.medical_dt) end as condition_start_dt
                     , case when c2.target_value in ('9201', '9203') ---입원,응급
                            then c1.discharge_dt
                            else coalesce(c1.diag_dt, c1.medical_dt) end as condition_end_dt
                     , case when (c1.diagnosis_cd <> '' and c1.diagnosis_cd is not null) and c1.rule_out_yn = 'Y'
                            then 'PRELIMINARY'
                            when (c1.diagnosis_cd <> '' and c1.diagnosis_cd is not null) and c1.rule_out_yn = 'N'
                            then 'FINAL'
                            when c2.target_value = '9201' and c1.discharge_diag_yn = 'Y' --입원이면서 퇴원진단인 경우
                            then 'FINAL'
                            when c2.target_value = '9201' and c1.discharge_diag_yn = 'N' --입원이면서 퇴원진단이 아닌 경우
                            then 'ADMISSION'
                            else 'PRELIMINARY' end as diagnosis_status_gb
                     , c3.target_value as main_yn
                     , p1.uid as person_id
                     , p1.birth_dt
                     , m1.target_concept_id_1
                     , m1.target_concept_id_2
                     , m1.source_concept_id
                     , m1.source_domain_id
                     , case when c1.rule_out_yn = 'Y' then 'Observation' else m1.target_domain_id end as target_domain_id --의증인 경우에 도메인을 observation으로 보내기 위해 적용함
                     , m1.seq as target_concept_seq
                  from itfcdmpv532_daily.itf_condition_occurrence c1
                  left join itfcdmpv532_daily.itf_person p1
                    on c1.patient_id = p1.patient_id -- and p1.rn=1
                  left join mapcdmpv532_daily.local_hash lh
                    on nullif(trim(c1.diagnosis_cd),'') = lh.local_cd1 and lh.source_domain_id = 'Condition'
                  left join mapcdmpv532_daily.map_main_hash m1
                    on lh.local_cd_hash = m1.local_cd_hash
                  left join mapcdmpv532_daily.constant c2
                    on c1.visit_gb = c2.source_value
                   and c2.idx = 702
                  left join mapcdmpv532_daily.constant c3
                    on c1.main_yn = c3.source_value
                   and c3.idx = 701
        ) t left join cdmpv532_daily.death d1 on t.person_id = d1.person_id --mt_death에는 동일환자 다른 환자번호 일 때 한 환자번호에서 사망시간이 없는  레코드 있기 때문에 death를 조인하여 사망시간을 가져옴   
        ) c
;
