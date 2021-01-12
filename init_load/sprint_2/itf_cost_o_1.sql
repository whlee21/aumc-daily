/*****************************************************
프로그램명  : ITF_COST_O_1.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 :  외래 COST 정보 선적재 1
cnt: 
time: 
*****************************************************/
 
DROP TABLE IF EXISTS ITFCDMPV532_daily.ITF_COST_O_1;;
  
 CREATE TABLE ITFCDMPV532_daily.ITF_COST_O_1 AS
            SELECT A.PATNO
                     , A.MEDDATE
                     , A.ORDTABLE
                     , A.ORDDATE
                     , A.ORDSEQNO
                     , A.ORDCODE
                     , A.SUGACODE
                     , (CASE
                           WHEN A.PATTYP IN ('23', '31', '32', '40')
                            AND A.TYPECD = 'CA'
                            AND A.OWNRAT != '100'
                            AND ( (A.INSTYP IN ('0', '2', '7')
                               AND A.EXECDATE < '2019-03-01')
                              OR (A.INSTYP = '8'
                              AND A.EXECDATE >= '2019-03-01')) THEN
                              '25'
                           WHEN S.NOPTVALUE4::INT = 5
                            AND A.ACTMATYP = '1' THEN
                              '06'
                           WHEN S.NOPTVALUE4::INT = 7
                            AND A.ACTMATYP = '1' THEN
                              '08'
                           ELSE
                              S.NOPTVALUE4::text
                        END)
                          NACCUCD
                     ,    CASE WHEN A.JOBFG = 'R' THEN  '[취소]' ELSE  '' END
                       || C.KORNAME
                       || CASE WHEN A.PJTCODE IS NULL THEN  NULL ELSE  '    (* 임상연구 *)' END
                          CODENAME /* 명칭 */
                     , A.RCPAMT::DECIMAL + A.SPCAMT::DECIMAL + COALESCE (A.YSCHAAMT, 0)::DECIMAL + COALESCE (A.VATAMT, 0)::DECIMAL RCPAMT /* 총액   */
                     , A.INSTYP INSTYP --진찰료 전액본인부담으로 변경
                     , COALESCE (A.YSCHAAMT, 0) YSCHAAMT
                     , A.SPCAMT SPCAMT
                     , A.TYPECD TYPECD
                     , A.OWNRAT
                     , A.PATTYP
                     , A.RCPTYP
                     , A.OIFG
                     , D.INSINTYP
                     , 0 SELRAT
                     , A.LARGCD
                     , A.EXECDATE
                     , A.PATFG
                     , a.edittime 
                     , a.meddept 
                  FROM ods_daily.AOOPCALT A
                     , ods_daily.ACPRICST C
                     , ods_daily.CSCOMCDT S
                     , ods_daily.ACPRICST D
                     , ods_daily.ACPRICST E
                 WHERE 1=1
                   --AND A.PATNO = :PATNO
                   --AND A.RCPDATE = TO_DATE (:RCPDATE, 'YYYY-MM-DD')
                   --AND A.RCPSEQ = :RCPSEQ
                   --AND A.APPATFG = :PATFG
                   and a.rejttime is null
                   AND COALESCE (A.JOBFG, '*') != 'R'
                   AND CASE WHEN A.RCPTYP = 'J' THEN A.MEDDATE ELSE    -- 31800481
                               CASE WHEN A.ORDCODE = 'XAU00001' THEN A.MEDDATE
                                    WHEN A.ORDCODE = 'XAU00002' THEN A.MEDDATE
                                    ELSE A.RCPDATE 
                                END                               
                       END ::DATE                               
                               <=  A.RCPDATE::DATE --2015.09.01 KEJ 의료질평가지원금 추가                               
                   AND C.SUGACODE = COALESCE(A.SUGACODE, '*')
                   AND A.EXECDATE  BETWEEN C.FROMDATE  AND C.TODATE 
                  AND E.SUGACODE =  COALESCE (A.ORDCODE, '*')
                   AND A.MEDDATE  BETWEEN E.FROMDATE  AND E.TODATE 
                   AND S.LARGECODE = 'AI'
                   AND S.MIDGCODE = 'AI200'
                   AND S.SMALLGCODE = E.ACTTYP
                   AND A.PATTYP || A.TYPECD != '1077' --240237581
                   --[선별급여항목제외]-----------------------
                   AND D.SUGACODE = COALESCE ( A.SUGACODE, '*')
                   AND A.EXECDATE BETWEEN D.FROMDATE AND D.TODATE 
                   AND ( 
                    (A.INSTYP || D.INSINTYP NOT IN ('01', '21', '76')
                      AND A.EXECDATE < '2019-03-01')
                     OR SUBSTR (A.PATTYP, 1, 1) NOT IN ('2', '3', '4')
                     OR A.TYPECD IN ('ST', '99')
                     OR COALESCE (D.SELRAT, 0) = 0
                     OR A.LARGCD NOT IN ('AA', 'BB', 'DD', 'EE')
                    )
                    AND A.recdtyp != 'G'
;;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_o_1' , 'itf_cost_o_1', count(*) as cnt
from itfcdmpv532_daily.itf_cost_o_1 ;