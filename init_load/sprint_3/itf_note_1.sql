/*****************************************************
파일명: itf_note_1.sql
작성자: Won Jong Bok
최초 작성일: 2020-12-04
비고:

cnt : 

create table itfcdmpv532_daily.emr_frm_type_1_item as
select item,count(*) fre from ods_daily.itf_emr_frm_1 where insert_type='TE' group by item
;

create table itfcdmpv532_daily.note_item_emr1(
match text
);


delete from itfcdmpv532_daily.note_item_emr1;

insert into itfcdmpv532_daily.note_item_emr1
    SELECT '%자' AS match UNION ALL
    SELECT '%의' AS match UNION ALL
    SELECT '%의 _' AS match UNION ALL
    SELECT '%의사' UNION ALL 
    SELECT '진료의1' UNION ALL 
    SELECT '진료의2' UNION ALL 
    SELECT '진료의3' UNION ALL 
    SELECT '진료의4' UNION ALL 
    SELECT '보호자 성명' UNION ALL 
    SELECT '%이름%' UNION ALL 
    SELECT '%간호사%' UNION ALL 
    SELECT '%면허번호%' UNION ALL 
    SELECT '%주빈등록번호%' UNION ALL 
    SELECT '%우편번호%' UNION ALL 
    SELECT '%주소%' UNION ALL
    SELECT '완화의료병동' UNION ALL
    SELECT '치료사' UNION ALL
    SELECT '사회복지사' UNION ALL
    SELECT '강사' UNION ALL
    SELECT '의학물리사' UNION ALL
    SELECT '평가자 사회복지사' UNION ALL
    SELECT '심폐기사'
;

select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%자' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%의 _' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%의사' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%성명%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%이름%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%간호사%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%번호%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%주소%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%병동%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_1_item where item like '%사' order by fre desc;

select * from ods_daily.itf_emr_frm_1 where item ='';

*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.itf_note_1;;

CREATE TABLE itfcdmpv532_daily.itf_note_1 AS
SELECT patno
    , medical_dt
    , record_dt
    , visit_gb
    , form_nm
    , item
    , result_data AS result_data
    , medical_dept
    , medical_dr
  FROM ods_daily.itf_emr_frm_1 emr1
 where insert_type = 'TE'
  and NOT EXISTS
    (
        SELECT
            *
        FROM itfcdmpv532_daily.note_item_emr1 AS ni
        WHERE emr1.item LIKE ni.match
    )
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_note_1' , 'itf_note_1', count(*) as cnt
from itfcdmpv532_daily.itf_note_1 ;
