/*****************************************************
프로그램명   : ITF_COST.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일  : 2020-12-04
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 : 

cnt : 
*****************************************************/

DROP TABLE if exists itfcdmpv532_daily.itf_cost;;

create table itfcdmpv532_daily.itf_cost as
    select     
          row_number() over(order by null) as uid
        ,  (AA.patno||AA.order_dt::varchar||AA.order_seq||AA.order_cd) ::varchar(50) as visit_no
        , AA.patno::varchar(50) as patient_id
        , AA.order_tb
        , AA.order_seq as order_no
        , coalesce (AA.order_sub_cd,AA.order_cd) as order_cd
        , AA.order_dt
        , AA.medical_dt
        , AA.visit_gb
        , AA.medical_dept
        , AA.insurance_gb
        , AA.total_pay_amt
        , trunc( AA.insurance_pay_amt)  total_payer_amt
        , AA.total_pay_amt - trunc( AA.insurance_pay_amt)  as total_patient_amt
        , AA.cost_gb
        , AA.drg_gb
        , AA.drg_cd
        , AA.currency as currency_gb
        , AA.cancel_yn
        , AA.reference_gb
        , AA.lastupdate_dt
      from
          (
            select * from itfcdmpv532_daily.itf_cost_O
            union all
            select * from itfcdmpv532_daily.itf_cost_I
          ) AA
    WHERE  medical_dt >= '1994-01-01'
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost' , 'itf_cost', count(*) as cnt
from itfcdmpv532_daily.itf_cost ;
