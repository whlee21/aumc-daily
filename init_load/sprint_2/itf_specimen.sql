/*****************************************************
프로그램명  : ITF_SPECIMEN.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      : 
소스 테이블(기본) : SPCOLLMT(검체채취내역), SPCOLLDT(검체채취처방내역)|진검 SLACPTMT(검체접수내역), SLRSLTMT(검체검사결과내역)
소스 테이블(참조) : MMCOMRQT(통합검사의뢰서), SLTRSTMT(통합검사결과내역)
프로그램 설명 : 병리검사에서 검체코드로 관리하지 않고 text형태로 저장.

cnt : 
time : 
Comments(JCho): isfloat 임의 생성. 추후 수정필요
*****************************************************/
DROP TABLE if exists itfcdmpv532_daily.itf_specimen;;

----- Declare of isfloat function
CREATE OR REPLACE FUNCTION isfloat(text) RETURNS BOOLEAN AS $$
DECLARE x FLOAT;
BEGIN
    x = $1::FLOAT;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;
----- end of function

CREATE TABLE itfcdmpv532_daily.itf_specimen as
select
    ROW_NUMBER() OVER(ORDER BY NULL)::BIGINT AS UID
    , Q.*
  from(

    select
        A.patno ::  varchar(50) AS patient_id
        ,a.MEDDATE  ::  timestamp AS medical_dt
        ,a.COLLTIME ::  timestamp AS collect_dt
        ,a.BARPRNTM ::  timestamp AS barcode_dt
        ,null       ::  timestamp as recept_dt
        ,substr(to_char(a.SPCDATE::date, 'yyyymmdd'), 3) || a.SPCNO || a.SPCSEQ ::  varchar(50) AS specimen_no
        ,trim(c.OPTVALUE4)    ::  varchar(50) AS specimen_cd
        ,null   ::  varchar(50) AS site
        ,null   ::  varchar(50) AS unit
        ,case when isfloat(translate(c.OPTVALUE9, '0123456789.-' || c.OPTVALUE9, '0123456789.-')) then translate(c.OPTVALUE9, '0123456789.-' || c.OPTVALUE9, '0123456789.-') else null end ::  float AS quantity
        ,a.PROCSTAT ::  varchar(50) AS examination_yn
        ,d.RSLTTEXT ::  varchar(50) AS examination_rslt
        ,case when a.cancelps = 'C' then 'Y'
                else 'N' end    ::  varchar(1) AS cancel_yn
        ,nullif(a.CANCELTM,'')  ::  timestamp AS cancel_dt
        ,'검체채취내역'::varchar(10) as reference_gb
        ,a.edittime::timestamp as lastupdate_dt
      from ods_daily.SPCOLLMT a --검체채취내역
          inner join ods_daily.SPCOLLDT b --검체채취처방내역
                on b.SPCDATE = a.SPCDATE
                   and b.SPCNO = a.SPCNO
                   and b.SPCSEQ = a.SPCSEQ
          left join ods_daily.MMCOMRQT c --통합검사의뢰서
                on b.PATNO = c.PATNO
                    and b.ORDDATE = c.ORDDATE
                    and b.ORDSEQNO = c.ORDSEQNO
                    and '6' = c.REQTYPE
          left join ods_daily.SLTRSTMT d --통합검사결과내역
                on d.PATNO = b.PATNO
                    and d.ORDDATE = b.ORDDATE
                    and d.ORDSEQNO = b.ORDSEQNO
                    and d.EXAMCODE = b.ORDCODE
--        LEFT JOIN itfcdmpv532.itf_patno Z ON A.patno = Z.patno

    union all

    SELECT
          A.patno::VARCHAR(50)                  AS PATIENT_ID
          ,A.MEDDATE ::TIMESTAMP                    AS MEDICAL_DT
          ,A.COLLTIME ::TIMESTAMP                    AS COLLECT_DT
          ,A.BARPRNTM ::TIMESTAMP                    AS barcode_dt
          ,null       ::  timestamp as recept_dt
          ,substr(to_char(a.SPCDATE::date, 'yyyymmdd'), 3) || a.SPCNO || a.SPCSEQ   ::  varchar(50) AS specimen_no
          ,a.SPCCODE    ::  varchar(50) AS specimen_cd
          ,null :: varchar(50) as site
          ,null ::  varchar(50) AS unit
          ,null ::  float AS quantity
          ,a.PROCSTAT   ::  varchar(50) AS examination_yn
          ,b.rsltnum    ::  varchar(50) AS examination_rslt
          ,case when a.cancelps = 'C' then 'Y'
                else 'N' end    ::  varchar(1) AS cancel_yn
          ,nullif(a.CANCELTM,'')    ::  timestamp AS cancel_dt
          ,'검체접수내역'::varchar(10) as reference_gb
          ,a.edittime::timestamp as lastupdate_dt
    FROM ods_daily.SLACPTMT A
       INNER JOIN ods_daily.SLRSLTMT B
                on a.SPCDATE     = b.SPCDATE
               and a.SPCNO       = b.SPCNO
               and a.SPCSEQ      = b.SPCSEQ
               and a.SPCCODE     = b.SPCCODE
--    LEFT JOIN itfcdmpv532.itf_patno Z ON A.patno = Z.patno

  ) Q
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_specimen' , 'itf_specimen', count(*) as cnt
from itfcdmpv532_daily.itf_specimen ;  