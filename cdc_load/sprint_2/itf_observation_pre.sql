/*****************************************************
프로그램명  : itf_observation_pre.sql
작성자      : Won Jong Bok
수정자      :
최초 작성일 : 2020-12-07
수정일      :
소스 테이블(기본) :
소스 테이블(참조) : 
프로그램 설명 : observation 전처리
cnt:
*****************************************************/


DELETE from ods_daily.MRF_ATTR WHERE attr_nm IN ('진료과', '작성의', '진료의사', '주소', '전화번호','주치의','가계도', '결혼년도', '직업', '이름', '성별', '기타 직업', '전공의');
--EMR 항목 중 빈도 수 높지만 불필요 항목 제거


DROP TABLE IF EXISTS ods_daily.itf_emr_frm_1 ;;
--1.일반 항목(텍스트, 날짜, 숫자등)
create TABLE ods_daily.itf_emr_frm_1 AS
SELECT DISTINCT
     A.PTNT_NO AS patno
    ,A.MED_TIME AS medical_dt
    ,A.FRM_DT AS record_dt
    ,A.ord_date AS order_dt
    ,A.CLN_TYPE AS visit_gb
    ,D.ins_type AS insert_type
    ,B.FRM_NM AS form_nm
    ,D.gb_nm AS gubun
    ,D.attr_nm AS item
    ,TRIM(COALESCE(C.nmrc_data::varchar, C.txt_data)) AS result_data
    ,A.MED_DEPT AS medical_dept
    ,A.MED_DR AS medical_dr
  FROM ods_daily.MRR_FRM_CLNINFO A
      ,ods_daily.MRF_FRM B
      ,ods_daily.MRR_ATTR_CLNINFO C
      ,ods_daily.MRF_ATTR D
      , (select patno from ods_daily.target_person group by patno )  tp 
 WHERE 1=1
   and a.PTNT_NO = tp.patno
   AND B.FRM_KEY = A.FRM_KEY
   AND C.FRMCLN_KEY = A.FRMCLN_KEY
   AND D.ATTR_key = C.ATTR_key;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_emr_frm_1' , 'itf_emr_frm_1', count(*) as cnt
from itfcdmpv532_daily.itf_emr_frm_1 ;

--2.항목별 종류 (콤보박스, 라디오버튼, 체크박스형태) 
DROP TABLE IF EXISTS ods_daily.itf_emr_frm_2 ;;
CREATE TABLE ods_daily.itf_emr_frm_2 AS
SELECT DISTINCT
     A.PTNT_NO AS patno
    ,A.MED_TIME AS medical_dt
    ,A.FRM_DT AS record_dt
    ,A.ord_date AS order_dt
    ,A.CLN_TYPE AS visit_gb
    ,E.ins_type AS insert_type
    ,B.FRM_NM AS form_nm
    ,E.gb_nm AS gubun
    ,E.attr_nm AS item
    ,TRIM(D.cont_nm||CASE WHEN D.add_txt_yn = 'Y' and TRIM(C.add_txt) <> '' THEN ' add_text: '||TRIM(C.add_txt) ELSE ''END) AS result_data
    ,A.MED_DEPT AS medical_dept
    ,A.MED_DR AS medical_dr
  FROM ods_daily.MRR_FRM_CLNINFO A
      ,ods_daily.MRF_FRM B
      ,ods_daily.MRR_CONT_CLNINFO C
      ,ods_daily.MRF_ATTR_CONT D
      ,ods_daily.MRF_ATTR E
      , (select patno from ods_daily.target_person group by patno )  tp 
 WHERE 1=1
   and a.PTNT_NO = tp.patno
    AND B.FRM_KEY = A.FRM_KEY
    AND C.FRMCLN_KEY = A.FRMCLN_KEY
    AND D.ATTR_KEY = C.ATTR_KEY
    AND D.RANK_NO = C.RANK_NO
    AND E.ATTR_CD = C.ATTR_CD
    AND E.ATTR_KEY = C.ATTR_KEY
    AND C.stus_cd = 'Y';--------------------------------------------------체크, 라디오 선택한것, 콤보 선택한것 만 

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_emr_frm_2' , 'itf_emr_frm_2', count(*) as cnt
from itfcdmpv532_daily.itf_emr_frm_2 ;        

--3.표 형태
DROP TABLE IF EXISTS ods_daily.itf_emr_frm_3 ;;
create TABLE ods_daily.itf_EMR_FRM_3 AS
SELECT DISTINCT
    A.PTNT_NO AS patno
    ,A.MED_TIME AS medical_dt
    ,A.FRM_DT AS record_dt
    ,A.med_date
    ,A.CLN_TYPE AS visit_gb
    ,E.ins_type AS insert_type
    ,B.FRM_NM AS form_nm
    ,d.grid_nm AS grid_nm---------------------------------------------추가
    ,E.gb_nm AS gubun
    ,E.ATTR_NM AS item
    ,TRIM(COALESCE(C.nmrc_data::varchar, TRIM(C.txt_data))) AS result_data
    ,A.MED_DEPT AS medical_dept
    ,A.MED_DR AS medical_dr
  FROM ods_daily.MRR_FRM_CLNINFO A
      ,ods_daily.MRF_FRM B
      ,ods_daily.MRR_GRID_CLNINFO C
      ,ods_daily.MRF_GRID D
      ,ods_daily.MRF_ATTR E
      , (select patno from ods_daily.target_person group by patno )  tp 
 WHERE 1=1
   and a.PTNT_NO = tp.patno
    AND B.FRM_KEY = A.FRM_KEY
    AND C.FRMCLN_KEY = A.FRMCLN_KEY
    AND D.GRID_KEY = C.GRID_KEY
    AND E.ATTR_KEY = C.ATTR_KEY
    AND C.data_cd = '' AND (C.nmrc_data::varchar <> '' OR C.txt_data <> '')
   ;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_emr_frm_3' , 'itf_emr_frm_3', count(*) as cnt
from itfcdmpv532_daily.itf_emr_frm_3 ;


--4.표형식 내의 항목 종류(콤보박스, 라디오버튼, 체크박스형태)
DROP TABLE IF EXISTS ods_daily.itf_emr_frm_4 ;;
CREATE TABLE ods_daily.itf_EMR_FRM_4 AS
SELECT DISTINCT
     A.PTNT_NO AS patno
    ,A.MED_TIME AS medical_dt
    ,A.FRM_DT AS record_dt
    ,A.ord_date AS order_dt
    ,A.CLN_TYPE AS visit_gb
    ,E.ins_type AS insert_type
    ,B.FRM_NM AS form_nm
    ,d.grid_nm AS grid_nm
    ,E.gb_nm AS gubun
    ,E.ATTR_NM AS item
    ,TRIM(F.CONT_NM ||' '||CASE WHEN F.add_txt_yn = 'Y' THEN TRIM(C.add_txt) ELSE ''END) AS result_data
    ,A.MED_DEPT AS medical_dept
    ,A.MED_DR AS medical_dr
  FROM ods_daily.MRR_FRM_CLNINFO A
      ,ods_daily.MRF_FRM B
      ,ods_daily.MRR_GRID_CONT_CLNINFO C
      ,ods_daily.MRF_GRID D
      ,ods_daily.MRF_ATTR E
      ,ods_daily.MRF_ATTR_CONT F
      , (select patno from ods_daily.target_person group by patno )  tp 
 WHERE 1=1
   and a.PTNT_NO = tp.patno
    AND B.FRM_KEY = A.FRM_KEY
    AND C.FRMCLN_KEY = A.FRMCLN_KEY
    AND D.GRID_KEY = C.GRID_KEY
    AND E.ATTR_KEY = C.ATTR_KEY
    AND F.ATTR_KEY = C.ATTR_KEY
    AND F.RANK_NO = C.RANK_NO
    ;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_emr_frm_4' , 'itf_emr_frm_4', count(*) as cnt
from itfcdmpv532_daily.itf_emr_frm_4 ;
