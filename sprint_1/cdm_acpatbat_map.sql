/*****************************************************
프로그램명  : cdm_acpatbat_map.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-02
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 : 환자번호 매핑 테이블 초기 / 추가 적재.. 추가 적재 부분만 돌려 주세요
cnt: 
time: 
*****************************************************/
 





-- 환자번호 매핑 로직 -- 초기  백만 부터 시작

--insert into ods_etc.cdm_acpatbat_map (patno, cdm_patno)
--select
--     AP.patno::varchar(50) as  patno
--     , 1000000 +  row_number() over(order by random() ) as cdm_patno
--FROM ods_neta1.acpatbat AP
--;;


-- 환자번호 매핑 로직 -- 변경
insert into ods_etc.cdm_acpatbat_map (patno, cdm_patno)
select
     AP.patno::varchar(50) as  patno
     , ab.rn + row_number() over(order by random() ) as cdm_patno
FROM ods_neta1.acpatbat AP , (select coalesce (max(cdm_patno),0)::int8 as rn  from ods_etc.cdm_acpatbat_map ) ab
where not exists (select 1 from ods_etc.cdm_acpatbat_map b where ap.patno = b.patno )
;;