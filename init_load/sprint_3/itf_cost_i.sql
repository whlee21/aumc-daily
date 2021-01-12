/*****************************************************
프로그램명  : ITF_COST_I.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-04
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 : 입원COST내역

cnt : 
time : 
*****************************************************/

DROP TABLE if exists itfcdmpv532_daily.ITF_COST_I;;

create table itfcdmpv532_daily.ITF_COST_I as
SELECT 
        null::varchar(50) as visit_no -- 방문고유번호
        , patno::varchar(50) as patient_id -- 환자번호
        , ordtable::varchar as order_tb -- 처방테이블
        , admtime::timestamp as medical_dt -- 진료일시
        , orddate::timestamp as order_dt -- 처방일시
        , ordseqno::varchar(50) as order_seq -- 처방순번
        , ordcode::varchar(50) as order_cd -- 처방코드
        , sugacode::varchar(50) as order_sub_cd -- 처방코드
        , pattyp::varchar(10) as insurance_gb -- 보험구분
        , patfg::varchar(10) as visit_gb -- 내원구분
        , a.meddept::varchar(50) as medical_dept -- 진료과
        , ownamt::numeric as patient_pay_amt -- 환자부담금
        , reqamt::numeric as insurance_pay_amt -- 공단부담금
        , totamt::numeric as total_pay_amt -- 총액
        , c24::varchar as cost_gb -- 비용구분
        , drg_gb::varchar(1) as drg_gb -- DRG구분
        , c33::varchar(50) as drg_cd -- DRG코드
        , 'won'::varchar(10) as currency -- 화폐단위
        , 'N'::varchar(10) as cancel_yn -- 취소여부
        , '입원 계산 내역'::varchar(10) as reference_gb
        , edittime::timestamp as lastupdate_dt
  FROM (
          
                SELECT b.patno
                     , b.admtime::timestamp::text
                     , '[DRG]' ordtable
                     , NULL orddate
                     , NULL ordseqno
                     , NULL ordcode
                     , CASE
                          WHEN c.seq = '0' THEN a.btotamt::numeric + a.selamt::numeric - a.totdietamt::numeric - a.suraddamt::numeric - a.sonicamt::numeric
                          WHEN c.seq = '1' THEN a.totdietamt::numeric
                          WHEN c.seq = '2' THEN a.suraddamt::numeric
                          WHEN c.seq = '3' THEN a.sonicamt::numeric
                       END
                          totamt -- 총금액
                     , CASE
                          WHEN c.seq = '0' THEN
                               a.reqamt::numeric
                             + a.reqselamt::numeric
                             - (a.totdietamt::numeric - a.owndietamt::numeric)
                             - (a.suraddamt::numeric - a.ownsuraddamt::numeric)
                             - (a.sonicamt::numeric - a.ownsonicamt::numeric)
                          WHEN c.seq = '1' THEN
                             a.totdietamt::numeric - a.owndietamt::numeric
                          WHEN c.seq = '2' THEN
                             a.suraddamt::numeric - a.ownsuraddamt::numeric
                          WHEN c.seq = '3' THEN
                             a.sonicamt::numeric - a.ownsonicamt::numeric
                       END
                          reqamt -- 조합부담
                     , CASE
                          WHEN c.seq = '0' THEN a.ownamt::numeric + a.ownselamt::numeric - a.owndietamt::numeric - a.ownsuraddamt::numeric - a.ownsonicamt::numeric
                          WHEN c.seq = '1' THEN a.owndietamt::numeric
                          WHEN c.seq = '2' THEN a.ownsuraddamt::numeric
                          WHEN c.seq = '3' THEN a.ownsonicamt::numeric
                       END
                          ownamt -- 환자부담
                     , a.pattyp         --23:건강보험  insurance_gb
                     , '포괄수가진료비' c24    -- cost_gb 
                     , 'Y' drg_gb
                     , a.drgno c33  --drg_cd
                     , a.patfg
                     , NULL AS sugacode
                     , a.edittime::timestamp::text 
                     , null as meddept --
                  FROM ods_daily.airdrpat a, ods_daily.apchangt b, (select seq FROM  generate_series(0, 3) AS seq) c
                 WHERE 1=1
                 -- a.patno = :patno
                 --AND a.admtime = TO_DATE (:admtime, 'yyyy-mm-dd hh24:mi')
                   AND a.jobstat = 'P'
                   AND a.patno = b.patno
                   AND a.admtime = b.admtime
                   AND a.pattyp = b.pattyp
                   AND a.typecd = b.typecd
                   AND a.fromdate = b.fromdate

        
        union all

        
       SELECT
              a.patno
             , a.admtime
             , a.ordtable
             , a.orddate::date as orddate
             , a.ordseqno
             , a.ordcode
             ,   CASE
                    WHEN coalesce (a.drgyn, 'N') = 'N'
                      OR coalesce (jobstat, 'S') <> 'P' THEN
                       a.rcpamt::numeric
                    ELSE
                       CASE
                          WHEN a.instyp IN ('4', '7')
                           AND coalesce (a.drguniyn, 'N') = 'Y' THEN --RCPAMT
                             CASE
                                WHEN a.acttyp IN ('4AM1', '4AM2', '4AM3', '4AM4')
                                and        
                                 coalesce ( ( SELECT 'Y'
                                  FROM ods_daily.apipcalt
                                 WHERE patno = a.patno
                                   AND admtime = a.admtime
                                   AND rejttime is null
                                   --AND (sugacode LIKE 'LA226%' OR sugacode LIKE 'LA227%')
                                   --20170411 KEJ LA201','LA202','LA203' ,'LA204','LA205','LA206 추가
                        --           AND substr(sugacode,1,5) IN ('LA226','LA227','LA201','LA202','LA203' ,'LA204','LA205','LA206')
                                   AND (substr(sugacode,1,5) IN ('LA226','LA227') OR substr(sugacode,1,5) IN ('LA201','LA202','LA203' ,'LA204','LA205','LA206') AND (execdate::date >= to_date('20170411','yyyymmdd') OR PATNO = '2188490'))
                                   AND pattyp = a.pattyp
                                   AND typecd = a.typecd
                                   AND execdate::date BETWEEN a.fromdate::date AND a.todate::date
                                   AND coalesce(instyp,'*') NOT IN ('3')
                                   limit 1), 'N') = 'N'
                                /* AND ods_daily.fn_ai_pcaexists (a.patno
                                                    , a.admtime
                                                    , 'I'
                                                    , a.pattyp
                                                    , a.typecd
                                                    , c.fromdate::date
                                                    , c.todate::date) = 'N'
                                                    */ 
                                THEN
                                   0
                                ELSE
                                   a.rcpamt::numeric
                             END
                          ELSE
                             0
                       END
                 END
               + coalesce (a.spcamt::numeric, 0)
               + coalesce (a.yschaamt::numeric, 0)
                  totamt /* 총금액   */
             --------------------------------------------------------------------------------------------------------------
             ,   CASE
                    WHEN coalesce (a.drgyn, 'N') = 'N'
                      OR coalesce (jobstat, 'S') <> 'P' THEN
                       CASE
                          WHEN a.typecd NOT IN ('99', 'ST')
                           AND a.instyp IN ('0', '2', '7', '8')
                           AND a.ownrat::numeric <> 100 THEN
                             a.rcpamt::numeric * (100 - a.ownrat::numeric) / 100
                          ELSE
                             0
                       END
                    ELSE
                       0
                 END
               + coalesce (a.yschaamt::numeric, 0)
               + (a.spcamt::numeric
                  - coalesce (ods_daily.fc_ac_own_spcamt (a.pattyp
                                         , a.typecd
                                         , a.sugacode
                                         , a.instyp
                                         , a.acttyp
                                         , a.actmatyp
                                         , a.susulyn
                                         , a.execdate::date
                                         , a.spcamt::numeric), 0))
                  reqamt /* 조합부담 */
             --------------------------------------------------------------------------------------------------------------
             , CASE
                  WHEN coalesce (a.drgyn, 'N') = 'N'
                    OR coalesce (jobstat, 'S') <> 'P' THEN
                     a.rcpamt::numeric * a.ownrat::numeric / 100
                  ELSE --[DRG]
                     CASE
                        WHEN coalesce (a.drguniyn, 'N') = 'Y'
                         AND a.instyp IN ('4', '7') THEN --A.RCPAMT
                           CASE
                              WHEN a.acttyp IN ('4AM1', '4AM2', '4AM3', '4AM4')
                              and coalesce (( 
                                 SELECT 'Y'
                                  FROM ods.apipcalt
                                 WHERE patno = a.patno
                                   AND admtime = a.admtime
                                   AND rejttime is null
                                   --AND (sugacode LIKE 'LA226%' OR sugacode LIKE 'LA227%')
                                   --20170411 KEJ LA201','LA202','LA203' ,'LA204','LA205','LA206 추가
                        --           AND substr(sugacode,1,5) IN ('LA226','LA227','LA201','LA202','LA203' ,'LA204','LA205','LA206')
                                   AND (substr(sugacode,1,5) IN ('LA226','LA227') OR substr(sugacode,1,5) IN ('LA201','LA202','LA203' ,'LA204','LA205','LA206') AND (execdate::date >= to_date('20170411','yyyymmdd') OR PATNO = '2188490'))
                                   AND pattyp = a.pattyp
                                   AND typecd = a.typecd
                                   AND execdate::date BETWEEN a.fromdate::date AND a.todate::date
                                   AND coalesce(instyp,'*') NOT IN ('3')
                                   limit 1 ),'N'
                                   ) = 'N'
                             /*
                              AND ods_daily.fn_ai_pcaexists (a.patno
                                                  , a.admtime
                                                  , 'I'
                                                  , a.pattyp
                                                  , a.typecd
                                                  , c.fromdate::date
                                                  , c.todate::date) = 'N'
                               */                   
                              THEN 0
                              ELSE
                                 a.rcpamt::numeric
                           END
                        ELSE
                           0
                     END
               END
               + coalesce (ods_daily.fc_ac_own_spcamt (a.pattyp
                                      , a.typecd
                                      , a.sugacode
                                      , a.instyp
                                      , a.acttyp
                                      , a.actmatyp
                                      , a.susulyn
                                      , a.execdate::date
                                      , a.spcamt::numeric), 0)
                  ownamt /* 본인부담 */
             , a.pattyp /* 진료구분 */
             , 'I'||lpad(a.noptvalue2::text,2,'0')
                  c24
/*             , (SELECT codename
                  FROM ods_daily.cscomcdt
                 WHERE largecode = 'AC'
                   AND midgcode = 'AC017'
                   AND smallgcode = lpad(e.noptvalue2,2,'0'))
                  c24*/
             , a.drgyn as drg_gb
             , null c33
             ,a.patfg
             ,a.sugacode
             ,a.edittime
             ,a.meddept 
          FROM itfcdmpv532_daily.itf_cost_i_temp a
                left join ods_daily.airdrpat r on a.patno2 = r.patno
                           AND a.admtime2 = r.admtime
                           AND a.pattyp = r.pattyp
                           AND a.typecd2 = r.typecd
                           AND a.fromdate = r.fromdate
                           AND r.jobstat = 'P'
         WHERE 1=1
        
       ) A
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_i' , 'itf_cost_i', count(*) as cnt
from itfcdmpv532_daily.itf_cost_i ;

