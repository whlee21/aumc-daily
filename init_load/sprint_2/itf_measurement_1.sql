/*****************************************************
프로그램명  : ITF_MEASUREMENT_1.SQL
작성자      : Won Jong Bok
수정자      : LHY
최초 작성일 : 2020-12-03
수정일      : 
소스 테이블(기본) : SLACPTMT(검체접수내역), SLRSLTMT(검체검사결과내역)
소스 테이블(참조) : SLRSLTDT(결과상세내역)
프로그램 설명 :  진단검사 결과를 선적재 한다.

CREATE INDEX person_patno_idx ON ods_daily.person (patno);

CREATE INDEX sldspcct_examcode_idx ON ods_daily.sldspcct (examcode,spccode,appltime);
CREATE INDEX slrefert_examcode_idx ON ods_daily.slrefert (EXAMCODE,REFFG,SPCCODE,APPLTIME,SEX,AGETOTAL);
CREATE INDEX slrsltdt_workarea_idx ON ods_daily.slrsltdt (workarea,workdate,labno,ordcode,subitem);

Comments(JCho): isnumeric 임의 생성. 추후 수정 필요 
*****************************************************/

DROP TABLE IF EXISTS ITFCDMPV532_daily.ITF_MEASUREMENT_1;;


----- Declare of isnumeric function
CREATE OR REPLACE FUNCTION isnumeric(text) RETURNS BOOLEAN AS $$
DECLARE x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;
----- end of function

create  TABLE itfcdmpv532_daily.ITF_MEASUREMENT_1
AS
select a.PATNO                                          as patient_id
      ,a.ORDSEQNO                                       as order_no
      ,a.ORDCODE                                        as order_cd
      ,c.PATFG                                          as visit_gb
      ,c.MEDDATE                                        as medical_dt
      ,a.ORDDATE                                        as order_dt
      ,c.EXECTIME                                       as execute_dt
      ,coalesce(b.RSLTTM, a.RSLTTM)                     as record_dt
      ,c.MEDDEPT                                        as medical_dept
      ,coalesce(b.SUBITEM,a.ordcode)                    as exam_cd
      ,null                                             as exam_sub_cd
      ,a.spcno                                          as specimen_no
      ,a.SPCCODE                                        as specimen_cd
      ,'N'                                              as antibiotic_yn
      ,null                                             as antibiotic_cd
      ,null                                             as examination_gb
      ,null                                             as relation_no
      ,c.ORDDR                                          as order_dr
      ,c.EXECID                                         as act_dr
      ,coalesce(b.REGID,a.REGID)                        as recorder
      ,'N'                                              as prn_order_yn
      ,'N'                                              as prn_act_yn
      , case when c.CANCELID is null then 'N'
                            else  'Y' end               as cancel_yn
      , c.CANCELTM                                      as cancel_dt
      ,'Y'                                              as valid_yn
      ,CASE WHEN POSITION('이상' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '>='
                WHEN POSITION('이하' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '<='
                WHEN POSITION('초과' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '>'
                WHEN POSITION('미만' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '<'
                WHEN POSITION('같다' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '='
                WHEN POSITION('>=' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '>='
                WHEN POSITION('<=' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '<='
                WHEN POSITION('>' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '>'
                WHEN POSITION('<' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '<'
                WHEN POSITION('=' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN '='
          ELSE NULL
          END                                           as result_operator 
      --,CASE WHEN ods_daily.IS_NUMERIC(TRANSLATE(coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-' || coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-')) THEN TRANSLATE(coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-' || coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-') ELSE NULL END AS RESULT_NUM
      ,CASE WHEN isnumeric(TRANSLATE(coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-' || coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-')) THEN TRANSLATE(coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-' || coalesce(b.RSLTNUM, a.RSLTNUM), '0123456789.-') ELSE NULL END AS RESULT_NUM
      ,CASE WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Positive(+)' THEN '+'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Pos(+)' THEN '+'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Pos(++)' THEN '++'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Pos(+++)' THEN '+++'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Pos(++++)' THEN '++++'
            WHEN POSITION('Neg' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN 'Negative'
            WHEN POSITION('NEG' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN 'Negative'
            WHEN POSITION('N(' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN 'Negative'
            WHEN POSITION('Pos' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN 'Positive'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = '-' THEN 'Negative'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Clear' THEN 'Clear'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'AB' THEN 'Group AB'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'B' THEN 'Group B'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'A' THEN 'Group A'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'O' THEN 'Group O'
            WHEN lower(coalesce(b.RSLTNUM, a.RSLTNUM)) = 'straw' THEN 'Straw color'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Trace' THEN 'trace'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = '1+' THEN '+'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = '2+' THEN '++'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = '3+' THEN '+++'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = '4+' THEN '++++'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Amber' THEN 'Amber color'
            WHEN POSITION('yellow' IN lower(coalesce(b.RSLTNUM, a.RSLTNUM))) > 0 THEN 'Yellowish'
            WHEN POSITION('Red' IN coalesce(b.RSLTNUM, a.RSLTNUM)) > 0 THEN 'Red'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Green' THEN 'Greenish'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'S' THEN 'Susceptible'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Susceptible' THEN 'Susceptible'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Light turbid' THEN 'Light color'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Colorless' THEN 'Colorless'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Hazy' THEN 'Hazy'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Cloudy' THEN 'Cloudy'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Bloody' THEN 'Bloody'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Speckled' THEN 'Speckled'
            WHEN POSITION('normal' IN lower(coalesce(b.RSLTNUM, a.RSLTNUM))) > 0 THEN 'Normal range'
            WHEN POSITION('not detected' IN lower(coalesce(b.RSLTNUM, a.RSLTNUM))) > 0 THEN 'NOT detected'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Detected' THEN 'Detected'
            WHEN lower(coalesce(b.RSLTNUM, a.RSLTNUM)) in ('reactive weakly','weakly reactive','reactive') THEN 'Weakly Reactive'
            WHEN coalesce(b.RSLTNUM, a.RSLTNUM) = 'Indeterminate' THEN 'Intermediately susceptible'
        END                                             as result_category
      , NULL                                             as bacteria_cd
      ,coalesce(b.RSLTNUM, a.RSLTNUM)                   as result_txt
      ,(select c.UNIT from ods_daily.SLDSPCCT c 
                     where c.EXAMCODE = coalesce(b.SUBITEM, a.ORDCODE)
                       and c.SPCCODE  = a.SPCCODE
--                       and c.APPLTIME = ods_daily.fn_sl_maxappltime_sldspcct_s2(coalesce(b.SUBITEM, a.ORDCODE), a.SPCCODE, a.SPCDATE)
                       and c.APPLTIME = (
                           select x.APPLTIME from ods_daily.SLDSPCCT x 
                            where x.EXAMCODE = coalesce(b.SUBITEM, a.ORDCODE)
                              and  x.SPCCODE = a.SPCCODE
                              and  x.APPLTIME <= a.SPCDATE
                              and  (x.EXPTIME is null or x.EXPTIME > a.SPCDATE)
                            order by x.appltime desc
                              limit 1
                              )
                       )                                as result_unit
      ,(
        select MAXVAL
          from ods_daily.SLREFERT r
         where r.EXAMCODE = coalesce(b.SUBITEM, a.ORDCODE)
           and r.SPCCODE  = a.SPCCODE
--           and r.APPLTIME = ods_daily.fn_sl_maxappltime_slrefert2_s(coalesce(b.SUBITEM, a.ORDCODE), r.REFFG, a.SPCCODE, r.SEX, r.AGETOTAL, a.SPCDATE)
           and r.APPLTIME = (
                select x.APPLTIME from ods_daily.SLREFERT x
                 where x.EXAMCODE = coalesce(b.SUBITEM, a.ORDCODE)
                   and  x.REFFG = r.REFFG
                   and  x.SPCCODE = a.SPCCODE
                   and  (x.SEX = 'B' or x.SEX = r.SEX)
                   and  x.AGETOTAL >= r.AGETOTAL
                   and  x.APPLTIME <= a.SPCDATE
                   and  ((x.EXPTIME is null) or (x.EXPTIME > a.SPCDATE))
                   limit 1
                )
           and (r.SEX = 'B' or r.SEX = (select d.SEX from ods_daily.acpatbat d where d.PATNO = a.PATNO))
           and (r.EXPTIME is null or r.EXPTIME > a.SPCDATE)
        limit 1
       )                                                as normal_max
      ,(
        select MINVAL
          from ods_daily.SLREFERT r
         where r.EXAMCODE = coalesce(b.SUBITEM, a.ORDCODE)
           and r.SPCCODE  = a.SPCCODE
--           and r.APPLTIME = ods_daily.fn_sl_maxappltime_slrefert2_s(coalesce(b.SUBITEM, a.ORDCODE), r.REFFG, a.SPCCODE, r.SEX, r.AGETOTAL, a.SPCDATE)
           and r.APPLTIME = (
                select x.APPLTIME from ods_daily.SLREFERT x
                 where x.EXAMCODE = coalesce(b.SUBITEM, a.ORDCODE)
                   and  x.REFFG = r.REFFG
                   and  x.SPCCODE = a.SPCCODE
                   and  (x.SEX = 'B' or x.SEX = r.SEX)
                   and  x.AGETOTAL >= r.AGETOTAL
                   and  x.APPLTIME <= a.SPCDATE
                   and  ((x.EXPTIME is null) or (x.EXPTIME > a.SPCDATE))
                   limit 1
                )
           and (r.SEX = 'B' or r.SEX = (select d.SEX from ods_daily.acpatbat d where d.PATNO = a.PATNO))
           and (r.EXPTIME is null or r.EXPTIME > a.SPCDATE)
        limit 1
       )                                                as normal_min
      ,'진단검사'                                         as reference_gb
      , c.edittime                                      as lastupdate_dt
          from ods_daily.SLRSLTMT a
          inner join ods_daily.SLACPTMT c
                on c.SPCDATE     = a.SPCDATE
               and c.SPCNO       = a.SPCNO
               and c.SPCSEQ      = a.SPCSEQ
               and c.SPCCODE     = a.SPCCODE
            --   and a.SUBITEMYN = 'Y' --미생물 검사 제외 
--          inner join ods_daily.person d
--                on d.PATNO       = a.PATNO
          left join ods_daily.SLRSLTDT b 
                on b.WORKAREA  = a.WORKAREA
               and b.WORKDATE  = a.WORKDATE
               and b.LABNO     = a.LABNO
               and b.ORDCODE   = a.ORDCODE 
;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_measurement_1' , 'itf_measurement_1', count(*) as cnt
from itfcdmpv532_daily.itf_measurement_1 ;

