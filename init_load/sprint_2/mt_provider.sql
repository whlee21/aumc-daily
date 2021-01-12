drop table if exists itfcdmpv532_daily.mt_provider;;

create table itfcdmpv532_daily.mt_provider as 
select p1.uid
             , p1.provider_id 
             , p1.year_of_birth
             , p1.verify_yn
             , p1.dept_cd 
             , p2.job_category_cd
             , p2.gender
             , row_number() over(partition by p1.provider_id order by case when p1.verify_yn = 'Y' then p1.provider_id end) as rn
          from itfcdmpv532_daily.itf_provider p1
         inner join itfcdmpv532_daily.mt_rule_provider p2 
            on p1.uid = p2.uid
;; 
