# Gold Metrics 계약서

이 문서는 Gold 레이어의 주요 지표 테이블을 정의한다.

원본:
- `local.lakehouse.silver_events`

생성 대상:
- `local.gold.daily_event_metrics`
- `local.gold.daily_revenue_metrics`
- `local.gold.daily_conversion_metrics`

---

## 1. daily_event_metrics

일별 이벤트 집계 테이블

### 컬럼
- `dt` : 날짜
- `total_events` : 전체 이벤트 수
- `view_events` : view 이벤트 수
- `search_events` : search 이벤트 수
- `add_to_cart_events` : add_to_cart 이벤트 수
- `purchase_events` : purchase 이벤트 수
- `refund_events` : refund 이벤트 수

---

## 2. daily_revenue_metrics

일별 매출 집계 테이블

### 컬럼
- `dt` : 날짜
- `gross_revenue` : 총 매출 합계
- `refund_amount` : 총 환불 금액 합계
- `net_revenue` : 순매출 (`gross_revenue - refund_amount`)

---

## 3. daily_conversion_metrics

일별 전환 관련 지표 테이블

### 컬럼
- `dt` : 날짜
- `view_events` : view 이벤트 수
- `add_to_cart_events` : add_to_cart 이벤트 수
- `purchase_events` : purchase 이벤트 수
- `view_to_cart_rate` : add_to_cart / view
- `cart_to_purchase_rate` : purchase / add_to_cart
- `view_to_purchase_rate` : purchase / view