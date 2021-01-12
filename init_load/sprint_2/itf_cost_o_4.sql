/*****************************************************
프로그램명  : ITF_COST_O_4.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 :  외래 COST 정보 선적재 4
cnt: 
time : 
*****************************************************/

DROP TABLE IF EXISTS ITFCDMPV532_daily.ITF_COST_O_4;;

      
CREATE TABLE itfcdmpv532_daily.ITF_COST_O_4 AS   
                SELECT a.patno
                     , a.meddate
                     , a.ordtable
                     , a.orddate
                     , a.ordseqno
                     , a.ordcode
                     , a.sugacode
                     , '24' naccucd
                     ,    case when a.jobfg = 'R' then '[취소]' else  '' end
                       || c.korname
                       || case when  a.pjtcode is null then null else '    (* 임상연구 *)' end
                          codename /* 명칭 */
                     , A.RCPAMT::DECIMAL + A.SPCAMT::DECIMAL + COALESCE (A.YSCHAAMT, 0) + COALESCE ( A.VATAMT, 0) RCPAMT /* 총액   */
                     , a.instyp instyp --진찰료 전액본인부담으로 변경
                     , '0'::float yschaamt
                     , a.spcamt spcamt
                     , a.typecd typecd
                     , a.ownrat
                     , a.pattyp
                     , a.rcptyp
                     , a.oifg
                     , c.insintyp
                     , c.selrat
                     , a.largcd
                     , a.execdate
                     , a.patfg
                     , a.edittime 
                     , a.meddept 
                  FROM ods_daily.aoopcalt a, ods_daily.acpricst c
                 WHERE 1=1 
                   --AND a.patno = :patno
                   --AND a.rcpdate = TO_DATE (:rcpdate, 'yyyy-mm-dd')
                   --AND a.rcpseq = :rcpseq
                   --AND a.appatfg = :patfg
                   and a.rejttime IS null
                   AND a.vatamt::int != 0
                   AND c.sugacode = coalesce (a.sugacode, '*')
                   AND c.fromdate = (SELECT 
                                           MAX (x.fromdate)
                                       FROM ods_daily.acpricst x
                                      WHERE x.sugacode = coalesce (a.sugacode, '*')
                                        AND  x.fromdate::date <=  a.execdate::date                                        
                                        )
                    AND A.recdtyp != 'G';;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_o_4' , 'itf_cost_o_4', count(*) as cnt
from itfcdmpv532_daily.itf_cost_o_4 ;

