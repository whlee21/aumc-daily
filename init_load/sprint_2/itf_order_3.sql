/*****************************************************
프로그램명  : ITF_ORDER_3.sql
작성자      : Won Jong Bok
수정자      :
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) :MMMEDORT(약처방),  MNBLOODT(수혈기록), MMTRTORT(처치/재료/수술료/마취료처방)
                   MMEXMORT(검사), MMREHORT(치료처방)  -> 이 테이블은 ods_daily.mmorderv  view형태의 테이블에 모여 있음 아래 sql 참고
소스 테이블(참조) : MNWADACT(병동실시내역), MNOUTACT(외래실시내역)
프로그램 설명 : 처방관련 (처치, 약, 재료) 데이터 적재
cnt:

Comments(JCho): MMEXMORT table에 anesthesia 관련 정보 없음 -> order 내린 날짜 혹은 닥터로 치환 /day -> 약이 아니기 때문에 처방 일수가 없을 것으로 고려하여 null 
*****************************************************/
DROP TABLE if exists itfcdmpv532_daily.itf_order_3;;

CREATE TABLE itfcdmpv532_daily.itf_order_3 AS
SELECT A.patno
            , A.patfg                AS visit_gb
            , A.ordcode              AS order_cd
            , A.ordseqno::VARCHAR  AS order_seq
            , NULL                   AS order_sub_cd
            , NULL                   AS start_dt
            , A.orddate              AS order_dt
            , A.meddate              AS medical_dt
            , A.opdate               AS operation_dt
            , A.exectime             AS act_dt
            --, A.anethstm             AS anesthesia_dt
            , NULL             AS anesthesia_dt
            , A.meddept              AS medical_dept
            , 'N'                   AS self_drug_yn
            , A.opseqno::VARCHAR      AS operation_seq
            , 'N'                    AS tot_order_yn
            , NULL                   AS tot_order_qty
            --, LEFT(CASE
            --      WHEN COALESCE(A.DAY,0) = '0' THEN '1'
            --     ELSE A.DAY
            -- END::VARCHAR, 6)::FLOAT                    AS order_day
            , NULL                   AS order_day -- 검사는 당일 이뤄지기 때문에 처방일수가 필요 없을것으로 생각 								
            , 1                      AS order_qty1
            , NULL                   AS order_qty2
            , LEFT(A.CNT::VARCHAR,6)::FLOAT AS order_cnt
            , A.orddr                AS order_dr
            , NULL                   AS procedure_provider
            , NULL                   AS device_provider
            , A.chadr                AS charge_dr
            , A.orddr                 AS operation_dr
            --, A.anethdr              AS anesthesia_dr
            , A.orddr              AS anesthesia_dr -- 검사이기 때문에 anesthesia 관련 없을 것으로 생각되나, order doctor로 입력  
            , NULL                   AS act_dr
            , NULL                   AS act_provider
            , NULL                   AS medical_dr
            , A.ordclstyp            AS order_class_gb
            , A.dcyn                 AS dc_yn1
            , NULL                   AS dc_yn2
            , dcordseq::VARCHAR    AS dc_order_seq
            , A.mkfg                 AS order_gb
            , 'Y' act_yn --CASE WHEN (B.ordclsfg IN ('F1','D1','C2','C3') OR C.ordclstyp ='D1') AND COALESCE(nullif(B.ACTFG, ''), nullif(C.ACTYN, ''), 'Y') = 'Y' THEN 'Y' ELSE 'N' END AS act_yn
            , A.PRNACTYN             AS prn_order_yn
            , 'N'                    AS prn_act_yn
            , 'N'                    AS pre_order_yn
            , 'N'                    AS pre_order_act_yn
            , C.methodcd             AS method_cd
            , NULL                   AS verbatim_end_date
            , NULL                   AS stop_dt
            , NULL                   AS stop_cause
            , A.remark
            , NULL                   AS drug_unit
            , NULL                   AS refill_cnt
            , NULL                   AS lot_number
            , 'N'                    AS discharge_drug_yn
            , NULL                   AS modality_cd
            , NULL                   AS unique_no
            , NULL                   AS cancel_dt
            , NULL                   AS cancel_yn
            , '검사'::varchar(50) reference_gb
            , a.edittime::timestamp  lastupdate_dt
            , a.wardno               AS ward_cd
FROM ods_daily.MMEXMORT  A
 LEFT JOIN ods_daily.MNWADACT B ON A.PATNO = B.PATNO AND A.meddate = B.admtime AND A.ORDDATE = B.ORDDATE AND A.ORDSEQNO = B.ORDSEQNO AND
                               A.ORDCODE = B.ORDCODE AND A.PATFG IN ('E', 'I', 'D') AND B.rejttime IS NULL
 LEFT JOIN ods_daily.mnoutact C ON A.PATNO = C.PATNO AND A.meddept = C.meddept AND A.ORDDATE = C.ORDDATE AND A.ORDSEQNO = C.ORDSEQNO AND
                               A.ORDCODE = C.ORDCODE AND A.PATFG IN ('G','H','M','O') AND C.rejttime is null
 WHERE A.ORDCLSTYP IN ('C1', 'C2', 'C3')
;


/*
 SQL Error [23505]: ERROR: duplicate key value violates unique constraint "pg_type_typname_nsp_index"
 Detail: Key (typname, typnamespace)=(itf_order_3, 16396) already exists.
 */

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_order_3' , 'itf_order_3', count(*) as cnt
from itfcdmpv532_daily.itf_order_3 ;

