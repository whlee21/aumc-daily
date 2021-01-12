
drop table if exists itfcdmpv532_daily.mt_rule_note;

create table itfcdmpv532_daily.mt_rule_note as 
select row_number() over(order by patient_id)::bigint as uid
     , t.patient_id 
     , t.language_gb
     , t.encoding_gb
     , t.note_start_dt
     , t.form_nm
     , t.txt
     , t.visit_no
     , t.visit_gb
     , t.medical_dr     
     , t.medical_dt
     , t.medical_dept
     , t.note_title     
     , case when t.note_start_dt is null                                            then 'A'  --시작일자가 null인 경우
            when t.patient_id is null                                               then 'B'  --환자번호가 null인 경우
            when t.note_start_dt::date < t.birth_dt::date                           then 'C'  --시작일자가 생년월일보다  먼저인 경우
            when t.note_start_dt::date > coalesce(d1.death_datetime::date, to_date('9999-12-31', 'yyyy-mm-dd')) then 'D'  --시작일자가 사망일자보다 나중인 경우
            else 'N' end as filtering
  from (select p1.patient_id 
             , n1.visit_no
             , n1.visit_gb
             , n1.medical_dr     
             , n1.medical_dt
             , n1.medical_dept
             , n1.form_nm as note_title             
             , p1.uid as person_id 
             , p1.birth_dt
             , c1.target_value as language_gb 
             , c2.target_value as encoding_gb 
             , c3.target_value as form_nm 
             , coalesce(n1.record_dt, n1.medical_dt) as note_start_dt
             , XMLELEMENT(NAME root, CAST(STRING_AGG(CAST(XMLELEMENT(NAME header, XMLFOREST(NOTE_ITEM AS nt,
             regexp_replace(result_desc, '['|| chr(1) || '-' || chr(8) ||chr(11) || '-' || chr(12) ||chr(14) || '-' || chr(31) ||chr(134) || '-' || chr(159) ||chr(127) || chr(128) || chr(129) || chr(130) || chr(131) || chr(132)|| ']', ' ', 'g' )
             AS rd)) AS TEXT),'''') AS XML)) :: TEXT AS TXT -- xml 1.1에 사용안되는 문자만 제거
          from itfcdmpv532_daily.itf_note n1 
          left join itfcdmpv532_daily.mt_person p1
            on n1.patient_id = p1.patient_id and p1.rn=1
          left join mapcdmpv532_daily.constant c1 
            on n1.language_gb = c1.source_value 
           and c1.idx = 1101
          left join mapcdmpv532_daily.constant c2 
            on n1.encoding_gb = c2.source_value 
           and c2.idx = 1102
          left join mapcdmpv532_daily.constant c3 
            on n1.form_nm = c3.source_value 
           and c3.idx = 1103
         group by p1.patient_id, n1.visit_no, n1.visit_gb, n1.medical_dr, n1.medical_dt, n1.medical_dept
                , n1.form_nm, p1.uid, p1.birth_dt, c1.target_value, c2.target_value, c3.target_value, n1.record_dt
       ) t left join cdmpv532_daily.death d1 on t.person_id = d1.person_id 
;
