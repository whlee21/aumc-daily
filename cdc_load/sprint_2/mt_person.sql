drop table if exists itfcdmpv532_daily.mt_person;   

create table itfcdmpv532_daily.mt_person as 
select p1.uid
     , p1.patient_id
     , p2.month_gb
     , p1.birth_dt
     , p1.zip_cd
     , p1.hospital_id
     , p2.gender
     , p2.year_of_birth
     , p2.month_of_birth
     , p2.day_of_birth
     , p2.foreigner_gb
     , p2.foreigner_yn
     , p2.race_gb
     , row_number() over(partition by p1.patient_id order by case when p2.filtering='N' then 1 else 2 end) as rn
  from itfcdmpv532_daily.itf_person p1 
 inner join itfcdmpv532_daily.mt_rule_person p2 
    on p1.uid = p2.uid 
 where p2.filtering = 'N'
;
