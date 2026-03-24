# 0018. Analysis Dashboard

## 문제

현재까지 프로젝트는 다음을 모두 수행한다.

- 데이터 생성
- Silver 변환
- Iceberg 저장
- 품질 검증
- Gold 집계
- dbt 모델링
- Trino query

하지만 실제 사용자 관점에서는 여전히 부족하다.

- SQL 파일을 직접 실행해야 한다
- 결과를 텍스트로만 확인한다
- 데이터 소비 흐름이 눈에 보이지 않는다

즉, “데이터를 어떻게 쓰는가”가 드러나지 않는다.

---

## 해결

Trino query layer 위에 read-only dashboard를 추가한다.

구성:

- Trino → 데이터 조회
- SQL → 데이터 정의
- Streamlit → UI

즉 구조는 다음과 같다.

pipeline → query → dashboard

---

## 핵심 설계

### 1. read-only

- 데이터 수정 없음
- pipeline 영향 없음
- 조회만 수행

---

### 2. Trino 단일 진입점

- Spark 직접 접근 없음
- 파일 직접 접근 없음
- 모든 조회는 Trino로 통일

---

### 3. Gold + Silver 혼합 사용

- Gold → 요약/집계
- Silver → 상세/탐색

즉 실제 분석 시나리오를 그대로 반영한다.

---

### 4. 캐시 사용

Streamlit `cache_data` 사용

목적:

- 반복 query 감소
- UI 반응성 개선

특성:

- TTL 기반 캐시
- 완전 실시간 아님

---

## 결과

이제 프로젝트는 다음 단계를 모두 포함한다.

- 데이터 생성
- 저장
- 검증
- 집계
- 분석
- 시각화

즉:

pipeline → consumption까지 완성됨

---

## 한계

- production dashboard 아님
- 사용자 인증 없음
- 다중 사용자 고려 없음
- 실시간 시스템 아님

현재는 local read-only baseline으로 유지한다.