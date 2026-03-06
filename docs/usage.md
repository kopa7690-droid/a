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
toggle_choicemodule_type = 0
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
          comment="이 행동의 성공 가능성"
          difficulty_class=12
          dice_outcome="공격 성공 여부"/>
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

### D20 모드

- 1~20 사이의 난수를 굴립니다.
- **난이도(difficulty_class, DC)**: DC를 기준으로 6단계 판정을 수행합니다.

```
20      : 🌟 Critical Success
DC+3~19 : ✅ Success
DC~DC+2 : ↗️ Narrow Success
DC-3~DC-1 : ↘️ Narrow Failure
2~DC-4  : ❌ Failure
1       : 💀 Critical Failure
```

Narrow 구간의 폭은 3으로 고정됩니다. DC가 극단값일 때는 자연스럽게 범위가 좁아지거나 겹칠 수 있으며, Critical은 항상 1과 20으로 고정됩니다.

---

## 버튼 인터랙션

### 🎲 리롤 버튼 (`choicemodule_rr_N`)

주사위 결과 옆 큐브 버튼을 클릭하면 다이얼로그가 열립니다:

| 옵션 | 설명 |
|------|------|
| Cancel | 취소 |
| Reroll | 랜덤 재굴림 |
| Force Success | 성공(DC+3~19) 범위 내 강제 굴림 |
| Force Narrow Success | 협소 성공(DC~DC+2) 범위 내 강제 굴림 |
| Force Narrow Failure | 협소 실패(DC-3~DC-1) 범위 내 강제 굴림 |
| Force Failure | 실패(2~DC-4) 범위 내 강제 굴림 |
| Force Critical Success | 최고 결과 강제 (20) |
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

### `toggle_choicemodule_type`

| 값 | 설명 |
|----|------|
| 0 | 기본 선택지 형식 |
| 1~3 | 변형 선택지 형식 |
| 4 | 선택지 비활성화 |

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

---

## 트러블슈팅

### Q: 선택지가 표시되지 않아요.

- `toggle_ChoiceModule.mode` 가 `true`로 설정되어 있지 않은지 확인하세요.
- `toggle_choicemodule_type` 이 4 미만인지 확인하세요.
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
