-- 변경 대상 person 추출
drop table if exists ods_daily.target_person;


create table ods_daily.target_person as
select patno from ( 
	/* target_person 만들기 */
	select patno  from ods_daily.airdrpat  -- 초기 RDRG환자기본정보
	union all select patno  from ods_daily.aoinsurt_ogg
	--union all select patno  from ods_daily.aoopcalt_ogg -- 대용량 미적재
	union all select patno  from ods_daily.aoopdlst_ogg
	union all select patno  from ods_daily.aooppayt_ogg
	union all select patno  from ods_daily.apchangt_ogg
	--union all select patno  from ods_daily.apipcalt_ogg --대용량 미적재
	union all select patno  from ods_daily.apipdlst_ogg
	union all select patno  from ods_daily.apippayt_ogg
	union all select patno  from ods_daily.apmovett_ogg
	union all select patno  from ods_daily.apwardht-- 초기 병동사용현황
	union all select patno  from ods_daily.mmcermst_ogg
	union all select patno  from ods_daily.miordrdt_ogg
	union all select patno  from ods_daily.mireceit_ogg
	union all select patno  from ods_daily.mmcomrqt_ogg
	union all select patno  from ods_daily.mmdmmatt-- 초기  당뇨병환자 소모성 재료 처방전
	union all select patno  from ods_daily.mmadrmot-- 초기 [현재] ADR 평가 - 모니터링 정보
	union all select patno  from ods_daily.mmadrsrt-- 초기 [현재] ADR 평가 - 의심약제 정보
	union all select patno  from ods_daily.mmadravt-- 초기 [현재] ADR 평가 - 약물유해반응 정보
	union all select patno  from ods_daily.mmpdiagt_ogg
	union all select patno  from ods_daily.mnastmgt-- 초기 Skin 테스트관리
	union all select patno  from ods_daily.mnbloodt_ogg
	union all select patno  from ods_daily.mnicupat-- 초기 중환자실 환자정보
	union all select patno  from ods_daily.mnoutact_ogg
	union all select patno  from ods_daily.mnoutrpt_ogg
	union all select patno  from ods_daily.mnvitalt_ogg
	union all select patno  from ods_daily.mnwadact_ogg
	union all select patno  from ods_daily.mpreceit_ogg
	--union all select ptnt_no  from ods_daily.mrr_frm_clninfo_ogg -- 대용량 미적재
	union all select patno  from ods_daily.slacptmt_ogg
	--union all select patno  from ods_daily.slrsltmt_ogg -- 대용량 미적재
	--union all select patno  from ods_daily.sltrstmt_ogg -- 대용량 미적재
	union all select patno  from ods_daily.smcancht--초기 암환자 등록
	union all select patno  from ods_daily.smddiagt_ogg
	union all select patno  from ods_daily.spacptdt_ogg
	union all select patno  from ods_daily.spacptmt_ogg
	union all select patid  from ods_daily.spbartmt_ogg -- patid 임
	union all select patno  from ods_daily.spcolldt_ogg
	union all select patno  from ods_daily.spcollmt_ogg
	union all select patno  from ods_daily.mmmedort_ogg
	union all select patno  from ods_daily.mmtrtort_ogg
	union all select patno  from ods_daily.mmexmort_ogg
	union all select patno  from ods_daily.mmrehort_ogg
)  t 
group by patno ;