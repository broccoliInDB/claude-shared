# Testing

## 테스트 전략

### 테스트 피라미드

```
        /  E2E  \          — 적게, 핵심 플로우만
       /----------\
      / Integration \      — API, DB 연동 검증
     /----------------\
    /    Unit Tests     \   — 많이, 빠르게
```

| 레벨 | 대상 | 비율 |
|------|------|------|
| Unit | 순수 함수, 유틸, hooks | 70% |
| Integration | API 핸들러, DB 쿼리 | 20% |
| E2E | 핵심 사용자 플로우 | 10% |

### 무엇을 테스트하는가
- **테스트한다**: 비즈니스 로직, 데이터 변환, 엣지 케이스, 에러 처리
- **테스트 안 한다**: 프레임워크 내부 동작, 단순 getter/setter, 외부 라이브러리

## 테스트 작성 규칙

### 네이밍
- 파일: `{기능}.test.ts` (소스와 같은 위치 또는 `test/` 폴더)
- 테스트명: "~하면 ~한다" 패턴

```typescript
// ❌ Bad
test('filter test', () => { ... })

// ✅ Good
test('예산 필터 시 해당 범위만 반환한다', () => { ... })
```

### AAA 패턴

```typescript
test('필터가 범위 내 항목만 반환한다', () => {
  // Arrange — 준비
  const items = [{ name: 'A', price: 40000 }, { name: 'B', price: 60000 }]

  // Act — 실행
  const result = filterByBudget(items, { min: 30000, max: 50000 })

  // Assert — 검증
  expect(result).toHaveLength(1)
  expect(result[0].name).toBe('A')
})
```

### 테스트 독립성
- 각 테스트는 독립적으로 실행 가능해야 한다
- 테스트 간 상태 공유 금지
- DB 테스트: 각 테스트 전후로 데이터 정리

## 커버리지

- 새 기능: 핵심 로직 커버리지 필수
- 버그 수정: 재발 방지 테스트 필수
- 커버리지보다 중요한 것: 의미 있는 assertion

## Mocking

- 외부 의존성만 mock (API, DB, 시간)
- 내부 함수는 mock하지 않는다 — 구현에 결합되는 테스트가 됨

## TDD (선택)

프로젝트에서 TDD를 채택한 경우:

```
🔴 Red → 🟢 Green → 🔵 Refactor
```

- 가장 간단한 실패 테스트 작성
- 테스트 통과를 위한 최소한의 코드 구현
- 테스트 통과 후에만 리팩토링
