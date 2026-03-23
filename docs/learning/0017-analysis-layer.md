# 0017. Analysis Layer (Query-first Consumption)

## 왜 필요한가

현재 프로젝트는 다음을 모두 수행한다.

- 데이터 생성
- 정제
- 저장 (Iceberg)
- 품질 검증
- 집계 (Gold)
- 모델링 (dbt)

하지만 실제 사용 관점이 빠져 있다.

즉:

"이 데이터를 어떻게 쓰는가?"

---

## 이번 단계의 목표

- Trino 기반 쿼리로 데이터를 직접 조회
- Gold / Silver / dbt 결과를 실제 분석 형태로 확인
- reproducible query 실행 구조 만들기

---

## 구성

- analytics/queries: SQL 저장
- scripts/query: 실행 스크립트

---

## 중요한 포인트

이 레이어는 다음 역할을 한다.

- smoke test가 아닌 실제 사용 시나리오
- analyst 관점 검증
- BI / dashboard 이전 단계

---

## 결론

이 단계부터 프로젝트는:

"데이터 파이프라인"에서

→ "데이터를 사용하는 시스템"

으로 확장된다.