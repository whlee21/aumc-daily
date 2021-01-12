/*****************************************************
프로그램명  : ITF_OBSERVATION_INDM.sql
작성자      : WON JONG BOK
수정자      : 
최초 작성일 : 2020-12-04
수정일      :
소스 테이블(기본) : MIRECEIT(산업검진접수), MIPPWD1T(산업검진 문진 및 진찰결과내역)
소스 테이블(참조) : 
프로그램 설명 : 산업검진시 문진내용
cnt : 
*****************************************************/

DROP TABLE IF EXISTS  itfcdmpv532_daily.ITF_OBSERVATION_FROM_INDM;


/* 산업검진 */
 CREATE TABLE itfcdmpv532_daily.ITF_OBSERVATION_FROM_INDM AS
    SELECT  -- 산업 검진 : 과거력- 암
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'CANCER' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
        , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.CANFG1 is not null 
    
    UNION ALL 
 
    SELECT  -- 산업 검진 : 과거력- 당뇨
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'DM' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
         , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.GLUFG1 is not null  
    
    UNION ALL

    SELECT  -- 산업 검진 : 과거력- 심장질환
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'HEART DISEASE' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
         , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.HRTFG1 is not null

    union all

    SELECT  -- 산업 검진 : 과거력- 뇌졸증
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'STROKE' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
         , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.COMAFG1 is not null   
 
    UNION ALL
 
    SELECT  -- 산업 검진 : 과거력- 고혈압
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'HTN' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B     
         , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND (A.HPFG1 is not null OR A.HPFG1 != 'X')
    
    UNION ALL
 
    SELECT  -- 산업 검진 : 과거력- 흡연여부
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , '흡연여부' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , CASE WHEN A.SMOKFG = '1' THEN 'Y' ELSE 'N' END AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.SMOKFG is not null

    union all

    SELECT  -- 산업 검진 : 과거력- 음주여부
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , '음주여부' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , CASE WHEN A.ACHOFG = '1' THEN 'Y' ELSE 'N' END AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.ACHOFG is not null    
    
    UNION ALL
   
    SELECT  -- 산업 검진 : 과거력- B형간염
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'HBV' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.LIVFG1 is not null 
    AND ( A.LIVFG1 LIKE '%HBV%' OR  A.LIVFG1 LIKE '%B형간염%' OR  A.LIVFG1 LIKE '%B형간염%' OR  A.LIVFG1 LIKE '%B형 간염%' 
            OR  A.LIVFG1 LIKE '%B VIRAL CARRIER%' OR  A.LIVFG1 LIKE '%B VIRAL CARRIER%'  OR  A.LIVFG1 LIKE '%HBV CARRIER%'  )
   
    UNION ALL
   
    SELECT  -- 산업 검진 : 과거력- C형간염
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'HCV' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
         , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.LIVFG1 is not null 
    AND ( A.LIVFG1 LIKE '%HCV%' OR  A.LIVFG1 LIKE '%C형간염%' OR  A.LIVFG1 LIKE '%C형간염%' OR  A.LIVFG1 LIKE '%C형 간염%' 
            OR  A.LIVFG1 LIKE '%C VIRAL CARRIER%' OR  A.LIVFG1 LIKE '%C VIRAL CARRIER%'  OR  A.LIVFG1 LIKE '%HCV CARRIER%'  )  

    union all

     SELECT  -- 산업 검진 : 과거력- A형간염
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , 'HAV' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-04-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.LIVFG1 is not null 
    AND ( A.LIVFG1 LIKE '%HAV%' OR  A.LIVFG1 LIKE '%A형간염%' OR  A.LIVFG1 LIKE '%A형간염%' OR  A.LIVFG1 LIKE '%A형 간염%' 
            OR  A.LIVFG1 LIKE '%A VIRAL CARRIER%' OR  A.LIVFG1 LIKE '%A VIRAL CARRIER%'  OR  A.LIVFG1 LIKE '%HAV CARRIER%'  )  
            
    UNION ALL
         
    SELECT  -- 산업 검진 : 과거력- 간경화
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , '간경화' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
     FROM ods_daily.MIPPWD1T A
     , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.LIVFG1 is not null 
    AND ( A.LIVFG1 LIKE '%간경화%' OR  A.LIVFG1 LIKE '%간 경화%' )  
                
    UNION ALL
   
    SELECT  -- 산업 검진 : 과거력- 간경변
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , '간경변' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
     , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
   AND A.ODT = B.ODT
   --AND A.SEQ = B.SEQ
   AND B.ODT::DATE >= '1999-01-01' 
   AND B.OSTSCD BETWEEN 'C' AND 'G'
   AND A.LIVFG1 is not null 
   AND ( A.LIVFG1 LIKE '%간경변%' OR  A.LIVFG1 LIKE '%간 경변%' )     

    union all

    SELECT  -- 산업 검진 : 과거력- 간디스토마
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , '간디스토마' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
     , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-04-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.LIVFG1 is not null 
    AND ( A.LIVFG1 LIKE '%간디스토마%' OR  A.LIVFG1 LIKE '%디스토마%' )     

    UNION ALL
   
    SELECT  -- 산업 검진 : 과거력- 지방간
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , A.EDITID AS MEDICAL_DR
        , '과거력' AS OBSERVATION_ITEM1
        , '지방간' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
     , ods_daily.MIRECEIT B     
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.LIVFG1 is not null 
    AND ( A.LIVFG1 LIKE '%지방간%' ) 
    
    UNION ALL
    
    -- 가족력    
    SELECT  -- 산업 검진 : 가족력-암
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'CANCER' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%CANCER%' OR  A.FAMS1 LIKE '%암%')

    union all

    SELECT  -- 산업 검진 :  가족력- 천식
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'ASTHMA' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
     FROM ods_daily.MIPPWD1T A
        , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%ASTHMA%' OR A.FAMS1 LIKE '%천식%')
   
    UNION ALL   
  
    SELECT  -- 산업 검진 : 가족력- 당뇨
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'DM' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
     FROM ods_daily.MIPPWD1T A
        , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-04-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%DM%' OR   A.FAMS1 LIKE '%DIABETES MELLITUS%' OR A.FAMS1 LIKE '%당뇨병%' OR A.FAMS1 LIKE '%당뇨%')

    UNION ALL
      
    SELECT  -- 산업 검진 : 가족력- 고지혈증
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'DYSLIPIDEMIA' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE >= '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%DYSLIPIDEMIA%' OR   A.FAMS1 LIKE '%고지혈증%' OR A.FAMS1 LIKE '%이상고지혈증%')

    union all

    SELECT  -- 산업 검진 : 가족력- 간염
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'HEPATITIS' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
       , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE > '1999-01-01'
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%HEPATITIS%' OR   A.FAMS1 LIKE '%간염%' )
  
    UNION ALL
  
    SELECT  -- 산업 검진 : 가족력- 고혈압
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'HTN' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE > '1999-04-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%HTN%' OR   A.FAMS1 LIKE '%HYPERTENSION%' OR A.FAMS1 LIKE '%고혈압%'  )
   
   UNION ALL
   
   SELECT  -- 산업 검진 : 가족력- 결핵
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'TB' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
        , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
        , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE > '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%TB%' OR A.FAMS1 LIKE '%TUBERCULOSIS%' OR A.FAMS1 LIKE '%결핵%' OR A.FAMS1 LIKE '%폐결핵%' )

    union all

    SELECT  -- 산업 검진 : 가족력- 뇌졸증
          A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'STROKE' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
                , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
       , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
    AND A.ODT = B.ODT
    --AND A.SEQ = B.SEQ
    AND B.ODT::DATE > '1999-01-01' 
    AND B.OSTSCD BETWEEN 'C' AND 'G'
    AND A.FAMS1 is not null
    AND ( A.FAMS1 LIKE '%뇌졸중%' OR A.FAMS1 LIKE '%중풍%' OR A.FAMS1 LIKE '%STROKE%')
  
   UNION ALL
      
    SELECT  -- 산업 검진 : 가족력- 심근경색
        A.PATNO AS PATIENT_ID
        , A.ODT AS MEDICAL_DT
        , A.ODT AS RECORD_DT
        , NULL AS ORDER_DT
        , 'G' AS VISIT_GB
        , 'TE' AS INSERT_TYPE
        , '산업의학 검진' FORM_NM
        , 'INDM' AS MEDICAL_DEPT
        , CASE WHEN A.EDITID is null THEN B.FANDR::int ELSE A.EDITID END AS MEDICAL_DR
        , '가족력' AS OBSERVATION_ITEM1
        , 'MI' AS OBSERVATION_ITEM2
        , '' AS  OBSERVATION_ITEM3
                , '' as qualifier
        , 'Y' AS RESULT_CD_TXT
        , NULL AS RESULT_NUM
        , null as result_unit
        , a.edittime as lastupdate_dt
    FROM ods_daily.MIPPWD1T A
      , ods_daily.MIRECEIT B
        , (select patno from ods_daily.target_person group by patno )  tp  
    WHERE A.PATNO = B.PATNO
    and a.patno = tp.patno
   AND A.ODT = B.ODT
   --AND A.SEQ = B.SEQ
   AND B.ODT::DATE > '1999-01-01'
   AND B.OSTSCD BETWEEN 'C' AND 'G'
   AND A.FAMS1 is not null
   AND ( A.FAMS1 LIKE '%심근경색%' OR  A.FAMS1 LIKE '%협심증%' OR  A.FAMS1 LIKE '%ANGINA%' OR  A.FAMS1 LIKE '%MI%' OR  A.FAMS1 LIKE '%MYOCARDIAL INFARCTION%')
 ;  


-----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_observation_from_indm' , 'itf_observation_from_indm', count(*) as cnt
from itfcdmpv532_daily.itf_observation_from_indm ;
