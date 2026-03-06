# ⚖️ Choice Module: Capsule Extension 💊

> **SillyTavern / RisuAI용 D&D 스타일 선택지 모듈**  
> A D&D-style choice & dice module for SillyTavern / RisuAI AI chat applications.

---

## 📖 소개 (About)

**Choice Module: Capsule Extension**은 AI 채팅(SillyTavern, RisuAI 등)에서  
D&D/TRPG 스타일의 **선택지 목록**과 **주사위 굴림**을 자동으로 제공하는 로어북(Lorebook) 모듈입니다.

매 AI 응답 끝에 다음 행동을 위한 선택지를 자동으로 생성하고,  
선택지 선택 시 확률·난이도 기반 주사위 판정을 수행합니다.

**This module automatically generates a list of next-action choices at the end of every AI response,  
and performs probability/difficulty-based dice checks when a choice is selected.**

---

## ✨ 주요 기능 (Features)

| 기능 | 설명 |
|------|------|
| 🎯 자동 선택지 생성 | AI 응답마다 1~5개의 다음 행동 선택지를 자동으로 제시 |
| 🎲 주사위 판정 | D100(백분율) 또는 D20 방식 지원, 성공/실패/크리티컬 결정 |
| 🔄 리롤 | 주사위 결과 재굴림 및 강제 성공/실패 옵션 |
| 📋 선택지 병합 | 이전 응답에 선택지 결과를 병합하는 기능 |
| 🦥 지연 로딩 | 선택지를 필요할 때만 불러오는 Lazy Load 지원 |
| 🗑️ 선택지 제거 | 불필요한 선택지를 숨기거나 제거 |
| 🌐 NPC 관점 | 유저 또는 NPC 관점의 선택지 생성 지원 |

---

## 📁 프로젝트 구조 (Project Structure)

```
📦 choice-module-capsule-extension
├── 📄 README.md                    # 이 문서
├── 📂 lorebook/                    # 로어북 항목들
│   ├── 01_main_prompt.md           # 메인 시스템 프롬프트 (Choice Module 지시문)
│   ├── 02_request_omit_choice.md   # 선택지 제거 규칙
│   ├── 03_request_fix_dice.md      # 주사위 수정 규칙
│   ├── 04_display_menu.md          # 메뉴 표시 규칙
│   ├── 05_output_remove_dice.md    # 주사위 출력 제거 규칙
│   └── 06_display_lazy.md          # 지연 로딩 표시 규칙
├── 📂 scripts/
│   └── main.lua                    # 메인 Lua 트리거 스크립트
└── 📂 docs/
    └── usage.md                    # 상세 사용법 가이드
```

---

## 🚀 설치 방법 (Installation)

### RisuAI

1. 이 저장소를 다운로드합니다.
2. RisuAI에서 캐릭터 또는 전역 로어북을 열고, `lorebook/` 폴더의 항목들을 순서대로 추가합니다.
3. `scripts/main.lua` 내용을 **Start** 타입 트리거 Lua 항목에 추가합니다.
4. 아래 [설정 변수](#️-설정-변수-configuration) 섹션을 참조하여 원하는 방식으로 설정합니다.

### SillyTavern

- 해당 모듈의 로어북 항목들을 World Info(세계 정보)에 추가하고,  
  Lua 스크립트를 적절한 후크(hook)에 연결합니다.

---

## ⚙️ 설정 변수 (Configuration)

모듈의 동작은 아래 전역 변수(Global Variables)로 제어합니다:

| 변수명 | 타입 | 설명 |
|--------|------|------|
| `toggle_choicemodule_type` | number (0–3) | 선택지 스타일 타입 (0=기본, 1~3=변형, 4=비활성) |
| `toggle_choicemodule_length` | number (0–4) | 선택지 텍스트 길이 (0=상세, 1=일반, 2=짧게, 3=간결, 4=한 줄) |
| `toggle_choicemodule_perspective` | boolean | NPC 관점 선택지 포함 여부 |
| `toggle_choicemodule_menu` | boolean | 메뉴 버튼 표시 여부 |
| `toggle_choicemodule_dice` | number (0 or 1) | 주사위 타입 (0=D100, 1=D20) |
| `toggle_choicemodule_hidden` | boolean | 주사위 결과 숨김 여부 |
| `toggle_ChoiceModule.mode` | boolean | 모듈 전체 활성/비활성 |

---

## 🎲 주사위 시스템 (Dice System)

### D100 방식 (`toggle_choicemodule_dice = 0`)

| 결과 | 조건 |
|------|------|
| 🌟 Critical Success | 롤 ≤ 5 |
| ✅ Success | 롤 ≤ 성공 확률(threshold) |
| ❌ Failure | 롤 > 성공 확률 |
| 💀 Critical Failure | 롤 ≥ 95 |

### D20 방식 (`toggle_choicemodule_dice = 1`)

| 결과 | 조건 |
|------|------|
| 🌟 Critical Success | 롤 = 20 |
| ✅ Success | 롤 ≥ 난이도(DC) |
| ❌ Failure | 롤 < 난이도 |
| 💀 Critical Failure | 롤 = 1 |

---

## 🗂️ 로어북 항목 설명 (Lorebook Entries)

| 항목 | 타입 | 설명 |
|------|------|------|
| `⚖️ Choice Module: Capsule Extension 💊` | lorebook | AI에게 선택지 형식을 지시하는 시스템 프롬프트 |
| `🗑️ Request: Omit Choice` | editprocess | `<Choice>` 태그 패턴을 감지해 선택지 블록을 제거 |
| `🗑️ Request: Fix Dice` | editprocess | 구형 주사위 포맷을 신형 포맷으로 변환 |
| `🖥️ Display: Menu` | editdisplay | 마지막 메시지에 모듈 메뉴 버튼 추가 |
| `🖨️ Output: Remove Dice` | editoutput | 출력에서 주사위 원문 태그 제거 |
| `🖥️ Display: Lazy` | editdisplay | 선택지를 접을 수 있는 지연 로딩 UI 표시 |

---

## 📜 Lua 스크립트 (Scripts)

### `scripts/main.lua`

모듈의 핵심 동작을 담당하는 메인 스크립트입니다:

- **`onButtonClick`**: 선택지 버튼 클릭 이벤트 처리
  - `op` (option): 선택지 선택 및 AI 재생성 처리
  - `rr` (reroll): 주사위 리롤 (취소/리롤/강제 성공·실패)
  - `rm` (remove): 특정 선택지 블록 제거
- **`onOutput`**: AI 응답 출력 후 마지막 채팅 ID 저장
- **`listenEdit("editDisplay", ...)`**: 채팅 표시 시 선택지 HTML 변환
  - `<Choice>` → 체크박스 토글 래퍼로 변환
  - `<ChoiceModule>` → 접기/펼치기 상세 UI로 변환
  - `<Suggestion>` → 버튼으로 변환
  - `<?checked ...?>` → 주사위 결과 테이블 UI로 변환

---

## 📋 선택지 포맷 (Choice Format)

AI가 출력해야 하는 선택지 형식:

```xml
<ChoiceModule>
  <Suggestion id="1">
    <Check for="행동 설명" comment="설명" success_probability=75 dice_outcome="..."/>
    선택지 텍스트
  </Suggestion>
  <Suggestion id="2">선택지 텍스트</Suggestion>
  ...
</ChoiceModule>
```

---

## 📄 라이선스 (License)

Copyright 2025 All rights reserved by [arca.live/b/characterai](https://arca.live/b/characterai)

---

## 🔗 관련 링크 (Related Links)

- [아카라이브 캐릭터AI 채널](https://arca.live/b/characterai)
- [RisuAI](https://github.com/kwaroran/RisuAI)
- [SillyTavern](https://github.com/SillyTavern/SillyTavern)
