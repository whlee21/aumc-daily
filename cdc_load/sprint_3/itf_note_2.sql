/*****************************************************
파일명: itf_note_2.sql
작성자: LHY
최초 작성일: 2020-12-07
비고:

cnt :
time : 

create table itfcdmpv532_daily.emr_frm_type_3_item as
select item,count(*) fre from ods.itf_emr_frm_3 where insert_type='TE' group by item
;;

create table itfcdmpv532_daily.note_item_emr3(
match text
)
;

delete from itfcdmpv532_daily.note_item_emr3
;

insert into itfcdmpv532_daily.note_item_emr3
    SELECT '%자' AS match UNION ALL
    SELECT '%의' AS match UNION ALL
    SELECT '%의사' UNION ALL 
    SELECT '성명' UNION ALL 
    SELECT '%이름%' UNION ALL 
    SELECT '%간호사%' UNION ALL 
    SELECT '치료사'
;

select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%자' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%의' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%의사' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%성명%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%이름%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%간호사%' order by fre desc;
select * from itfcdmpv532_daily.emr_frm_type_3_item where item like '%사' order by fre desc;


select * from ods.itf_emr_frm_3 where item ='';

*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.itf_note_2;;

CREATE TABLE itfcdmpv532_daily.itf_note_2 AS
SELECT patno
    , medical_dt
    , record_dt
    , visit_gb
    , form_nm
    , item
    , result_data AS result_data
    , medical_dept
    , medical_dr
  FROM ods_daily.itf_emr_frm_3 emr3
 where insert_type = 'TE'
  and NOT EXISTS
    (
        SELECT
            *
        FROM itfcdmpv532_daily.note_item_emr3 AS ni
        WHERE emr3.item LIKE ni.match
    )
;;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_note_2' , 'itf_note_2', count(*) as cnt
from itfcdmpv532_daily.itf_note_2 ;
