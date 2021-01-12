drop table if exists itfcdmpv532_daily.mt_rule_visit;

create table itfcdmpv532_daily.mt_rule_visit as  
select t3.*
     , case when t3.visit_gb_new_div = '9202' and t3.op_cnt > 1 then (select target_value from mapcdmpv532_daily.constant where idx = 9999) end as op_care_site  --외래방문 케이스에 동일 환자가 하루에 1건 이상인 경우 visit_occurrence에 가는 대표 외래방문의 care_site는 whole hospital이 됨 
     , LAG(t3.visit_detail_id, 1, null) over(partition by t3.patient_id order by case when  t3.filtering = 'N' then t3.lag_order end) as preceding_visit_detail_id  --환자별로 시작일자순 방문시퀀스순의 직전 visit_detail_id
     , LAG(t3.visit_occurrence_id, 1, null) over(partition by t3.patient_id order by case when t3.filtering = 'N' then t3.lag_order end) as preceding_visit_occurrence_id --환자별로 시작일자순 방문시퀀스순의 직전 visit_occurrence_id
  from( select t2.visit_detail_id
             , t2.visit_occurrence_id
             , t2.visit_start_dt
             , t2.visit_end_dt
             , t2.provider
             , t2.visit_path 
             , t2.visit_gb
             , t2.visit_gb_new
             , t2.visit_gb_div
             , t2.visit_gb_new_div 
             , t2.discharge_yn  
             , t2.reference_gb   
             , t2.discharge_path
             , t2.patient_id
             , t2.division_gb
             , t2.visit_no
             , t2.medical_dt
             , t2.medical_dept
             , t2.medical_dr 
             , v2.op_cnt
             , row_number() over(partition by t2.patient_id order by t2.visit_start_dt) as lag_order
             , case when (t2.medical_yn = 'N' or t2.cancel_yn = 'Y' or t2.cancel_dt is not null) then 'A' --취소한 경우
                    when t2.visit_start_dt :: date < t2.birth_dt :: date                                         then 'B' --내원시간이 생년월일보다 먼저인 경우
                    when t2.visit_start_dt :: date > t2.visit_end_dt :: date                                     then 'C' --내원시간이 퇴원시간보다 나중인 경우
                    when t2.patient_id is null                                                   then 'D' --환자번호가 없는 경우
                    when t2.visit_start_dt is null                                               then 'E' --내원시간이 null인 경우
                    when t2.visit_end_dt is null                                                 then 'F' --퇴원시간이 null인 경우
                    when extract(year from t2.visit_start_dt)::integer - extract(year from t2.birth_dt)::integer > 150 then 'G' --150세 이상 살아있는 경우
                    when t2.visit_gb is null                                                     then 'H' --내원구분이 null인경우
                    else 'N' end as filtering
          from(select t1.visit_detail_id, t1.visit_occurrence_id, t1.visit_start_dt, t1.provider, t1.visit_path 
                    , t1.visit_gb, t1.visit_gb_new, t1.discharge_yn, t1.reference_gb, t1.discharge_path, t1.division_gb
                    , t1.medical_yn, t1.cancel_yn, t1.cancel_dt, t1.patient_id, t1.birth_dt
                    , t1.visit_no, t1.medical_dt, t1.medical_dept, t1.medical_dr, t1.visit_gb_div, t1.visit_gb_new_div
                    , case when coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd')) < t1.visit_end_dt::date            then d1.death_datetime --사망일자가 종료일자보다 먼저일 경우 종료일자를 사망일자로 대체함 
                           when (t1.visit_end_dt is null or t1.visit_end_dt::date = '9999-12-31'::date) and d1.death_datetime is not null then d1.death_datetime --종료일자가 불분명한 경우에 사망일자가 명확한 케이스에 한 하여 사망일자로 대체함
                           when t1.visit_end_dt is not null and t1.visit_end_dt > now()                                             then now()
                           else t1.visit_end_dt end as visit_end_dt
                 from (select v1.visit_detail_id
                            , v1.visit_occurrence_id
                            --, v1.patient_id -- 아래로 수정 by 이승형 20201127
                            , p1.patient_id
                            , v1.medical_yn 
                            , v1.cancel_yn
                            , v1.cancel_dt
                            , v1.division_gb
                            , v1.visit_no
                            , v1.visit_gb
                            , v1.visit_gb_new
                            , v1.medical_dt
                            , v1.medical_dept
                            , v1.medical_dr
                            , p1.uid as person_id
                            , p1.birth_dt
                            , coalesce(v1.visit_dt2, v1.medical_dt) as visit_start_dt
                            , case when c4.target_value = 'N' --입원중(discharge_yn = 'N')
                                    and (coalesce(v1.discharge_dt, v1.medical_dt)::date = '9999-12-31'::date or coalesce(v1.discharge_dt, v1.medical_dt)::date is null) then now()::date 
                                   else coalesce(v1.discharge_dt, v1.medical_dt) end as visit_end_dt  
                            , coalesce(v1.admission_charge_dr, v1.medical_dr) as provider
                            , c1.target_value as visit_gb_div 
                            , c2.target_value as visit_path
                            , c3.target_value as visit_gb_new_div
                            , c4.target_value as discharge_yn
                            , c5.target_value as reference_gb
                            , c6.target_value as discharge_path
                         from itfcdmpv532_daily.itf_visit v1
                         left join itfcdmpv532_daily.mt_person p1 
                           on v1.patient_id = p1.patient_id and p1.rn=1
                         left join mapcdmpv532_daily.constant c1 
                           on v1.visit_gb = c1.source_value
                          and c1.idx = 504
                         left join mapcdmpv532_daily.constant c2 
                           on v1.visit_path = c2.source_value
                          and c2.idx = 501
                         left join mapcdmpv532_daily.constant c3 
                           on v1.visit_gb_new = c3.source_value
                          and c3.idx = 506
                         left join mapcdmpv532_daily.constant c4
                           on v1.discharge_yn = c4.source_value
                          and c4.idx = 505
                         left join mapcdmpv532_daily.constant c5 
                           on v1.reference_gb = c5.source_value 
                          and c5.idx = 503
                         left join mapcdmpv532_daily.constant c6 
                           on v1.discharge_path = c6.source_value 
                          and c6.idx = 502 
      ) t1 left join cdmpv532_daily.death d1 on t1.person_id = d1.person_id
      ) t2 left join (select visit_occurrence_id, count(1) as op_cnt from itfcdmpv532_daily.itf_visit group by visit_occurrence_id) v2 on t2.visit_occurrence_id = v2.visit_occurrence_id
      ) t3
;
