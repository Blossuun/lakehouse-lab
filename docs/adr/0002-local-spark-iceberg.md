# ADR 0002 - 로컬 Spark + Iceberg (MinIO 기반) 설계

## 배경
- Raw(JSONL) → Silver(Parquet)까지는 “파일 레벨”
- Lakehouse 경험을 위해 “테이블 레벨(Iceberg)”로 올리는 단계가 필요
- 로컬 재현성을 위해 docker-compose 기반으로 Spark 실행 환경을 제공

## 결정 요약
- Spark 이미지: apache/spark (공식 이미지) 사용
- Iceberg 카탈로그: SparkCatalog + Hadoop catalog
- Warehouse: MinIO(S3a) 경로로 지정 (s3a://datalake/warehouse)
- Iceberg/하둡 AWS JAR은 spark-submit --packages로 주입 (버전 고정)

## 왜 Hadoop catalog인가?
- 로컬에서 가장 단순하며 별도 서비스(JDBC catalog, REST catalog) 없이 시작 가능
- Iceberg 메타데이터는 warehouse 경로 아래에 저장
- 이후 확장(PR #6~)에서 REST catalog 등으로 바꾸기 쉬움

## 설정값 근거 (spark-defaults.conf)

### 1) Iceberg Spark Extensions
- spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions
  - 이유: Spark SQL/DFWriter에서 Iceberg 기능(테이블 생성/쓰기/스냅샷 등)을 활성화

### 2) 카탈로그 정의(local)
- spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog
  - 이유: Spark에 Iceberg 카탈로그를 등록하기 위한 표준 클래스
- spark.sql.catalog.local.type=hadoop
  - 이유: 로컬 최소 구성(메타스토어 서비스 없이 warehouse에 메타데이터 저장)
- spark.sql.catalog.local.warehouse=s3a://datalake/warehouse
  - 이유: MinIO를 Data Lake 저장소로 사용. Iceberg 메타데이터도 동일 저장소에 위치

### 3) S3a (MinIO) 연결
- spark.hadoop.fs.s3a.endpoint=http://minio:9000
  - 이유: docker-compose 네트워크에서 MinIO 컨테이너 접근 주소
- spark.hadoop.fs.s3a.path.style.access=true
  - 이유: MinIO는 path-style이 일반적으로 안정적(virtual-host style 미사용)
- spark.hadoop.fs.s3a.connection.ssl.enabled=false
  - 이유: 로컬 MinIO는 기본적으로 http(비TLS)
- spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.EnvironmentVariableCredentialsProvider
  - 이유: 자격증명을 repo 파일에 하드코딩하지 않고, docker compose env로 주입(보안/재현성)

### 4) 재현성/디버깅
- spark.sql.session.timeZone=UTC
  - 이유: 파티션/시간 파싱의 일관성을 위해 UTC 고정
- (선택) spark.ui.enabled=true
  - 이유: 로컬 디버깅 편의. 필요 없으면 꺼도 됨

## Spark submit 패키지(버전 고정) 근거
- org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:<ICEBERG_VERSION>
  - 이유: Spark 버전에 맞는 Iceberg runtime 번들
- org.apache.hadoop:hadoop-aws:<HADOOP_AWS_VERSION> + com.amazonaws:aws-java-sdk-bundle:<AWS_SDK_BUNDLE_VERSION>
  - 이유: s3a filesystem을 통해 MinIO(S3) 접근에 필요

> 주의: Spark 이미지에 내장된 Hadoop 버전과 hadoop-aws 버전은 맞추는 것이 안전함.
> 로컬 PoC에서는 우선 고정 버전으로 시작하고, 문제 발생 시 Spark의 Hadoop 버전에 맞춰 조정한다.