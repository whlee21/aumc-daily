/*****************************************************
프로그램명  : pre_master.sql
작성자      : Won Jong Bok
수정자      :
최초 작성일 : 2020-12-04
수정일      :
프로그램 설명 : code master 선작
*****************************************************/



DROP TABLE if exists itfcdmpv532_daily.pre_itf_acedimst;;

create table itfcdmpv532_daily.pre_itf_acedimst as
select edicode ,max(ediname ) ediname from ods_daily.acedimst 
 where (edicode ,fromdate ,todate ) in(
                     select edicode,max(fromdate ) fromdate ,todate 
                       from ods_daily.acedimst 
                      where (edicode, todate) in (
                                         select
                                             edicode 
                                            ,max(todate) todate 
                                           from ods_daily.acedimst 
                                         group by edicode 
                                     )
                                 group by edicode,todate 
             ) 
group by edicode 
;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'pre_itf_acedimst' , 'pre_itf_acedimst', count(*) as cnt
from itfcdmpv532_daily.pre_itf_acedimst ;  

DROP TABLE if exists itfcdmpv532_daily.pre_itf_smdiagct;;

create table itfcdmpv532_daily.pre_itf_smdiagct as
select * from ods_daily.smdiagct 
 where (diagcode ,fromdate ,todate ) in(
                     select diagcode,max(fromdate ) fromdate ,todate 
                       from ods_daily.smdiagct 
                      where (diagcode, todate) in (
                                         select
                                             diagcode 
                                            ,max(todate) todate 
                                           from ods_daily.smdiagct 
                                         group by diagcode 
                                     )
                                 group by diagcode,todate 
             ) 
;

-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'pre_itf_smdiagct' , 'pre_itf_smdiagct', count(*) as cnt
from itfcdmpv532_daily.pre_itf_smdiagct ;  



DROP TABLE if exists itfcdmpv532_daily.pre_itf_acpricst;;

create table itfcdmpv532_daily.pre_itf_acpricst as
select * from ods_daily.acpricst 
 where (sugacode ,fromdate ,todate ) in(
                     select sugacode,max(fromdate ) fromdate ,todate 
                       from ods_daily.acpricst 
                      where (sugacode, todate) in (
                                         select
                                             sugacode 
                                            ,max(todate) todate 
                                           from ods_daily.acpricst 
                                         group by sugacode 
                                     )
                                 group by sugacode,todate 
             ) 
;


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'pre_itf_acpricst' , 'pre_itf_acpricst', count(*) as cnt
from itfcdmpv532_daily.pre_itf_acpricst ; 
