create sequence if not exists patno_id_seq;
create sequence if not exists visit_occurrence_id_seq;
create sequence if not exists visit_detail_id_seq;
create sequence if not exists condition_id_seq;
create sequence if not exists procedure_occurrence_id_seq;
create sequence if not exists drug_exposure_id_seq;
create sequence if not exists device_exposure_id_seq;
create sequence if not exists measurement_id_seq;
create sequence if not exists note_id_seq;
create sequence if not exists observation_id_seq;
create sequence if not exists specimen_id_seq;
create sequence if not exists observation_period_id_seq;

SELECT setval('observation_period_id_seq', (SELECT MAX(observation_period_id) FROM cdmpv532_daily.observation_period op ));

--select nextval('etl_task_check_grp_id');; -- task 전체를 확인하기 위한 그룹 id 부여

SELECT setval('patno_id_seq', (SELECT MAX(person_id) FROM cdmpv532_daily.PERSON)); --환자번호 채번

SELECT setval('visit_occurrence_id_seq', (SELECT MAX(visit_occurrence_id) FROM cdmpv532_daily.visit_occurrence));
SELECT setval('visit_detail_id_seq', (SELECT MAX(visit_detail_id) FROM cdmpv532_daily.visit_detail));

SELECT setval('condition_id_seq', (SELECT MAX(condition_occurrence_id) FROM cdmpv532_daily.condition_occurrence));
SELECT setval('procedure_occurrence_id_seq', (SELECT MAX(procedure_occurrence_id) FROM cdmpv532_daily.procedure_occurrence));
SELECT setval('drug_exposure_id_seq', (SELECT MAX(drug_exposure_id) FROM cdmpv532_daily.drug_exposure));
SELECT setval('device_exposure_id_seq', (SELECT MAX(device_exposure_id) FROM cdmpv532_daily.device_exposure));

SELECT setval('measurement_id_seq', (SELECT MAX(measurement_id) FROM cdmpv532_daily.measurement));
SELECT setval('observation_id_seq', (SELECT MAX(observation_id ) FROM cdmpv532_daily.observation));

SELECT setval('note_id_seq', (SELECT MAX(note_id) FROM cdmpv532_daily.note));
SELECT setval('specimen_id_seq', (SELECT MAX(specimen_id) FROM cdmpv532_daily.specimen));