# Git Workflow

## Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting (no code change) |
| `refactor` | Refactoring (no feature change) |
| `perf` | Performance improvement |
| `test` | Add/update tests |
| `build` | Build system / dependencies |
| `ci` | CI configuration |
| `chore` | Other changes |

### Tidy First

구조적 변경과 동작 변경을 같은 커밋에 혼합 금지:

| 유형 | 설명 | 예시 |
|------|------|------|
| **구조적 변경** | 동작 변경 없이 코드 재배치 | 이름 변경, 메서드 추출, 코드 이동 |
| **동작 변경** | 실제 기능 추가/수정 | 새 기능 구현, 버그 수정 |

둘 다 필요하면 **구조적 변경을 먼저** 커밋하고, 이후 동작 변경을 커밋한다.

## Version Management

release-please 사용 시:
- `feat:` → minor bump (0.x.0)
- `fix:` → patch bump (0.0.x)
- `feat!:` or `BREAKING CHANGE` footer → major bump (x.0.0)
- Do NOT manually change version in package.json
