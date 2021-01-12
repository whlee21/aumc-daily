/*****************************************************
프로그램명  : ITF_ORDER_6.sql
작성자      : Won Jong Bok
수정자      : 
최초 작성일 : 2020-12-07
수정일      :
소스 테이블(기본) : itf_mmdmmatt
소스 테이블(참조) :
프로그램 설명 : 당뇨소모성재료
cnt:  
*****************************************************/

DROP TABLE if exists itfcdmpv532_daily.itf_order_6;;


CREATE TABLE itfcdmpv532_daily.itf_order_6 AS
 SELECT 
      PATIENT_ID
    , VISIT_GB
    , ORDER_CD
    , MAX(ORDER_SEQ)::varchar ORDER_SEQ
    , MAX(ORDER_SUB_CD) ORDER_SUB_CD
    , MAX(START_DT) START_DT
    , ORDER_DT ORDER_DT
    , MEDICAL_DT MEDICAL_DT
    , MAX(OPERATION_DT) OPERATION_DT
    , MAX(ACT_DT) ACT_DT
    , MAX(ANESTHESIA_DT) ANESTHESIA_DT    
    , MAX(MEDICAL_DEPT) MEDICAL_DEPT
    , 'N' AS SELF_DRUG_YN
    , MAX(OPERATION_SEQ) OPERATION_SEQ
    , MAX(TOT_ORDER_YN) TOT_ORDER_YN
    , MAX(TOT_ORDER_QTY) TOT_ORDER_QTY
    , MAX(ORDER_DAY) ORDER_DAY    
    , MAX(ORDER_QTY1) ORDER_QTY1
    , MAX(ORDER_QTY2) ORDER_QTY2
    , MAX(ORDER_CNT)::int ORDER_CNT
    , MAX(ORDER_DR) ORDER_DR
    , MAX(PROCEDURE_PROVIDER) PROCEDURE_PROVIDER
    , MAX(DEVICE_PROVIDER) DEVICE_PROVIDER
    , MAX(CHARGE_DR) CHARGE_DR
    , MAX(OPERATION_DR) OPERATION_DR
    , MAX(ANESTHESIA_DR) ANESTHESIA_DR
    , MAX(ACT_DR) ACT_DR
    , MAX(ACT_PROVIDER) ACT_PROVIDER    
    , NULL AS medical_dr
    , MAX(ORDER_CLASS_GB) ORDER_CLASS_GB
    , MAX(DC_YN1) DC_YN1
    , MAX(DC_YN2) DC_YN2
    , MAX(DC_ORDER_SEQ) DC_ORDER_SEQ
    , MAX(ORDER_GB) ORDER_GB
    , MAX(ACT_YN) ACT_YN
    , MAX(PRN_ORDER_YN) PRN_ORDER_YN
    , MAX(PRN_ACT_YN) PRN_ACT_YN    
    , MAX(PRE_ORDER_YN) PRE_ORDER_YN
    , MAX(PRE_ORDER_ACT_YN) PRE_ORDER_ACT_YN
    , MAX(METHOD_CD) METHOD_CD
    , MAX(VERBATIM_END_DATE) VERBATIM_END_DATE
    , null as stop_dt
    , MAX(STOP_REASON) STOP_REASON
    , MAX(REMARK) REMARK       
    , MAX(DRUG_UNIT) DRUG_UNIT
    , MAX(REFILL_CNT) REFILL_CNT
    , MAX(LOT_NUMBER) LOT_NUMBER
    , MAX(DISCHARGE_DRUG_YN) DISCHARGE_DRUG_YN
    , MAX(MODALITY_CD) MODALITY_CD
    , MAX(UNIQUE_NO) UNIQUE_NO
    , MAX(CANCEL_DT) CANCEL_DT
    , MAX(CANCEL_YN) CANCEL_YN
    , '당뇨병소모성재료' as reference_gb
    , null::timestamp as lastupdate_dt
    , NULL AS ward_cd
  FROM (   
      SELECT
           A.PATNO AS PATIENT_ID --환자번호
            , 'O' AS VISIT_GB --내원구분\
            , rn 
            , case when rn = 1 and BSUGAR = 'Y' then 'ABC00'  --혈당측정검사지
                   when rn = 2 and BLANCET = 'Y' then 'ABC01' --채혈침
                   when rn = 3 and INSULINJT = 'Y' then 'ABC02' --인슐린주사기
                   when rn = 4 and INSULNDLE = 'Y' then 'ABC03' --인슐린주사바늘
                   when rn = 5 and INSULINPJ = 'Y' then 'ABC04' --인슐린펌프용 주사기
                   when rn = 6 and INSULINPN = 'Y' then 'ABC05' --인슐린펌프용 주사바늘
                   when rn = 7 and  productnm in ('DEXCOM G5', 'Descom G5', 'Dexcom G5', 'Dxcom G5', 'G5', 'dexcom G5', 'dexcom g5', '덱스콤G5' ) then 'ABC06' --DEXCOM G5 SENSOR
                   when rn = 8 and  productnm in ('엔라이트센터', '엔라이트센서', 'Enlight  Sensor', '엔라이트 센서', '엔라이트센서' )  then 'ABC07' --ENLITE_SENSOR
                   when rn = 9 and  productnm in ('Guardian 3 Sensor', '가디언 3 센터', '가디언3센서', '가디언3센터' ) then 'ABC08' --Guardian_3_Sensor
                   when rn = 10 and  productnm in ('guardian connect', '가디언건넥트', '가디언컨넥트', '가디언케넥트', '가이언커넥트' ) then 'ABC09' --guardian_connect
              else null  end ORDER_CD    
          , A.seqno AS ORDER_SEQ --처방순번
            , NULL AS ORDER_SUB_CD --처방상세코드
            , NULL AS START_DT  --
            , a.rptdt AS ORDER_DT --처방일시
            , a.rptdt AS MEDICAL_DT   --진료일시
            , NULL AS OPERATION_DT  --수술일시
            , NULL AS ACT_DT--시행일시
            , NULL AS ANESTHESIA_DT --마취시작일시 없는거 같음 
            , a.MEDDEPT AS MEDICAL_DEPT    --진료과
            , NULL AS OPERATION_SEQ --수술순번
            , 'N' AS TOT_ORDER_YN
            , NULL AS TOT_ORDER_QTY
            , a.ordterm AS ORDER_DAY    --처방일수
            , 1 ORDER_QTY1  -- 처방량  -- 문의
            , NULL AS ORDER_QTY2    -- 처방량 
            , 1 AS ORDER_CNT    --처방횟수   -- 문의
            , a.MEDDR AS ORDER_DR -- EXECDR            
            , NULL AS PROCEDURE_PROVIDER    -- 처치의
            , NULL AS DEVICE_PROVIDER
            , NULL AS CHARGE_DR -- 주치의
            , NULL AS OPERATION_DR  -- 수술의
            , NULL AS ANESTHESIA_DR --마취의
            ,  NULL  AS ACT_DR --시행의
            , NULL AS ACT_PROVIDER -- EXECDR
            , 'D2' AS ORDER_CLASS_GB    -- 처방코드구분 : 재료
            , 'N'                                            AS DC_YN1  --DC여부
            , 'N' AS DC_YN2 --DC여부
            , NULL AS DC_ORDER_SEQ  --D/C원처방번호  DC여부가 Y 면 처방 번호를 그대로 쓰면 되는것인가
            , 'N' AS ORDER_GB   --처방발생구분 A랑 N  만 CDM으로 추출되는지 확인
            , 'Y' AS ACT_YN -- 실시구분 ACTCNT: 간호사 실시여부
            , 'N' AS PRN_ORDER_YN   --PRN처방여부
            , 'N' AS PRN_ACT_YN --PRN실시여부
            , 'N' AS PRE_ORDER_YN   --선처방여부
            , 'N' AS PRE_ORDER_ACT_YN   -- 선처방실시여부
            , NULL AS METHOD_CD  -- 투여방법
            , NULL AS VERBATIM_END_DATE  -- 중지지시일시
            , NULL AS STOP_DT    -- 중지일시
            , NULL AS STOP_CAUSE     -- 중지사유
            , NULL AS REMARK     -- 복용법
            , NULL AS DRUG_UNIT --처방약단위
            , NULL AS REFILL_CNT     -- 리필횟수 --
            , NULL AS LOT_NUMBER     -- 약품수량 --
            , 'N'  AS DISCHARGE_DRUG_YN  -- 퇴원약여부 
            , NULL AS MODALITY_CD    -- 양식코드
            , NULL AS UNIQUE_NO  -- 기기식별번호
            , NULL AS CANCEL_DT
            , 'N' AS CANCEL_YN   -- 취소삭제여부
            , NULL AS STOP_REASON
      FROM ods_daily.mmdmmatt A 
      inner join (select patno from ods_daily.target_person group by patno )  tp on a.patno = tp.patno
      inner join  (select rn from generate_series(1,10) as rn) b
      WHERE 1=1   
  ) T 
  WHERE ORDER_CD IS NOT null
  GROUP BY  PATIENT_ID , VISIT_GB, ORDER_CD ,ORDER_SEQ ,ORDER_DT, MEDICAL_DT    ;;


   -----------------------------check cnt
insert into ods_daily.etl_task_check(task_grp_id, task_id, table_name, cnt)
select (SELECT last_value FROM etl_task_check_grp_id), 'itf_order_6' , 'itf_order_6', count(*) as cnt
from itfcdmpv532_daily.itf_order_6 ;

