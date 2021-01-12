drop table if exists itfcdmpv532_daily.mt_rule_provider;;

create table itfcdmpv532_daily.mt_rule_provider as 
select p1.uid
     , p1.provider_id
     , c1.target_value as job_category_cd
     , c2.target_value as gender
  from itfcdmpv532_daily.itf_provider p1
 left join mapcdmpv532_daily.constant c1  
   on p1.job_category_cd = c1.source_value 
  and c1.idx = 201
 left join mapcdmpv532_daily.constant c2 
   on p1.gender = c2.source_value 
  and c2.idx = 202  
  ;;
  
