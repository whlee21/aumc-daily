/*****************************************************
파일명: itf_note_4.sql
작성자: Won Jong Bok
최초 작성일: 2020-12-04
비고:

cnt : 

*****************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.itf_note_4;;




CREATE TABLE itfcdmpv532_daily.itf_note_4 as
SELECT
      A.PATNO
    , a.rptdt MEDICAL_DT
    , NULL RECORD_DT
    , 'O' AS VISIT_GB
    , '당뇨병환자 소모성 재료 처방전' AS FORM_NM
    , '' AS item
    , '혈당측정검사지 | '||BSUGAR||'
채혈침 | '||BLANCET||'
인슐린주사기 | '||INSULINJT||'
인슐린주사바늘 | '||INSULNDLE||'
인슐린펌프용 주사기 | '||INSULINPJ||'
인슐린펌프용 주사바늘 | '||INSULINPN||'
DEXCOM G5 SENSOR | '||CASE WHEN productnm IN ('DEXCOM G5', 'Descom G5', 'Dexcom G5', 'Dxcom G5', 'G5', 'dexcom G5', 'dexcom g5', '덱스콤G5' ) THEN 'Y' ELSE 'N' END||'
ENLITE_SENSOR | '|| CASE WHEN productnm IN ('엔라이트센터', '엔라이트센서', 'Enlight  Sensor', '엔라이트 센서', '엔라이트센서' ) THEN 'Y' ELSE 'N' END ||'
Guardian_3_Sensor | '|| CASE WHEN productnm IN ('Guardian 3 Sensor', '가디언 3 센터', '가디언3센서', '가디언3센터' ) THEN 'Y' ELSE 'N' END ||'
guardian_connect | '|| CASE WHEN productnm IN ('guardian connect', '가디언건넥트', '가디언컨넥트', '가디언케넥트', '가이언커넥트' ) THEN 'Y' ELSE 'N' end ||'
총처방기간 | ' || a.ordterm ||'
발급일자 | ' || a.rptdt::date::varchar||'
종료일자 | ' || (a.rptdt :: date +  a.ordterm ::int)::varchar
        AS result_data
    , a.MEDDEPT AS MEDICAL_DEPT
    , a.MEDDR AS MEDICAL_DR
from ods_daily.mmdmmatt a
;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_note_4' , 'itf_note_4', count(*) as cnt
from itfcdmpv532_daily.itf_note_4 ;