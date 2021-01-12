drop table if exists itfcdmpv532_daily.mt_rule_person;

create table itfcdmpv532_daily.mt_rule_person as --2,021,292
select t.uid
     , t.patient_id
     , t.gender
     , t.foreigner_gb
     , t.foreigner_yn
     , t.race_gb
	 , date_part('year', t.birth_dt)  as year_of_birth
	 , date_part('month', t.birth_dt) as month_of_birth
	 , date_part('day', t.birth_dt)   as day_of_birth
     , case when (extract(month from t.birth_dt)) in (1,2,3) then 1::int
            when (extract(month from t.birth_dt)) in (4,5,6) then 4::int
            when (extract(month from t.birth_dt)) in (7,8,9) then 7::int
            when (extract(month from t.birth_dt)) in (10,11,12) then 10::int end as month_gb
     , case when t.foreigner_gb not in ('1','2','3','4','5','6','7','8','9','0') then 'A'  --주민번호 뒷자리 중 첫번째 숫자가 유효하지 않은 경우
            when (extract(year from t.birth_dt))::integer < (extract(year from current_date))::integer - 151 then 'B' --출생년도가 현재시점으로부터 150년보다 더 이전인 경우
            when t.birth_dt::date > t.death_dt::date then 'C'  --death_dt가 null이면 E로 필터링 안 됨
            when t.birth_dt::date is null then 'D'  
            when date_part('year', t.birth_dt) not between 1900 and extract(year from ((current_date::date)::timestamp + interval '1 day'))	then 'E' --생년월일이 1900년에서 현재사이가 아닌 경우
            when date_part('year', t.birth_dt) > extract(year from current_date::date) then 'F'
            else 'N' end as filtering
  from (
        select p1.uid
             , p1.patient_id
             , p1.birth_dt
             , case when coalesce(d1.death_dt, d1.regit_dt)::date = '9999-12-31'::date then null else coalesce(d1.death_dt, d1.regit_dt) end as death_dt
             , c1.target_value as gender
             , c2.target_value as race_gb
             , c3.target_value as foreigner_gb
             , c4.target_value as foreigner_yn
          from itfcdmpv532_daily.itf_person p1     
          left join itfcdmpv532_daily.itf_death d1
            on p1.patient_id = d1.patient_id
           and coalesce(d1.death_dt, d1.regit_dt) is not null  -- 조건 준 이유는 mt_death를 사용하고 싶지만, itf_death를 사용해야 해서
           and d1.death_dt >= p1.birth_dt
           and d1.death_dt <= cast(to_char(current_date, 'yyyy-mm-dd') as date) 
           and d1.death_seq = 1 
          left join mapcdmpv532_daily.constant c1 
            on p1.gender = c1.source_value
           and c1.idx = 301
          left join mapcdmpv532_daily.constant c2 
            on p1.race_gb = c2.source_value
           and c2.idx = 302 
          left join mapcdmpv532_daily.constant c3
            on p1.foreigner_gb = c3.source_value 
           and c3.idx = 303  
          left join mapcdmpv532_daily.constant c4
            on p1.foreigner_yn = c4.source_value
           and c4.idx = 304
           ) t ; 
