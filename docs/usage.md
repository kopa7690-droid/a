# 📖 상세 사용 가이드 (Detailed Usage Guide)

## 목차

1. [빠른 시작](#빠른-시작)
2. [LightBoard 모드](#lightboard-모드)
3. [선택지 포맷 상세](#선택지-포맷-상세)
4. [주사위 판정 상세](#주사위-판정-상세)
5. [버튼 인터랙션](#버튼-인터랙션)
6. [전역 변수 상세](#전역-변수-상세)
7. [트러블슈팅](#트러블슈팅)

---

## 빠른 시작

### 1단계: 로어북 항목 추가

RisuAI의 로어북(World Info)에 아래 항목들을 순서대로 추가합니다:

| 순서 | 파일 | 항목명 | 타입 |
|------|------|--------|------|
| 1 | `lorebook/01_main_prompt.md` | `⚖️ Choice Module: Capsule Extension 💊` | lorebook |
| 2 | — | `---` | (구분선) |
| 3 | `lorebook/07_manifest_lb.md` | `manifest.lb` | lorebook |
| 4 | `lorebook/08_choicemodule_lb.md` | `ChoiceModule.lb` | lorebook |
| 5 | `lorebook/09_choicemodule_lb_job.md` | `ChoiceModule.lb.job` | lorebook |
| 6 | `lorebook/10_choicemodule_lb_format.md` | `ChoiceModule.lb.format` | lorebook |
| 7 | `lorebook/11_choicemodule_lb_thoughts.md` | `ChoiceModule.lb.thoughts` | lorebook |
| 8 | `lorebook/12_choicemodule_lb_onoutput.md` | `ChoiceModule.lb.onOutput` | lorebook |
| 9 | `lorebook/13_choicemodule_lb_interaction.md` | `ChoiceModule.lb.interaction` | lorebook |
| 10 | `lorebook/14_choicemodule_lb_thoughts_interaction.md` | `ChoiceModule.lb.thoughts-interaction` | lorebook |
| 11 | `scripts/actions.lua` 내용 | `ChoiceModule.actions` | lorebook |
| 12 | `lorebook/02_request_omit_choice.md` | `🗑️ Request: Omit Choice` | editprocess |
| 13 | `lorebook/03_request_fix_dice.md` | `🗑️ Request: Fix Dice` | editprocess |
| 14 | `lorebook/04_display_menu.md` | `🖥️ Display: Menu` | editdisplay |
| 15 | `lorebook/05_output_remove_dice.md` | `🖨️ Output: Remove Dice` | editoutput |
| 16 | `lorebook/06_display_lazy.md` | `🖥️ Display: Lazy` | editdisplay |

### 2단계: Lua 스크립트 추가

1. RisuAI에서 새 로어북 항목 생성
2. 타입을 `start` / `triggerlua`로 설정
3. `lowLevelAccess = true` 설정
4. `scripts/main.lua` 내용을 붙여넣기

### 3단계: ChoiceModule.actions 항목 추가

1. 새 로어북 항목 생성, 이름: `ChoiceModule.actions`
2. `scripts/actions.lua` 내용을 콘텐츠로 붙여넣기

> **참고**: `scripts/actions.lua`는 `@`를 난독화 문자로 사용합니다. 파일 내용을 그대로 복사하면 됩니다. `@`는 런타임에 `-`로 자동 치환됩니다.

### 4단계: 전역 변수 초기화

아래 전역 변수를 원하는 값으로 설정합니다 (기본값 예시):

```
toggle_choicemodule_length = 1
toggle_choicemodule_perspective = false
toggle_choicemodule_menu = true
toggle_choicemodule_hidden = false
toggle_choicemodule_diversity = false
toggle_choicemodule_proactivity = false
toggle_ChoiceModule.mode = false
toggle_ChoiceModule.korean = false
toggle_ChoiceModule.noLorebook = 0
toggle_lightboard.thoughts = 3
toggle_choicemodule_ally_name = 파티원  # Ally character name shown in OOC messages
```

---

## LightBoard 모드

LightBoard 모드는 선택지 생성을 메인 AI 응답과 분리하여 **별도의 독립된 AI 호출**로 처리하는 고급 모드입니다.

### 작동 방식

1. 메인 AI 응답이 완료된 후 `<lb-lazy>` 태그가 삽입됩니다.
2. **"⚖️ 선택지 불러오기"** 버튼이 표시됩니다.
3. 버튼 클릭 시 LightBoard가 `manifest.lb`에 정의된 컨텍스트를 사용해 선택지를 별도 생성합니다.
4. 생성된 선택지는 `ChoiceModule.lb.onOutput`에 의해 후처리되어 채팅에 삽입됩니다.

### LightBoard 관련 로어북 항목

| 항목 | 역할 |
|------|------|
| `manifest.lb` | 컨텍스트 범위 정의 (`authorsNote`, `charDesc`, `loreBooks`, `personaDesc`) |
| `ChoiceModule.lb` | 태스크 지시문 (선택지 생성 방법) |
| `ChoiceModule.lb.job` | 작업 설명 (창작 자료 기반) |
| `ChoiceModule.lb.format` | XML 출력 형식 (`<lb-choice>...</lb-choice>`) |
| `ChoiceModule.lb.thoughts` | 단계별 추론 유도 |
| `ChoiceModule.lb.onOutput` | 출력 ID 타임스탬프 처리 |
| `ChoiceModule.lb.interaction` | 유저 특정 요청 반영 |
| `ChoiceModule.lb.thoughts-interaction` | 인터랙션 시 단계별 추론 |

### 관련 전역 변수

| 변수명 | 설명 |
|--------|------|
| `toggle_ChoiceModule.noLorebook` | `1`로 설정하면 LightBoard 호출 시 로어북 제외 |
| `toggle_lightboard.thoughts` | 3 미만이면 각 사고 단계를 8단어 이하로 제한 |

---

## 선택지 포맷 상세

AI가 응답 끝에 출력해야 하는 XML 형식입니다.

### 기본 형식

```xml
<ChoiceModule>
  <Suggestion id="1">선택지 내용 1</Suggestion>
  <Suggestion id="2">선택지 내용 2</Suggestion>
  <Suggestion id="3">선택지 내용 3</Suggestion>
</ChoiceModule>
```

### 주사위 판정 포함

```xml
<ChoiceModule>
  <Suggestion id="1">
    <Check for="전투 행동 설명"
          comment="이 행동의 성공 확률"
          difficulty_class=12 />
    적에게 검을 휘두른다.
  </Suggestion>
</ChoiceModule>
```

### 풍경(Scene) 포함

```xml
<Suggestion id="1">
  <Scene seed="달빛이 비치는 숲">
    깊은 숲 속, 달빛이 나뭇잎 사이로 스며든다.
  </Scene>
</Suggestion>
```

### 말풍선(Bubble) 설명 포함

```xml
<Suggestion id="1">
  <Bubble>이 선택지를 고르면 퀘스트가 시작됩니다</Bubble>
  마을 장로에게 말을 건다.
</Suggestion>
```

---

## 주사위 판정 상세

### D20 모드 (6단계 판정)

- 1~20 사이의 난수를 굴립니다.
- **난이도(difficulty_class, DC)**: 판정 기준값 (기본값 10)

```
20       : 🌟 Critical Success
DC+3~19  : ✅ Success
DC~DC+2  : 🔼 Narrow Success   → OOC: "(OOC: 근소한 성공입니다. 아슬아슬하게 성공하는 결과를 묘사하세요.)"
DC-3~DC-1: 🔽 Narrow Failure   → OOC: "(OOC: 근소한 실패입니다. 아쉽게 실패했지만 완전한 실패는 아닌 결과를 묘사하세요.)"
2~DC-4   : ❌ Failure
1        : 💀 Critical Failure
```

> Narrow Success / Narrow Failure 결과 시 AI에게 근소한 결과임을 안내하는 OOC 메시지가 유저 메시지에 자동 추가됩니다.

---

## 버튼 인터랙션

### 🎲 리롤 버튼 (`choicemodule_rr_N`)

주사위 결과 옆 큐브 버튼을 클릭하면 다이얼로그가 열립니다:

| 옵션 | 설명 |
|------|------|
| Cancel | 취소 |
| Reroll | 랜덤 재굴림 |
| Force Success | Success 범위 내 강제 굴림 (DC+3~19) |
| Force Critical Success | 최고 결과 강제 (20) |
| Force Narrow Success | Narrow Success 범위 내 강제 굴림 (DC~DC+2) |
| Force Narrow Failure | Narrow Failure 범위 내 강제 굴림 (DC-3~DC-1) |
| Force Failure | Failure 범위 내 강제 굴림 (2~DC-4) |
| Force Critical Failure | 최악의 결과 강제 (1) |

### ✂️ 선택지 제거 버튼 (`choicemodule_rm_N_M`)

특정 선택지 목록 블록을 채팅에서 제거합니다.

### 📋 메뉴 버튼 (`choicemodule_mn_N`)

선택지 모듈의 전체 메뉴를 엽니다. 아래 4가지 옵션을 제공합니다:

| 옵션 | 설명 |
|------|------|
| 취소 | 아무 작업도 하지 않고 닫기 |
| 선택지 재생성 | OOC 메시지를 삽입하여 선택지만 재생성 |
| 선택지 요청 + 재생성 | 특정 선택지를 포함한 재생성 (입력창 표시) |
| 선택지 삭제 | 현재 메시지의 `<Choice>` 블록 제거 |

### 🔄 합치기 버튼 (`choicemodule_mg`)

OOC 메시지로 생성된 선택지를 **이전 AI 응답에 병합**합니다.

작동 원리:
1. 현재(마지막) 메시지에서 `<Choice>` 블록을 추출합니다.
2. 현재보다 2번 앞의 AI 응답 메시지를 찾습니다.
3. 해당 메시지에 이미 `<Choice>` 블록이 있으면 교체하고, 없으면 뒤에 추가합니다.
4. OOC 선택지 요청 메시지를 제거합니다.
5. 채팅 목록이 짧은 경우(2개 이하) 첫 번째 메시지에 직접 삽입합니다.

---

## 전역 변수 상세

### `toggle_choicemodule_length`

| 값 | 선택지 텍스트 길이 |
|----|------------------|
| 0 | 최대 (Full + detailed) |
| 1 | 일반 (Full) |
| 2 | 짧게 |
| 3 | 간결 (Concise) |
| 4 | 한 줄 설명 |

### `toggle_choicemodule_hidden`

주사위 결과 숨김:
- `false` (0): 결과 표시
- `true` (1): 과거 메시지의 결과를 `[ ? ]`로 숨김

### `toggle_choicemodule_diversity`

- `false` (0): 기본 동작
- `true` (1): 반복적인 선택지를 피하고 다양성 있는 옵션 생성 지시

### `toggle_choicemodule_proactivity`

- `false` (0): 기본 동작
- `true` (1): 현상 유지가 아닌 진행을 위한 능동적인 제안 생성 지시

### `toggle_ChoiceModule.korean`

- `false` (0): 기본 언어 사용
- `true` (1): 텍스트 노드와 속성값을 한국어로 작성 요청

### `toggle_ChoiceModule.noLorebook`

- `0` (기본): LightBoard 호출 시 로어북 포함
- `1`: LightBoard 호출 시 로어북 제외

### `toggle_lightboard.thoughts`

- `3 이상` (기본): 단계별 사고 제한 없음
- `3 미만`: 각 사고 단계를 8단어 이하로 제한 (간결한 추론)

### `toggle_choicemodule_ally_name`

보조 판정 OOC 메시지에 표시될 캐릭터 이름입니다.

- 기본값: `"파티원"`
- 예: `엘리아`, `레나` 등 원하는 이름으로 설정

---

## 🔥 궁극기 시스템 (Ultimate System)

> 항상 활성화됩니다 (별도 토글 불필요).

### 개요

D&D 6대 스탯(STR/DEX/CON/INT/WIS/CHA)별로 독립적인 **게이지(0–5)**를 충전하여,  
FULL(5/5) 상태에서 해당 스탯 선택지를 선택하면 **무조건 대성공(Critical Success)**을 발동합니다.

### 게이지 충전 규칙

| 상황 | 충전 |
|------|------|
| 해당 스탯 선택지 선택 (어떤 결과든) | +1 |
| 선택 결과 Critical Failure | +2 (크리 실패 패널티 보상) |
| stat 없는 구형 선택지 | 충전 없음 |

### 궁극기 발동 조건

1. 해당 스탯 게이지가 **5/5 (FULL)**
2. 위 조건의 스탯이 할당된 선택지 클릭

### 발동 효과

- 실제 주사위를 굴리지 않고 `rolled = 20`, `outcome = "Critical Success"` 고정
- 게이지를 **0으로 리셋**
- 유저 메시지에 다음 OOC 지시문 자동 추가:

```
* OOC: {{user}}의 🪓 STR 궁극기가 발동됩니다! 무조건 대성공입니다. STR 능력이 극한까지 발휘되는 극적인 장면을 연출하세요.
```

### 예시 흐름

```
[1턴] STR 선택지 선택 → Critical Failure → 게이지 STR: 0→2
[2턴] STR 선택지 선택 → Narrow Failure  → 게이지 STR: 2→3
[3턴] STR 선택지 선택 → Success         → 게이지 STR: 3→4
[4턴] STR 선택지 선택 → Failure         → 게이지 STR: 4→5 (FULL)
[5턴] STR 선택지 선택 → 🔥 궁극기 발동! outcome=Critical Success, 게이지 STR: 5→0
```

### UI 표시

선택지 블록 하단에 각 스탯의 게이지가 표시됩니다:

```
🪓 STR [███░░] 3/5  🏃 DEX [█░░░░] 1/5  🛡️ CON [████░] 4/5
🧠 INT [░░░░░] 0/5  👁️ WIS [██░░░] 2/5  💬 CHA [█████] 5/5
```

FULL 게이지 스탯: `🔥 CHA [█████] 5/5` (🔥 이모지로 표시)  
FULL 게이지 버튼: CSS 클래스 `choicemodule-ult-ready` 추가 (BETA — 별도 CSS 테마에서 glow 효과 구현)

---

## 🤝 보조 판정 시스템 (Ally Assist System)

> 항상 활성화됩니다 (별도 토글 불필요).

### 개요

파티원이 **실패 결과를 보조**하여 유저의 outcome을 상향 조정하는 협동 판정 시스템입니다.  
유저 결과가 실패 계열(Critical Failure / Failure / Narrow Failure)일 때 파티원이 같은 DC로 **보조 주사위**를 굴립니다.

### 보조 발동 조건

- 유저의 outcome이 **Narrow Failure / Failure / Critical Failure** (레벨 0–2)
- 보조 주사위가 자동으로 굴려지며, Narrow Success 이상 시 결과가 상향 조정됨

### 업그레이드 규칙

| 보조 결과 | 업그레이드 | 예시 (유저 Failure → 최종) |
|-----------|-----------|---------------------------|
| 🔼 Narrow Success | +1 단계 | Failure → Narrow Failure |
| ✅ Success | +2 단계 | Failure → Narrow Success |
| 🌟 Critical Success | +3 단계 | Failure → Success |
| Failure 계열 | 변화 없음 | (보조 결과 출력 없음) |

### OOC 자동 삽입

보조 성공(outcome 변화)이 발생하면 유저 메시지에 자동으로 OOC가 추가됩니다:

```
* (OOC: '엘리아'가 {{user}}의 실패를 보조하여 Narrow Failure로 상쇄시킵니다. 유저의 행동을 서포트하는 묘사를 포함하세요.)
```

보조 주사위가 실패 계열이면 아무 출력도 추가되지 않습니다.

### 예시 흐름

```
[판정 시작] 유저 STR 선택지 → rolled=5, DC=12 → Failure
  ↳ [보조 발동]  파티원 보조 주사위 → rolled=14, DC=12 → Narrow Success (+1)
  ↳ [최종 결과] Failure(1) + 1 = Narrow Failure(2)
  ↳ [OOC 추가] "(OOC: '엘리아'가 {{user}}의 실패를 보조하여 Narrow Failure로 상쇄시킵니다.)"

[판정 시작] 유저 DEX 선택지 → rolled=3, DC=12 → Critical Failure
  ↳ [보조 발동]  파티원 보조 주사위 → rolled=17, DC=12 → Success (+2)
  ↳ [최종 결과] Critical Failure(0) + 2 = Narrow Failure(2)
```

### UI 표시

주사위 결과 테이블 아래 (결과 미숨김 모드에서만 표시):

```
🤝 보조: [ 14 ] → Narrow Success ｜ 최종: [ Narrow Failure ]
```

`Outcome` 셀에는 항상 최종 outcome(보조 적용 후)이 표시됩니다.

### 궁극기와의 관계

| 상황 | 동작 |
|------|------|
| 궁극기 발동 시 | 보조 판정 완전히 스킵 (궁극기 우선) |
| 보조 성공 시 궁극기 게이지 | **충전 없음** (보조 결과는 게이지에 영향 없음) |

### 설정 변수

| 변수명 | 타입 | 기본값 | 설명 |
|--------|------|--------|------|
| `toggle_choicemodule_ally_name` | string | "파티원" | OOC에 표시될 보조 캐릭터 이름 |

---

## 🛡️ 연속 실패 보정 시스템 (Pity System) — Phase 5

### 개요

유저가 **연속으로 실패**할 때 다음 판정 확률을 보정하는 자동 시스템입니다.  
Failure / Critical Failure / Narrow Failure가 3회 이상 연속 발생하면 **다음 판정 롤에 +1~+5 보정**이 자동으로 추가됩니다.

### failStreak 카운터

| 결과 | failStreak 변화 |
|------|----------------|
| Critical Success | 0으로 리셋 |
| Success | 0으로 리셋 |
| Narrow Success | 변화 없음 |
| Narrow Failure | +1 증가 |
| Failure | +1 증가 |
| Critical Failure | +1 증가 |

- 카운터는 chatVar `ChoiceModule.failStreak`에 저장됩니다.
- 알리 보조(Ally Assist)가 적용된 경우 **최종 outcome** 기준으로 카운터를 갱신합니다.
- 궁극기가 발동된 경우 Pity 보정은 건너뜁니다 (궁극기 우선).

### 보정 적용 예시

```
[1턴] STR 선택지 → rolled=3 → Critical Failure → failStreak: 0→1
[2턴] DEX 선택지 → rolled=5 → Failure          → failStreak: 1→2
[3턴] INT 선택지 → rolled=6 → Failure          → failStreak: 2→3
[4턴] WIS 선택지 → Pity 발동! pity_bonus=3 → rolled=9+3=12 → Narrow Success → failStreak: 3 (변화 없음)
[5턴] CON 선택지 → Pity 발동! pity_bonus=2 → rolled=13+2=15 → Success → failStreak: 3→0
```

### OOC 자동 안내

보정이 적용된 경우 유저 메시지에 아래 OOC가 자동 추가됩니다:

```
* (OOC: 연속된 실패로, 이번 판정엔 +3 보정이 적용되었습니다.)
```

보정값은 1~5 랜덤으로 결정되며, 실제 적용된 값이 표시됩니다.

---

## 트러블슈팅

### Q: 선택지가 표시되지 않아요.

- `toggle_ChoiceModule.mode` 가 `true`로 설정되어 있지 않은지 확인하세요.
- 로어북 항목의 활성화 여부를 확인하세요.

### Q: 주사위 버튼이 작동하지 않아요.

- Lua 스크립트(`scripts/main.lua`)가 올바르게 설치되었는지 확인하세요.
- `ChoiceModule.actions` 로어북 항목이 존재하는지 확인하세요.
- RisuAI의 `lowLevelAccess` 가 활성화되어 있는지 확인하세요.

### Q: 리롤 후 결과가 저장되지 않아요.

- `getChat` / `setChat` API 접근 권한을 확인하세요.
- 로어북 항목 타입이 `start` 인지 확인하세요.

---

© 2025 [arca.live/b/characterai](https://arca.live/b/characterai)
