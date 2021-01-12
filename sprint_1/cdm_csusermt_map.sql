/*****************************************************
프로그램명  : cdm_csusermt_map.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-02
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 :  사원 번호 매핑 초기 / 추가 적재  - 초기는 최초 1회 그이후는 변경분만 돌려 주세요
cnt: 
time: 
*****************************************************/


--사원번호 매핑 로직 -- 초기
--insert into ods_etc.cdm_csusermt_map(userid, empno ,cdm_empno)
--select  
--     a.userid
--    , a.empno
--    , 10000000 + dense_rank() over (order by empno) :: bigint AS cdm_empno
--FROM ods_netc1.csusermt a
--;


--사원번호 매핑 로직 -- 변경  -- 사원번호 ,userid둘다 없을때 완젼 신규
insert into ods_etc.cdm_csusermt_map(userid, empno ,cdm_empno)
select  
     a.userid
    , a.empno
    , rn + dense_rank() over (order by empno) :: bigint AS cdm_empno
FROM ods_netc1.csusermt a , (select coalesce ( max(cdm_empno) , 0) rn from ods_etc.cdm_csusermt_map) b
where 1=1
and not exists (select 1 from  ods_etc.cdm_csusermt_map c where a.userid = c.userid and a.empno = c.empno )


--사원번호 매핑 로직 -- 변경  -- 사원번호 ,userid가 새로 만들어진 경우 기존cdm_empno 사용
insert into ods_etc.cdm_csusermt_map(userid, empno ,cdm_empno)
select
    a.userid
    , a.empno
    , (select b.cdm_empno from  ods_etc.cdm_csusermt_map b where a.empno = b.empno limit 1 )
from ods_netc1.csusermt a
where 1=1
and not exists (select 1 from  ods_etc.cdm_csusermt_map c where a.userid = c.userid  )