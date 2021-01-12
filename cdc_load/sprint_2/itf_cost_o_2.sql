/*****************************************************
프로그램명  : ITF_COST_O_2.SQL
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      :
소스 테이블(기본) : 
소스 테이블(참조) : 
프로그램 설명 :  외래 COST 정보 선적재 2
cnt: 36,757
time : 14s
*****************************************************/

DROP TABLE IF EXISTS ITFCDMPV532_daily.ITF_COST_O_2;;

      
CREATE TABLE itfcdmpv532_daily.ITF_COST_O_2 AS
  SELECT a.patno
         , a.meddate
         , a.ordtable
         , a.orddate
         , a.ordseqno
         , a.ordcode
         , a.sugacode
         , '25' naccucd
         ,    case when a.jobfg = 'R' then '[취소]' else  '' end
           || c.korname
           || case when a.pjtcode is null then null
                   else  '    (* 임상연구 *)' end
              codename /* 명칭 */
         , a.rcpamt::decimal + a.spcamt::decimal + coalesce ( a.yschaamt, 0)::decimal + coalesce ( a.vatamt, 0)::decimal rcpamt /* 총액   */
         , a.instyp instyp --진찰료 전액본인부담으로 변경
         , coalesce ( a.yschaamt , 0) yschaamt
         , a.spcamt spcamt
         , a.typecd typecd
         , a.ownrat
         , a.pattyp
         , a.rcptyp
         , a.oifg
         , d.insintyp
         , d.selrat
         , a.largcd
         , a.execdate
         , a.patfg
         , a.edittime 
         , a.meddept 
      FROM ods_daily.aoopcalt a
         , ods_daily.acpricst c
         , ods_daily.cscomcdt s
         , ods_daily.acpricst d
         , ods_daily.acpricst e
         , (select patno from ods_daily.target_person group by patno )  tp 
     WHERE 1=1
       --AND a.patno = :patno
       --AND a.rcpdate = TO_DATE (:rcpdate, 'yyyy-mm-dd')
       --AND a.rcpseq = :rcpseq
       --AND a.appatfg = :patfg
       and a.patno = tp.patno
       and a.rejttime IS null
       AND coalesce ( a.jobfg, '*') != 'R'
       AND case when a.rcptyp = 'J' then a.meddate
                else case when a.ordcode = 'XAU00001' then a.meddate 
                          when a.ordcode = 'XAU00002' then a.meddate
                          else a.rcpdate 
                      end 
            end  <= a.rcpdate --2015.09.01 KEJ 의료질평가지원금 추가
       AND c.sugacode = coalesce ( a.sugacode, '*')
       AND a.execdate::date BETWEEN c.fromdate::date AND replace(c.todate::varchar, '00:00:00', '23:59:59')::date
       AND e.sugacode = coalesce (a.ordcode, '*')
       AND a.meddate::date BETWEEN e.fromdate::date AND replace(e.todate::varchar, '00:00:00', '23:59:59')::date
       AND s.largecode = 'AI'
       AND s.midgcode = 'AI200'
       AND s.smallgcode = e.acttyp
       AND a.pattyp || a.typecd != '1077'
       --[선별급여항목]-----------------------
       AND d.sugacode = coalesce (a.sugacode, '*')
       AND a.execdate::Date BETWEEN d.fromdate::date AND replace(d.todate::varchar, '00:00:00', '23:59:59')::date
       AND (a.instyp || d.insintyp IN ('01', '21', '76')
         OR a.execdate::date >= TO_DATE ('2019-03-01', 'YYYY-MM-DD'))
       AND SUBSTR (a.pattyp, 1, 1) IN ('2', '3', '4')
       AND a.typecd NOT IN ('ST', '99')
       AND coalesce (  d.selrat, 0) > '0'
       AND a.largcd IN ('AA', 'BB', 'DD', 'EE')
       AND A.recdtyp != 'G';;


       -----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_o_2' , 'itf_cost_o_2', count(*) as cnt
from itfcdmpv532_daily.itf_cost_o_2 ;
