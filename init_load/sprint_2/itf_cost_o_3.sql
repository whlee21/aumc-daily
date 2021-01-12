/*****************************************************
프로그램명  : ITF_COST_O_3.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-03
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 :  외래 COST 정보 선적재 3
cnt: 
time: 
*****************************************************/

DROP TABLE IF EXISTS ITFCDMPV532_daily.ITF_COST_O_3;;


CREATE TABLE itfcdmpv532_daily.ITF_COST_O_3 as
SELECT A.PATNO
        , A.MEDDATE
        , A.ORDTABLE
        , A.ORDDATE
        , A.ORDSEQNO
        , A.ORDCODE
        , A.SUGACODE
        , '02' NACCUCD
        ,   CONCAT(  CASE WHEN A.JOBFG = 'R' THEN '[취소]' ELSE  '' END
        , C.KORNAME
        , CASE WHEN A.PJTCODE IS NULL THEN  NULL ELSE  '    (* 임상연구 *)' END )
            CODENAME /* 명칭 */
        , A.RCPAMT::DECIMAL + A.SPCAMT::DECIMAL + COALESCE( A.YSCHAAMT, '0')::DECIMAL + COALESCE( A.VATAMT, '0')::DECIMAL RCPAMT /* 총액   */
        , A.INSTYP INSTYP --진찰료 전액본인부담으로 변경
        , COALESCE(  A.YSCHAAMT, '0') YSCHAAMT
        , A.SPCAMT SPCAMT
        , A.TYPECD TYPECD
        , A.OWNRAT
        , A.PATTYP
        , A.RCPTYP
        , A.OIFG
        , C.INSINTYP
        , C.SELRAT
        , A.LARGCD
        , A.EXECDATE
        , A.PATFG
        , a.edittime 
        , a.meddept 
    FROM ods_daily.AOOPCALT A
        , ods_daily.ACPRICST C
        , ods_daily.CSCOMCDT S
        , ods_daily.ACPRICST E
    WHERE 1=1 
    -- AND A.PATNO = :PATNO
    --  AND A.RCPDATE = TO_DATE (:RCPDATE, 'YYYY-MM-DD')
    -- AND A.RCPSEQ = :RCPSEQ
    -- AND A.APPATFG = :PATFG
    and a.rejttime is null
    AND COALESCE ( A.JOBFG, '*') != 'R'
    AND (A.RCPTYP = 'J'
        OR A.ORDCODE IN ('XAU00002', 'XAU00001')) --2015.09.01 KEJ 의료질평가지원금 추가
    AND A.MEDDATE > A.RCPDATE
    AND C.SUGACODE = COALESCE (A.SUGACODE, '*')
    AND A.EXECDATE::DATE BETWEEN C.FROMDATE::DATE AND REPLACE(C.TODATE::varchar, '00:00:00', '23:59:59')::DATE
    AND E.SUGACODE = COALESCE (A.ORDCODE, '*')
    AND A.MEDDATE::DATE BETWEEN E.FROMDATE::DATE AND  REPLACE(E.TODATE::varchar, '00:00:00', '23:59:59')::DATE
    AND S.LARGECODE = 'AI'
    AND S.MIDGCODE = 'AI200'
    AND S.SMALLGCODE = E.ACTTYP
    AND A.PATTYP || A.TYPECD != '1077'
    AND A.recdtyp != 'G'
    ;;

    -----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_o_3' , 'itf_cost_o_3', count(*) as cnt
from itfcdmpv532_daily.itf_cost_o_3 ;

