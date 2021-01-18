drop table if exists itfcdmpv532_daily.mt_care_site;;

create table itfcdmpv532_daily.mt_care_site as
select c1.uid
	 , c1.meddept_cd
	 , c1.meddept_nm
	 , c1.dept_cd -- added
	 , c1.dept_nm -- added
	 , c1.zip_code_3 
	 , c2.target_value as place_of_service
	 , row_number() over(partition by c1.dept_cd) as rn
  from itfcdmpv532_daily.itf_care_site c1 
  left join mapcdmpv532_daily.constant c2 
    on c1.meddept_cd = c2.source_value
   and c2.idx = 101
;;
