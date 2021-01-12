drop table if exists itfcdmpv532_daily.mt_rule_payer_plan_period;;

create table itfcdmpv532_daily.mt_rule_payer_plan_period as
select p.uid 
     , p.patient_id
     , p.visit_no
     , p.ins_start_dt
     , p.ins_end_dt
     , p.ins_stop_gb 
     , p.insurance_gb
     , p.stop_reason_source_value
     , p.payer_source_value           
	 , case when p.ins_start_dt::date > p.ins_end_dt::date      then 'E'  --시작일자가 종료일자보다 나중인 경우
	        else p.filtering end as filtering
  from (select p1.uid 
        	 , p2.patient_id
        	 , p1.visit_no
        	 , p1.ins_start_dt
        	 , p1.insurance_gb
        	 , p1.ins_stop_gb
        	 , p2.uid as person_id
        	 , case when p1.ins_start_dt is null                          then 'A'  --시작일자가 null인 경우
        	        when p1.ins_end_dt   is null                          then 'B'  --종료일자가 null인 경우
        	        when (p1.patient_id is null or p2.patient_id is null) then 'C'  --환자번호가 null인 경우
        	        when p1.ins_start_dt::date < p2.birth_dt::date        then 'D'  --시작일자가 생년월일보다 먼저인 경우
        	        else 'N' end as filtering 
        	 , c1.target_value as stop_reason_source_value
        	 , c2.target_value as payer_source_value
             , case when coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd')) < p1.ins_end_dt::date         then d1.death_datetime --종료일자가 사망일자보다 나중이면 사망일자를 종료일자로 대체함
	                when(p1.ins_end_dt is null or p1.ins_end_dt::date = '9999-12-31'::date) and d1.death_datetime is not null then d1.death_datetime --종료일자가 불명확한 데이터 중에 사망일자가 있는 건에 한 해 사망일자를 넣어줌
	                else p1.ins_end_dt end as ins_end_dt        	 
          from itfcdmpv532_daily.itf_payer_plan_period p1
          left join itfcdmpv532_daily.mt_person p2 
            on p1.patient_id = p2.patient_id and p2.rn=1
          left join cdmpv532_daily.death d1 
		    on p2.uid = d1.person_id
          left join mapcdmpv532_daily.constant c1     --athena에 신청예정
            on p1.ins_stop_gb = c1.source_value 
           and c1.idx = 0000                    --없는 idx 수정예정
          left join mapcdmpv532_daily.constant c2 
            on p1.insurance_gb = c2.source_value 
           and c2.idx = 1201
) p;
