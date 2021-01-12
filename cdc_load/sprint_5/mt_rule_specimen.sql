drop table if exists itfcdmpv532_daily.mt_rule_specimen;

create table itfcdmpv532_daily.mt_rule_specimen as  
select t.uid
     , t.patient_id
     , t.specimen_dt
     , t.specimen_cd
     , t.reference_gb
     , t.medical_dt
     , t.specimen_no
     , t.examination_rslt
     , t.quantity
     , t.site
     , t.unit
     , t.target_concept_id_1
     , t.source_concept_id
     , t.source_domain_id 
     , t.target_domain_id
     , case when t.cancel_dt is not null and cancel_yn = 'Y'                                                      then 'A'  --취소한 경우
            when t.specimen_dt::date < t.birth_dt::date                                                           then 'B'  --검체 채취 일시가 생년월일보다 먼저인 경우
            when t.specimen_dt::date > coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd'))     then 'C'  --검체 채취 일시가 사망보다 나중인 경우
            when t.patient_id is null                                                                             then 'D'  --환자번호가 없는 경우
            when extract(year from t.specimen_dt)::integer - extract(year from t.birth_dt)::integer > 150         then 'E'  --검체일자가 생년월일로 부터 150년 이후인 경우
            when t.examination_yn = 'N'                                                                           then 'F'  --검체검사결과상태가 완결이 아닌 경우
            when t.specimen_cd is null                                                                            then 'G'  --검체코드가 null인 경우
            when t.specimen_dt is null                                                                            then 'H'  --검체 채취 일시가 없는  경우
            else 'N' end as filtering
    from  (select s1.uid 
                , p1.patient_id
                , s1.cancel_dt
                , s1.cancel_yn
                , s1.examination_yn
                , s1.medical_dt
                , s1.specimen_no
                , lh.local_cd_hash as specimen_cd
                , coalesce(s1.collect_dt, s1.barcode_dt, s1.recept_dt, s1.medical_dt) as specimen_dt
                , p1.uid as person_id
                , p1.birth_dt
                --, case when s1.quantity is null then 1 when s1.quantity < 1 then 1 end as quantity  --themis rule에 따라 1보다 작거나 null이어도 검체검사를 했다면 1로 대체함
                , case when s1.quantity is null then 1 when s1.quantity < 1 then 1  else s1.quantity  end as quantity  -- 20201116 이승형 수정
                , c1.target_value          as reference_gb
                , c2.target_value          as examination_rslt
                , c3.target_value          as site
                , c4.target_value          as unit
                , m1.target_concept_id_1
                , m1.source_concept_id
                , m1.source_domain_id 
                , m1.target_domain_id
                , m1.seq as target_concept_seq
             from itfcdmpv532_daily.itf_specimen s1
             left join itfcdmpv532_daily.mt_person p1
               on s1.patient_id = p1.patient_id and p1.rn=1
             left join mapcdmpv532_daily.constant c1 
               on s1.reference_gb = c1.source_value
              and c1.idx = 901
             left join mapcdmpv532_daily.constant c2 
               on s1.examination_rslt = c2.source_value
              and c2.idx = 902
             left join mapcdmpv532_daily.constant c3
               on s1.site = c1.source_value
              and c3.idx = 903
             left join mapcdmpv532_daily.constant c4 
               on s1.unit = c1.source_value
              and c4.idx = 904
             left join mapcdmpv532_daily.local_hash lh
               on nullif(trim(s1.specimen_cd),'') = lh.local_cd1 and lh.source_domain_id = 'Specimen'
             left join mapcdmpv532_daily.map_main_hash m1
               on lh.local_cd_hash = m1.local_cd_hash
         ) t left join cdmpv532_daily.death d1 on t.person_id = d1.person_id
;
