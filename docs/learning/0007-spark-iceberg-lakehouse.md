# 0007 - Spark + Iceberg로 Silver(파일)를 Lakehouse(테이블)로 올리기

## 배경

Silver(Parquet)는 “파일 레벨” 데이터입니다.
Lakehouse의 핵심은 “테이블 레벨”로 관리하는 것입니다.

Iceberg를 도입하면:
- 스키마/파티션/스냅샷 같은 메타데이터를 테이블이 관리하고
- 엔진(Spark 등)은 그 테이블을 읽고 쓰는 방식으로 운영할 수 있습니다.

## 이번 PR에서 한 일

- Spark가 MinIO(S3a)에서 Silver Parquet을 읽음
- Iceberg 테이블로 적재
- `dt` 파티션으로 overwrite(재실행 안정성) 시나리오 확보
- PowerShell 스모크 스크립트로 재현 가능한 실행 루프 제공

## 이번에 가졌던 궁금증과 해소

### Q1. 왜 스모크 스크립트를 .ps1로 만들었나?

Windows 환경에서 `docker exec` + `spark-submit` 조합을
가장 낮은 마찰로 재현하기 위해 PowerShell 스크립트를 사용했습니다.

- Windows 기본 셸로 동작
- 인자 전달/줄바꿈 처리 안정적
- 팀 온보딩 시 가장 단순한 실행 경로 제공

### Q2. 스모크 실행 로그와 결과는 어떻게 확인하나?

- 기본: PowerShell 콘솔 출력에 spark-submit 로그/결과가 그대로 표시됨
- (선택) 실행 중 Spark UI 확인: http://localhost:4040
- 가장 확실한 성공 기준: Iceberg 테이블이 생성되고 row count가 출력되는지

## 설정값 선택 이유

Spark/Iceberg/MinIO 관련 설정 값의 선택 근거는 ADR에 정리했습니다.

- `docs/adr/0002-local-spark-iceberg.md`

## 내가 느낀 차이

- Parquet 파일: 읽는 쪽이 스키마/정합성을 직접 책임지는 부분이 큼
- Iceberg 테이블: 스키마/스냅샷/파티션을 “테이블 메타데이터”가 책임

