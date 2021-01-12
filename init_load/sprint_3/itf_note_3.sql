/*****************************************************
파일명: itf_note_3.sql
작성자: Won Jong Bok
최초 작성일: 2020-12-04
비고:

cnt : 

*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.itf_note_3;;

CREATE TABLE itfcdmpv532_daily.itf_note_3 AS
SELECT
   A.PATNO
  , A.MEDDATE AS medical_dt
  , A.REPTTIME AS record_dt
  , A.PATHFG AS visit_gb
  , 'Pathology report' AS form_nm
  , CASE
        WHEN B.RSLTFG = 'G' THEN 'Gross'
        WHEN B.RSLTFG = 'N' THEN 'Biopsy'
    END AS item
  , CASE WHEN coalesce (B.result,b.result1 ,b.result2 ) is null THEN null 
        ELSE CASE WHEN B.RESULT is not null THEN 'Result: '||B.RESULT ELSE '' END
            || CASE WHEN B.RESULT1 is not null THEN ' Result1: '||B.RESULT1 ELSE '' END
            || CASE WHEN B.RESULT2 is not null THEN ' Result2: '||B.RESULT2 ELSE '' end
    END AS result_data
  , A.MEDDEPT AS medical_dept
  , A.ORDDR AS medical_dr
  FROM
     ods_daily.SPACPTMT A, ods_daily.SPRSLTMT B
 WHERE 1 =1
   AND A.PATHFG = B.PATHFG
   AND A.PATHYEAR = B.PATHYEAR
   AND A.PATHNO = B.PATHNO
   AND A.PROCSTAT IN ('E','F','G','H')
   AND A.PATHFG = 'S'
   AND B.RSLTFG IN ('G','N')
;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_note_3' , 'itf_note_3', count(*) as cnt
from itfcdmpv532_daily.itf_note_3 ;