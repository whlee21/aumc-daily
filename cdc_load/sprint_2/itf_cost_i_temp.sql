/*****************************************************
파일명: ITF_COST_I_TEMP1.sql
V2.0 2020-12-07
cnt: 
-- cost 전처리
CREATE INDEX itf_apipcalt_patno_idx ON ods_daily.apipcalt (patno,admtime,pattyp,typecd,sugacode,execdate); --96m

******************************************************/

DROP TABLE IF EXISTS itfcdmpv532_daily.ITF_COST_I_TEMP;; 

create  table itfcdmpv532_daily.ITF_COST_I_TEMP
    as
    select
    a.admtime
    ,a.execdate
    ,a.instyp
    ,a.ordcode
    ,a.orddate
    ,a.ordseqno
    ,a.ordtable
    ,a.ownrat
    ,a.patfg
    ,a.patno
    ,a.pattyp
    ,a.rcpamt
    ,a.spcamt
    ,a.typecd
    ,a.yschaamt
    ,b.actmatyp
    ,b.acttyp
    ,b.drguniyn
    ,b.susulyn
    ,c.admtime as  admtime2
    ,c.drgyn
    ,c.fromdate
    , c.todate
    ,c.patno as patno2
    ,c.typecd typecd2
    , ( select e.noptvalue2 from ods_daily.cscomcdt e
    where e.largecode = 'AI'
     AND e.midgcode = 'AI200'
     AND e.smallgcode = b.acttyp
    ) noptvalue2
    ,a.sugacode
    ,a.edittime 
    ,a.meddept 
    FROM ods_daily.apipcalt a
    inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
    inner join  ods_daily.acpricst b on b.sugacode = a.sugacode
        AND a.execdate BETWEEN b.fromdate AND b.todate
    inner join ods_daily.apchangt c on a.patno = c.patno
                 AND a.admtime = c.admtime
                 AND a.pattyp = c.pattyp
                 AND a.typecd = c.typecd
                 AND a.execdate BETWEEN c.fromdate AND c.todate
    WHERE 1=1
    AND a.rejttime is null
    and a.recdtyp!='G'
;;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_cost_i_temp' , 'itf_cost_i_temp', count(*) as cnt
from itfcdmpv532_daily.itf_cost_i_temp ;
