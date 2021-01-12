/*****************************************************
프로그램명  : ITF_MEASUREMENT_6.SQL
작성자     : 
수정자     : 
최초 작성일 : 2020-12-07
수정일     : 
소스 테이블(기본) : SLACPTMT(검체접수내역), SLRSLTMT(검체검사결과내역)
소스 테이블(참조) : SLMICSNT(감수성결과내역)
프로그램 설명 :  미생물검사


*****************************************************/


-- 미생물
DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_MEASUREMENT_6;;

 create  TABLE itfcdmpv532_daily.ITF_MEASUREMENT_6
    AS
  select distinct
       a.PATNO                                          as patient_id
      ,a.ORDSEQNO                                       as order_no
      ,a.ORDCODE                                        as order_cd
      ,c.PATFG                                          as visit_gb
      ,c.MEDDATE                                        as medical_dt
      ,a.ORDDATE                                        as order_dt
      ,c.EXECTIME                                       as execute_dt
      ,a.RSLTTM                                         as record_dt
      ,c.MEDDEPT                                        as medical_dept
      ,a.ORDCODE                                        as exam_cd
      ,null                                             as exam_sub_cd
      ,a.spcno                                          as specimen_no
      ,a.SPCCODE                                        as specimen_cd
      ,'N'                                              as antibiotic_yn
      ,null                                            as antibiotic_cd
      ,null                                             as examination_gb
      ,a.WORKAREA||a.WORKDATE||a.LABNO||a.ORDCODE||b.MICCODE        as relation_no
      ,c.ORDDR                                          as order_dr
      ,c.EXECID                                         as act_dr
      ,null                                             as recorder
      ,'N'                                              as prn_order_yn
      ,'N'                                              as prn_act_yn
      , case when c.CANCELID is null then 'N'
           else 'Y' end                                 as cancel_yn
      , c.CANCELTM                                      as cancel_dt
      ,'Y'                                              as valid_yn
      ,CASE
                WHEN POSITION('>=' IN b.SENSRSLT) > 0 THEN '>='
                WHEN POSITION('<=' IN b.SENSRSLT) > 0 THEN '<='
          ELSE NULL
          END                                           as result_operator
      ,CASE WHEN ods_daily.IS_NUMERIC(TRANSLATE(b.SENSRSLT, '0123456789.-' || b.SENSRSLT, '0123456789.-')) THEN TRANSLATE(b.SENSRSLT, '0123456789.-' || b.SENSRSLT, '0123456789.-') ELSE NULL END AS RESULT_NUM
      ,CASE WHEN b.SENSRSLT in ('+','P') THEN 'POSITIVE'
            WHEN b.SENSRSLT in ('-','N') THEN 'NEGATIVE'
          --  WHEN b.SENSRSLT = 'S' THEN 'Susceptible'
          --  WHEN b.SENSRSLT = 'I' THEN 'Intermediately susceptible'
          --  WHEN b.SENSRSLT = 'R' THEN 'Resistant'
        END                                             as result_category
      ,b.MICCODE                                        as bacteria_cd
      ,null                                      as result_txt
      ,(select c.UNIT from ods_daily.SLDSPCCT c
                     where c.EXAMCODE = a.ORDCODE
                       and c.SPCCODE  = a.SPCCODE
--                       and c.APPLTIME = ods_daily.fn_sl_maxappltime_sldspcct_s2(a.ORDCODE, a.SPCCODE, a.SPCDATE)
                       and c.APPLTIME = (
                           select x.APPLTIME from ods_daily.SLDSPCCT x
                            where x.EXAMCODE = a.ordcode
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
         where r.EXAMCODE = a.ORDCODE
           and r.SPCCODE  = a.SPCCODE
--           and r.APPLTIME = ods_daily.fn_sl_maxappltime_slrefert2_s(a.ORDCODE, r.REFFG, a.SPCCODE, r.SEX, r.AGETOTAL::numeric, a.SPCDATE)
           and r.APPLTIME = (
                select x.APPLTIME from ods_daily.SLREFERT x
                 where x.EXAMCODE = a.ordcode
                   and  x.REFFG = r.REFFG
                   and  x.SPCCODE = a.SPCCODE
                   and  (x.SEX = 'B' or x.SEX = r.SEX)
                   and  x.AGETOTAL >= r.AGETOTAL
                   and  x.APPLTIME <= a.SPCDATE
                   and  ((x.EXPTIME is null) or (x.EXPTIME > a.SPCDATE))
                   limit 1
                )
           and (r.SEX = 'B' or r.SEX = d.SEX)
           and (r.EXPTIME is null or r.EXPTIME > a.SPCDATE)
        limit 1
       )                                                as normal_max
      ,(
        select MINVAL
          from ods_daily.SLREFERT r
         where r.EXAMCODE = a.ORDCODE
           and r.SPCCODE  = a.SPCCODE
--           and r.APPLTIME = ods_daily.fn_sl_maxappltime_slrefert2_s(a.ORDCODE, r.REFFG, a.SPCCODE, r.SEX, r.AGETOTAL::numeric, a.SPCDATE)
           and r.APPLTIME = (
                select x.APPLTIME from ods_daily.SLREFERT x
                 where x.EXAMCODE = a.ordcode
                   and  x.REFFG = r.REFFG
                   and  x.SPCCODE = a.SPCCODE
                   and  (x.SEX = 'B' or x.SEX = r.SEX)
                   and  x.AGETOTAL >= r.AGETOTAL
                   and  x.APPLTIME <= a.SPCDATE
                   and  ((x.EXPTIME is null) or (x.EXPTIME > a.SPCDATE))
                   limit 1
                )
           and (r.SEX = 'B' or r.SEX = d.SEX)
           and (r.EXPTIME is null or r.EXPTIME > a.SPCDATE)
        limit 1
       )                                                as normal_min
      ,'미생물검사'                                        as reference_gb
      , c.edittime                                      as lastupdate_dt
          from ods_daily.SLRSLTMT a
              ,ods_daily.SLMICSNT b
              ,ods_daily.SLACPTMT c
              ,ods_daily.acpatbat d
              , (select patno from ods_daily.target_person group by patno )  tp
         where a.WORKAREA in ('41', '42', '43', 'AG', 'ST')
           and a.patno = tp.patno
           and a.SUBITEMYN = 'N'
           and b.WORKAREA  = a.WORKAREA
           and b.WORKDATE  = a.WORKDATE
           and b.LABNO     = a.LABNO
           and b.EXAMCODE   = a.ORDCODE
           and c.SPCDATE     = a.SPCDATE
           and c.SPCNO       = a.SPCNO
           and c.SPCSEQ      = a.SPCSEQ
           and c.SPCCODE     = a.SPCCODE
           and d.PATNO       = a.PATNO;;


           -----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_measurement_6' , 'itf_measurement_6', count(*) as cnt
from itfcdmpv532_daily.itf_measurement_6 ;
