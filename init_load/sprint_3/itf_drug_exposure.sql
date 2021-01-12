/*****************************************************
프로그램명  : ITF_DRUG_EXPOSURE.sql
작성자      : Won Jong Bok
수정자      :
최초 작성일 : 2020-12-04
수정일      :
소스 테이블(기본) :MMMEDORT(약처방),  MNBLOODT(수혈기록), MMTRTORT(처치/재료/수술료/마취료처방)
                   MMEXMORT(검사), MMREHORT(치료처방)  -> 이 테이블은 ods.mmorderv  view형태의 테이블에 모여 있음 아래 sql 참고
소스 테이블(참조) : MNWADACT(병동실시내역), MNOUTACT(외래실시내역)
프로그램 설명 : 처방관련 (처치, 약, 재료) 데이터 적재
cnt:
*****************************************************/



DROP TABLE if exists itfcdmpv532_daily.ITF_DRUG_EXPOSURE;;


CREATE  TABLE itfcdmpv532_daily.ITF_DRUG_EXPOSURE as
select row_number() OVER (ORDER BY null)::    bigint AS uid
        , NULL   ::  varchar(50) AS visit_no
        , tt1.*
from ( 
    select
         patient_id
        , order_no
        , order_cd
        , start_dt
        , order_dt
        , operation_dt
        , act_dt
        , anesthesia_dt
        , medical_dt
        , case when ward_cd IN
              ('091S', '3CCU', '5ICU', 'EICU', 'ICUA'
              , 'ICUB', 'NCUA', 'NCUB', 'NICUA', 'NICUB'
              , 'TICUA', 'TICUB', 'TICUC')
          then 'C' else visit_gb end ::  varchar(1) visit_gb
        , medical_dept
        , operation_seq
        , tot_order_yn
        , tot_order_qty
        , coalesce(order_qty1, 1) order_qty1
        , order_qty2
        , coalesce(order_cnt, 1) order_cnt
        , coalesce(order_day, 1) order_day
        , order_dr
        , procedure_provider
        , charge_dr
        , operation_dr
        , anesthesia_dr
        , act_dr
        , act_provider
        , t2.edicdfg::varchar(20) as bill_order_gb
        , order_class_gb
        , dc_yn1
        , dc_yn2
        , dc_order_seq
        , prn_order_yn
        , prn_act_yn
        , order_gb
        , act_yn        
        , pre_order_yn
        , pre_order_act_yn
        , method_cd
        , verbatim_end_date
        , stop_reason
        , remark
        , drug_unit AS unit
        , refill_cnt
        , lot_number
        , self_drug_yn
        , discharge_drug_yn
        , cancel_yn
        , cancel_dt
        , reference_gb
        , lastupdate_dt         
        , now() as etl_dt
        , ward_cd
    from (
        SELECT
             A.patno   ::  varchar(50) AS patient_id
            ,order_seq  ::  varchar(50) order_no
            ,coalesce (H.sugacode, order_cd) ::  varchar(50) as order_cd
            ,start_dt    ::  timestamp as start_dt
            ,order_dt    ::  timestamp as order_dt
            ,operation_dt    ::  timestamp as operation_dt
            ,act_dt  ::  timestamp as act_dt
            ,anesthesia_dt   ::  timestamp as anesthesia_dt
            ,medical_dt  ::  timestamp as medical_dt
            ,visit_gb   ::  varchar(1)
            ,medical_dept   ::  varchar(50)
            ,operation_seq  ::  varchar(50)
            ,tot_order_yn   ::  varchar(1)
            ,tot_order_qty  ::  float
            ,order_qty1 ::  float
            ,order_qty2 ::  float
            ,order_cnt  ::  int
            ,order_day  ::  int
            ,A.order_dr
            ,procedure_provider ::  varchar(50) procedure_provider
            , A.charge_dr      ::  varchar(50) AS charge_dr
            , A.operation_dr   ::  varchar(50) AS operation_dr
            , A.anesthesia_dr  ::  varchar(50) AS anesthesia_dr
            , act_dr ::  varchar(50)
            , A.act_provider ::  varchar(50) AS act_provider
           -- , edicdfg::varchar(20) as bill_order_gb
            ,order_class_gb ::  varchar(50)
            ,dc_yn1 ::  varchar(1)
            ,dc_yn2 ::  varchar(1)
            ,dc_order_seq   ::  varchar(50)
            ,order_gb   ::  varchar(50)
            ,act_yn ::  varchar(1)
            ,prn_order_yn   ::  varchar(1)
            ,prn_act_yn ::  varchar(1)
            ,pre_order_yn   ::  varchar(1)
            ,pre_order_act_yn   ::  varchar(1)
            ,method_cd  ::  varchar(50)
            ,verbatim_end_date   ::  date as verbatim_end_date
            ,stop_cause ::  varchar(20) AS stop_reason
            ,remark ::  text
            ,drug_unit  ::  varchar(50)
            ,refill_cnt ::  int
            ,lot_number ::  varchar(50)
            ,self_drug_yn   ::  varchar(1)
            ,discharge_drug_yn  ::  varchar(1)
            ,cancel_yn  ::  varchar(1)
            ,cancel_dt   ::  timestamp as cancel_dt
            ,reference_gb ::  varchar(10) reference_gb
            ,lastupdate_dt :: timestamp lastupdate_dt           
            ,ward_cd
        FROM (
                 SELECT *
                 FROM itfcdmpv532_daily.itf_order_1 A
                 UNION ALL
                 SELECT *
                 FROM itfcdmpv532_daily.itf_order_2 A
                 UNION ALL
                 SELECT *
                 FROM itfcdmpv532_daily.itf_order_3 A
                 UNION ALL
                 SELECT *
                 FROM itfcdmpv532_daily.itf_order_4 A
                 UNION ALL
                 SELECT *
                 FROM itfcdmpv532_daily.itf_order_5 A
             ) A
           LEFT JOIN ods_daily.ACPRICGT H
           on A.order_cd = H.grpsuga
           and a.order_dt::timestamp between h.fromdate and h.todate
           where coalesce(a.start_dt, a.act_dt, a.order_dt)    ::  timestamp >=  '1994-01-01'

    ) t1
    left join itfcdmpv532_daily.pre_itf_acpricst t2
    on t1.order_cd = t2.sugacode
) tt1 
where 1=1
and bill_order_gb = '3'
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_drug_exposure' , 'itf_drug_exposure', count(*) as cnt
from itfcdmpv532_daily.itf_drug_exposure ;