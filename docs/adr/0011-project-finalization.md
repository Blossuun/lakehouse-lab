# ADR-0011: Project Finalization

## Context

프로젝트는 다음을 구현했다.

- data pipeline
- Iceberg storage
- quality validation
- Gold metrics
- dbt analytics
- Trino query
- dashboard
- API

하지만 최종 상태 정의가 필요했다.

---

## Decision

프로젝트를 다음 상태로 종료한다.

- runbook 제공
- end-to-end validation 제공
- README 정리

---

## Consequences

장점:

- 완결된 구조
- 재현 가능한 실행
- 학습 자료로 적합

단점:

- 추가 기능 없음

---

## Final State

이 프로젝트는 다음을 모두 포함한다.

- pipeline
- storage
- validation
- aggregation
- query
- dashboard
- API

---

## Notes

이 ADR을 기준으로 프로젝트는 종료된다.