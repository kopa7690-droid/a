# 📖 상세 사용 가이드 (Detailed Usage Guide)

## 목차

1. [빠른 시작](#빠른-시작)
2. [선택지 포맷 상세](#선택지-포맷-상세)
3. [주사위 판정 상세](#주사위-판정-상세)
4. [버튼 인터랙션](#버튼-인터랙션)
5. [전역 변수 상세](#전역-변수-상세)
6. [트러블슈팅](#트러블슈팅)

---

## 빠른 시작

### 1단계: 로어북 항목 추가

RisuAI의 로어북(World Info)에 아래 항목들을 순서대로 추가합니다:

| 순서 | 파일 | 타입 |
|------|------|------|
| 1 | `lorebook/01_main_prompt.md` | lorebook |
| 2 | `lorebook/02_request_omit_choice.md` | editprocess |
| 3 | `lorebook/03_request_fix_dice.md` | editprocess |
| 4 | `lorebook/04_display_menu.md` | editdisplay |
| 5 | `lorebook/05_output_remove_dice.md` | editoutput |
| 6 | `lorebook/06_display_lazy.md` | editdisplay |

### 2단계: Lua 스크립트 추가

1. RisuAI에서 새 로어북 항목 생성
2. 타입을 `start` / `triggerlua`로 설정
3. `lowLevelAccess = true` 설정
4. `scripts/main.lua` 내용을 붙여넣기

### 3단계: ChoiceModule.actions 항목 추가

1. 새 로어북 항목 생성, 이름: `ChoiceModule.actions`
2. `scripts/actions.lua` 내용을 콘텐츠로 붙여넣기

### 4단계: 전역 변수 초기화

아래 전역 변수를 원하는 값으로 설정합니다 (기본값 예시):

```
toggle_choicemodule_type = 0
toggle_choicemodule_length = 1
toggle_choicemodule_perspective = false
toggle_choicemodule_menu = true
toggle_choicemodule_dice = 0
toggle_choicemodule_hidden = false
toggle_ChoiceModule.mode = false
```

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
          success_probability=70
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

### D100 모드 (`toggle_choicemodule_dice = 0`)

- 1~100 사이의 난수를 굴립니다.
- **성공 확률(success_probability)**: 이 값 이하로 굴리면 성공.

```
 1 ~ 5  : 🌟 Critical Success
 6 ~ 성공확률 : ✅ Success
성공확률+1 ~ 94 : ❌ Failure
95 ~ 100 : 💀 Critical Failure
```

### D20 모드 (`toggle_choicemodule_dice = 1`)

- 1~20 사이의 난수를 굴립니다.
- **난이도(difficulty_class, DC)**: 이 값 이상으로 굴리면 성공.

```
 1     : 💀 Critical Failure
 2 ~ DC-1 : ❌ Failure
DC ~ 19 : ✅ Success
20     : 🌟 Critical Success
```

---

## 버튼 인터랙션

### 🎲 리롤 버튼 (`choicemodule_rr_N`)

주사위 결과 옆 큐브 버튼을 클릭하면 다이얼로그가 열립니다:

| 옵션 | 설명 |
|------|------|
| Cancel | 취소 |
| Reroll | 랜덤 재굴림 |
| Force Success | 성공 범위 내 강제 굴림 |
| Force Critical Success | 최고 결과 강제 |
| Force Failure | 실패 범위 내 강제 굴림 |
| Force Critical Failure | 최악의 결과 강제 |

### ✂️ 선택지 제거 버튼 (`choicemodule_rm_N_M`)

특정 선택지 목록 블록을 채팅에서 제거합니다.

### 📋 메뉴 버튼 (`choicemodule_mn_N`)

선택지 모듈의 전체 메뉴를 엽니다.

### 🔄 합치기 버튼 (`choicemodule_mg`)

OOC 메시지의 선택지를 이전 AI 응답에 병합합니다.

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
