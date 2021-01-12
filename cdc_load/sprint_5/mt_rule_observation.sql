drop table if exists itfcdmpv532_daily.mt_rule_observation;;

create table itfcdmpv532_daily.mt_rule_observation as 
select t.uid
     , t.patient_id
     , t.visit_no
     , t.medical_dt
     , t.visit_gb
     , t.medical_dept
     , t.medical_dr
     , t.qualifier
     , t.result_txt
     , t.result_num 
     , t.result_unit
     , t.form_nm     
     , t.observation_start_dt 
     , t.target_concept_id_1
     , t.target_concept_id_4
     , t.target_concept_id_5
     , t.source_concept_id
     , t.source_domain_id
     , t.target_domain_id
     , t.target_concept_seq
     , t.reference_gb
     /*
     , coalesce(t.observation_item1,'')||' / '||
       coalesce(t.observation_item2,'')||' / '||
       coalesce(t.observation_item3,'')||' / '||
       coalesce(t.result_txt,'') as observation_source_value
      */
     , observation_source_value
     , case when result_txt = 'Y' then t.target_concept_id_2 
            when result_txt = 'N' then t.target_concept_id_3 end as value_as_concept_id  --
     , case /*when t.observation_item1 is null                       then 'A'  --문항이 null인 경우*/
            when t.result_txt is null and t.result_num is null     then 'B'  --결과값이 null인 경우
            when t.form_nm is null                                 then 'C'  --서식지가 null인 경우(서식지 명을 알 수 없는 경우)
            when t.observation_start_dt is null                    then 'D'  --시작일시가 null인 경우
            when t.observation_start_dt::date < t.birth_dt::date   then 'E'  --생년월일이 시작일시보다 나중인 경우
            when t.observation_start_dt::date > coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd')) then 'F' --시작일시가 사망일자보다 나중인 경우
            when extract(year from t.observation_start_dt)::integer - extract(year from t.birth_dt)::integer > 150     then 'G' --시작일시가 생년월일 +150년보다 더 나중인 경우 
            when t.patient_id is null                              then 'H' --환자번호가 없는 경우
            else 'N' end as filtering
  from (select o1.uid 
             , p1.patient_id
             , o1.form_nm
             , o1.visit_no
             , o1.medical_dt
             , o1.visit_gb
             , o1.medical_dept
             , o1.medical_dr
             , o1.qualifier
             , o1.result_txt
             , o1.result_num 
             , o1.result_unit
             /*
             , o1.observation_item1
             , o1.observation_item2
             , o1.observation_item3
             */
             , lh.local_cd_hash as observation_source_value
             , p1.uid as person_id
             , p1.birth_dt
             , m1.target_concept_id_1
             , m1.target_concept_id_2
             , m1.target_concept_id_3
             , m1.target_concept_id_4
             , m1.target_concept_id_5
             , m1.source_concept_id
             , m1.source_domain_id
             , m1.target_domain_id 
             , m1.seq as target_concept_seq
             , c1.target_value as reference_gb
             , coalesce(o1.record_dt, o1.medical_dt) as observation_start_dt
          from itfcdmpv532_daily.itf_observation o1 
          left join itfcdmpv532_daily.mt_person p1 
            on o1.patient_id = p1.patient_id and p1.rn=1
          left join mapcdmpv532_daily.local_hash lh
            on o1.form_nm = lh.local_cd1
           and o1.observation_item1 = lh.local_cd2
           and o1.observation_item2 = lh.local_cd3
           and o1.observation_item3 = lh.local_cd4
           and lh.source_domain_id = 'Observation'
          left join mapcdmpv532_daily.map_main_hash m1
            on lh.local_cd_hash = m1.local_cd_hash
          left join mapcdmpv532_daily.constant c1 
            on o1.form_nm = c1.source_value 
           and c1.idx = 801
        ) t left join cdmpv532_daily.death d1 on t.person_id = d1.person_id 
;;
