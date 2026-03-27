# Lakehouse Lab

이 저장소는 로컬 Docker 환경에서 다음을 end-to-end로 구현하는 실습형 프로젝트다.

* 데이터 생성
* Silver 변환
* Iceberg 저장
* 품질 검증
* Gold 집계
* dbt 분석 레이어
* Trino query
* Dashboard
* API

👉 즉, **데이터 파이프라인 → 데이터 소비까지 전체 흐름을 구현**한다.

---

## 🚀 Quick Start (Full System)

아래 두 명령으로 전체 시스템을 실행하고 검증할 수 있다.

* task infra:up
* task validate:all

이 과정에서:

* 전체 pipeline 실행
* query / API 포함 검증

까지 한 번에 수행된다.

---

## 🧭 전체 구조

Raw → Silver → Iceberg → Quality → Gold → dbt → Trino → Dashboard / API

---

## 🐳 Local Infrastructure

* task infra:up

포함 구성:

* Spark
* Trino
* Hive Metastore
* MinIO
* Postgres
* MLflow

---

## ⚙️ Pipeline

* task raw
* task silver
* task iceberg
* task quality
* task gold

---

## 🔍 Query Layer

Trino를 통해 SQL을 실행한다.

예시:

* scripts/query/run_trino_query.ps1 사용
* analytics/queries 디렉토리의 SQL 파일 실행

---

## 📊 분석 대시보드 (Analysis Dashboard)

대시보드를 통해 데이터를 시각적으로 확인할 수 있다.

실행 순서:

1. uv sync --group dashboard
2. scripts/dashboard/run_analysis_dashboard.ps1 실행

대시보드에서 확인 가능한 항목:

* 일별 비즈니스 개요 (Gold)
* 전환 퍼널 (Gold)
* 상위 상품 (Silver)

특징:

* 모든 데이터 조회는 Trino를 통해 수행
* 데이터 수정 없이 조회만 가능한 read-only 구조
* 로컬 Docker / WSL 환경 기준

이 레이어는 “데이터를 만드는 것”이 아니라
**“데이터를 실제로 사용하는 방식”**을 보여준다.

---

## 🔌 API

API를 통해 programmatic access를 제공한다.

실행 순서:

1. uv sync --group api
2. scripts/api/run_api_server.ps1 실행

접속:

* [http://localhost:8000/docs](http://localhost:8000/docs)

제공 기능:

* health check
* Gold metrics 조회

---

## ✅ Full Validation

전체 시스템 검증:

* task validate:all

---

## 📘 Runbook

전체 실행 절차:

* docs/runbook.md 참고

---

## 🎯 Project Goal

이 프로젝트의 목적:

* Spark + Iceberg 기반 데이터 파이프라인 설계
* 품질 검증 및 집계 구조 설계
* Trino 기반 query layer 구성
* Dashboard / API를 통한 소비 계층 구현

👉 즉,

**“데이터를 만드는 시스템”이 아니라
“데이터를 실제로 사용하는 시스템”까지 완성하는 것**

---

## 🧩 Final State

이 프로젝트는 다음을 모두 포함한다.

* pipeline ✔
* storage ✔
* validation ✔
* aggregation ✔
* query ✔
* dashboard ✔
* API ✔

👉 **완결된 lakehouse 시스템**

---

## 📝 Notes

이 저장소는 학습/실습용 프로젝트이며 다음은 범위에 포함하지 않는다.

* production deployment
* authentication
* multi-user system

---

## 📌 Status

👉 **Finalized**

이 상태를 기준으로 프로젝트는 종료한다.
