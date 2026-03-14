# 0011 - Shared Iceberg Catalog (Spark + Trino)

## 배경

기존 프로젝트는 Spark를 중심으로 Iceberg를 사용했다.

구조는 다음과 같았다.

```text
Spark
  -> Iceberg (SparkCatalog, type=hadoop)
  -> MinIO
```

이 구조는 Spark 단독으로는 잘 동작했다.
하지만 Trino나 dbt 같은 다른 엔진을 붙여 같은 Iceberg 테이블을 읽으려면
공유 가능한 catalog가 필요했다.

---

## 문제

기존 Spark의 Hadoop catalog는
Spark 단독 사용에는 편하지만,
다른 query engine이 바로 공유해서 읽기엔 적합하지 않았다.

즉:

- Spark는 write 가능
- Trino는 같은 Iceberg를 바로 read 하기 어려움

이 문제가 있었다.

---

## 해결

이번 단계에서는 Iceberg catalog를
Hive Metastore 기반 shared catalog로 전환했다.

구조는 다음처럼 바뀌었다.

```text
Spark  -> write
Trino  -> read
HMS    -> shared Iceberg catalog
MinIO  -> object storage
```

---

## 이번 단계에서 한 일

1. Hive Metastore 추가
2. Postgres에 metastore DB 준비
3. Spark catalog를 `type=hive`로 전환
4. Trino Iceberg catalog를 Hive Metastore에 연결
5. Spark write / Trino read smoke 성공

---

## 구현 과정에서 겪은 문제

### 1. Spark `spark-sql`로는 Iceberg classpath가 부족했다

직접 `spark-sql`을 실행했을 때:

- `IcebergSparkSessionExtensions`
- `SparkCatalog`

클래스를 찾지 못했다.

원인:
- `spark-sql` 실행 시 Iceberg runtime jar가 classpath에 자동으로 올라오지 않았기 때문

해결:
- interactive `spark-sql` 대신
- `spark-submit --packages ...` 기반의 작은 smoke job 사용

배운 점:
- 로컬 PoC에서 `spark-sql`은 classpath/Hive/Derby 문제를 자주 일으킨다
- 반복 가능한 smoke/test는 `spark-submit` job이 더 안정적이다

---

### 2. Hive Metastore는 S3A를 못찾았다.

초기에는 Hive Metastore에서 다음 오류가 발생했다.

```text
Class org.apache.hadoop.fs.s3a.S3AFileSystem not found
```

원인:
- Spark는 `hadoop-aws`를 `--packages`로 받아 S3A를 알지만
- Hive Metastore 컨테이너는 해당 jar가 없어서 `s3a://...` warehouse를 처리할 수 없었다

해결:
- Hive 컨테이너에 `hadoop-aws` 와 `aws-java-sdk-bundle` 추가
- `core-site.xml`에 S3A 설정 추가

배운 점:
- shared catalog 구조에서는 Spark만 S3를 이해하면 충분하지 않다
- catalog backend(HMS)도 같은 storage access 경로를 이해해야 한다

---

### 3. Trino는 shared catalog가 준비된 뒤에만 붙일 수 있다

처음에는 `dbt-spark(thrift)`를 시도했지만,
Spark thrift 조합에서 내부 클래스 호환 문제가 발생했다.

그래서 최종 방향은 다음처럼 정리했다.

```text
1. shared Iceberg catalog 확보
2. Spark write / Trino read 성공
3. 그 다음 dbt-trino
```

이 순서가 맞았다.

### Hive dependency 캐시는 컨테이너 안이 아니라 호스트에서 준비하는 편이 더 안정적이었다

처음에는 Hive Metastore 컨테이너 시작 시점에
`curl`로 필요한 JAR를 다운로드하도록 구성하려 했다.

하지만 실제로는 두 가지 문제가 있었다.

1. Hive 이미지의 기본 entrypoint 흐름과 충돌할 수 있었다
2. `apache/hive:4.0.0` 이미지에는 `curl`이 기본 포함되어 있지 않았다

그래서 최종적으로는 방식을 바꿨다.

- 호스트 PowerShell 스크립트가 `infra/hive/cache/`에 JAR를 준비
- 파일이 이미 있으면 재다운로드하지 않음
- Docker는 해당 디렉터리를 컨테이너에 마운트만 함

이 방식의 장점:
- 컨테이너 이미지 내부 도구(`curl` 등)에 의존하지 않음
- `docker compose down` / `up`를 반복해도 호스트 캐시가 유지됨
- 리포에 큰 바이너리를 커밋하지 않아도 됨

배운 점:
- 캐시가 필요한 의존성은 “컨테이너 안에서 즉석 다운로드”보다
  “호스트에서 준비하고 마운트”하는 방식이 더 단순하고 예측 가능할 때가 많다

---

## 왜 DuckDB를 이번 단계의 주 경로로 선택하지 않았는가

DuckDB는 dbt와 잘 맞고 로컬 분석 엔진으로 훌륭하다.
하지만 이번 프로젝트의 중심은 다음 구조다.

```text
Spark + MinIO + Iceberg + shared catalog
```

즉 목표는 단순한 로컬 분석이 아니라,
여러 엔진이 같은 lakehouse를 공유하는 구조를 만드는 것이다.

DuckDB는 이 목표에서 보조 엔진으로는 좋지만,
이번 단계의 핵심인 shared catalog / service-style query layer 역할에는
Trino가 더 적합하다고 판단했다.

---

## 이번 단계의 의미

이제 프로젝트 구조는 다음과 같다.

```text
Raw ingestion
-> Silver transform
-> Iceberg table
-> Iceberg ops
-> Data quality gate
-> Gold metrics
-> Shared Iceberg catalog
```

이 단계가 끝나면서 프로젝트는
단순 Spark 중심 파이프라인이 아니라,
lakehouse 위에 여러 엔진을 붙일 수 있는 구조로 발전했다.

다음 단계는 자연스럽게:

```text
Trino + dbt-trino
```

로 이어진다.