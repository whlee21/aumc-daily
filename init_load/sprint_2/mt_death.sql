drop table if exists itfcdmpv532_daily.mt_death; 

create table itfcdmpv532_daily.mt_death as        
select d1.uid
     , d1.patient_id
     , d2.death_dt
     , d2.select_cause
     , d2.reference_gb
     , row_number() over(partition by p1.uid order by d1.death_dt desc) as rn 
  from itfcdmpv532_daily.itf_death d1
 inner join itfcdmpv532_daily.mt_rule_death d2 
    on d1.uid = d2.uid 
 inner join itfcdmpv532_daily.itf_person p1
    on d1.patient_id = p1.patient_id 
 where d2.filtering = 'N'
 ;
