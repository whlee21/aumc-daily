/*****************************************************
프로그램명  : ITF_ORDER_1.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      :
소스 테이블(기본) :MMMEDORT(약처방),  MNBLOODT(수혈기록), MMTRTORT(처치/재료/수술료/마취료처방)
                   MMEXMORT(검사), MMREHORT(치료처방)  -> 이 테이블은 ods_daily.mmorderv  view형태의 테이블에 모여 있음 아래 sql 참고
소스 테이블(참조) : MNWADACT(병동실시내역), MNOUTACT(외래실시내역)
프로그램 설명 : 처방관련 (처치, 약, 재료) 데이터 적재
cnt:  
*****************************************************/
DROP TABLE if exists itfcdmpv532_daily.itf_order_1;;


CREATE  TABLE itfcdmpv532_daily.itf_order_1 AS
         SELECT A.patno
                    , A.patfg                                                            AS visit_gb
                    , A.ordcode                                                          AS order_cd
                    , A.ordseqno::varchar                                      AS order_seq
                    , NULL                                                               AS order_sub_cd
                    , NULL                                                               AS start_dt
                    , A.orddate                                                          AS order_dt
                    , A.meddate                                                          AS medical_dt
                    , NULL                                                               AS operation_dt
                    , B.ACTINGRETM                                                       AS act_dt
                    , NULL                                                               AS anesthesia_dt
                    , A.meddept                                                          AS medical_dept
                    , case when A.oneselfyn='' then 'N'
                            else coalesce(A.oneselfyn,'N') end                           AS self_drug_yn
                    , NULL                                                               AS operation_seq
                    , 'N'                                                                AS tot_order_yn
                    , NULL                                                               AS tot_order_qty
                    , LEFT(CASE
                          WHEN A.PATFG IN ('I', 'E') AND A.DSCDRGYN = 'N' THEN '1'
                          WHEN A.DAY = '0' THEN '1'
                          ELSE A.DAY
                        end::varchar, 6) ::FLOAT                                                                     AS order_day
                    , LEFT(A.PACKQTY::varchar,6)::FLOAT                                         AS order_qty1
                    , NULL                                                               AS order_qty2
                    , LEFT(COALESCE(B.CNT,A.CNT)::varchar, 6)::FLOAT                AS order_cnt
                    , A.orddr                                                            AS order_dr
                    , NULL                                                               AS procedure_provider
                    , NULL                                                               AS device_provider
                    , A.chadr                                                            AS charge_dr
                    , NULL                                                               AS operation_dr
                    , NULL                                                               AS anesthesia_dr
                    , NULL                                                               AS act_dr
                    , NULL                                                               AS act_provider
                    , NULL                                                               AS medical_dr
                    , A.ordclstyp                                                        AS order_class_gb
                    , A.dcyn                                                             AS dc_yn1
                    , NULL                                                               AS dc_yn2
                    , dcordseq::varchar                                               AS dc_order_seq
                    , A.mkfg                                                             AS order_gb
                    , CASE WHEN COALESCE(B.ACTFG, C.ACTYN, 'Y') = 'Y' THEN 'Y' ELSE 'N' END                                    AS act_yn
                    , A.PRNACTYN                                                         AS prn_order_yn
                    , CASE WHEN A.PRNACTYN = 'Y' AND B.ACTFG = 'Y' THEN 'Y' ELSE 'N' END AS prn_act_yn
                    , A.preordyn                                                         AS pre_order_yn
                    , 'N'                                                                AS pre_order_act_yn
                    , A.methodcd                                                         AS method_cd
                    , NULL                                                               AS verbatim_end_date
                    , NULL                                                               AS stop_dt
                    , NULL                                                               AS stop_cause
                    , A.remark
                    , A.packunit                                                         AS drug_unit
                    , NULL                                                               AS refill_cnt
                    , NULL                                                               AS lot_number
                    , A.dscdrgyn                                                         AS discharge_drug_yn
                    , NULL                                                               AS modality_cd
                    , NULL                                                               AS unique_no
                    , NULL                                                               AS cancel_dt
                    , NULL                                                               AS cancel_yn
                    , '약제'::varchar(50) reference_gb
                    , a.edittime::timestamp  lastupdate_dt
                    , a.wardno                                                           AS ward_cd
         FROM ods_daily.MMMEDORT A
         inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
         LEFT JOIN ods_daily.MNWADACT B ON A.PATNO = B.PATNO AND A.meddate = B.admtime AND A.ORDDATE = B.ORDDATE AND A.ORDSEQNO = B.ORDSEQNO AND
                                       A.ORDCODE = B.ORDCODE AND A.PATFG IN ('E', 'I', 'D') AND A.ordclstyp = B.ordclsfg AND B.rejttime IS NULL
         LEFT JOIN ods_daily.mnoutact C ON A.PATNO = C.PATNO AND A.meddept = C.meddept AND A.ORDDATE = C.ORDDATE AND A.ORDSEQNO = C.ORDSEQNO AND
                                       A.ORDCODE = C.ORDCODE AND A.PATFG IN ('G','H','M','O') AND A.ORDCLSTYP = C.ordclstyp AND C.rejttime is null
         WHERE 1=1;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_order_1' , 'itf_order_1', count(*) as cnt
from itfcdmpv532_daily.itf_order_1 ;  
