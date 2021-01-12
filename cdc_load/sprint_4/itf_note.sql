/*****************************************************
파일명: itf_note.sql
작성자: 
최초 작성일: 2020-12-07
비고:

cnt : 

*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.itf_note;;

CREATE TABLE itfcdmpv532_daily.itf_note AS
SELECT
 NULL :: varchar(50) AS visit_no
, patno :: varchar(50) AS patient_id
, medical_dt :: timestamp
, record_dt ::  timestamp
, visit_gb ::   varchar(10)
, medical_dept ::   varchar(50)
, C.cdm_empno ::    varchar(20) AS medical_dr
, null ::    varchar(50) as recorder
, form_nm ::    varchar(50)
, item :: varchar(250) note_item
,result_data as result_desc
,'KR'::varchar(10) as language_gb
,'UTF-8'::varchar(10) as encoding_gb
,null::timestamp as lastupdate_dt
FROM (
    select * from itfcdmpv532_daily.itf_note_1
    union all
    select * from itfcdmpv532_daily.itf_note_2
    union all
    select * from itfcdmpv532_daily.itf_note_3
    union all
    select * from itfcdmpv532_daily.itf_note_4
) A
WHERE  coalesce (record_dt,medical_dt) :: DATE >= '1994-01-01'
  AND result_data is not null
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_note' , 'itf_note', count(*) as cnt
from itfcdmpv532_daily.itf_observatitf_noteion ;
