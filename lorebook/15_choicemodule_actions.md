# ChoiceModule.actions — 선택지 액션 스크립트 (로어북 Lua)

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `ChoiceModule.actions` |
| **type** | `lorebook` (Lua 스크립트, 로어북 항목으로 저장) |

---

## 콘텐츠 (Content)

이 항목의 콘텐츠는 `scripts/actions.lua` 파일의 전체 내용입니다.

RisuAI에서 이 파일의 내용을 `ChoiceModule.actions`라는 이름의 **로어북 항목**에 넣어야 합니다.

---

## 설명

이 파일은 선택지 모듈의 핵심 액션 로직을 담은 Lua 스크립트입니다.

### 실행 구조

1. `scripts/main.lua`가 RisuAI 트리거 스크립트로 실행됩니다.
2. 버튼 클릭 시 `main.lua`가 `getLoreBooks(t, 'ChoiceModule.actions')`로 이 로어북 항목을 로드합니다.
3. 로드 시 `@` 문자가 `-`로 치환됩니다 (난독화 해제):
   - `@@` → `--` (Lua 주석)
   - `@1` → `-1` (음수)
   - `.@` → `.-` (Lua 비탐욕 패턴)
4. 치환된 코드가 `load()`로 실행됩니다.

### ⚠️ 중요: main.lua에 합치면 안 됩니다!

`actions.lua`를 `main.lua` 트리거 스크립트에 직접 합치면 `@` 난독화 치환이 적용되지 않아 `unexpected symbol near '@'` 에러가 발생합니다. 반드시 **로어북 항목**으로 분리해서 넣어야 합니다.

### 포함 기능

- **6단계 판정 시스템** (Critical Failure ~ Critical Success)
- **보조 보너스 시스템** (ASSIST_BONUS)
- **궁극기 시스템** (Ultimate gauge, Phase 3)
- **연속 실패 보정** (Pity System, Phase 5)
- **파티원 보조 시스템** (Ally assist, Phase 4)
- **AI 자동 판단** (Auto-judgment, tension-based DC mod)
- **주사위 굴림 함수** (`dr()` — D20 기반)
- **액션 핸들러**: op (선택), mn (메뉴), mg (합치기), rr (리롤), rm (삭제)
