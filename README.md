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
| 🎯 자동 선택지 생성 | AI 응답마다 항상 5개의 다음 행동 선택지를 자동으로 제시 |
| ⚔️ D&D 스탯 속성 | 각 선택지에 STR/DEX/CON/INT/WIS/CHA 중 하나의 스탯을 부여하며, 5개 선택지에 모두 다른 스탯 사용 |
| 🎲 주사위 판정 | D20 방식 지원, 6단계 판정(Critical Success/Success/Narrow Success/Narrow Failure/Failure/Critical Failure) |
| 🔄 리롤 | 주사위 결과 재굴림 및 강제 성공/실패 옵션 |
| 📋 선택지 병합 | 이전 응답에 선택지 결과를 병합하는 기능 |
| 🦥 지연 로딩 | 선택지를 필요할 때만 불러오는 Lazy Load 지원 |
| 🗑️ 선택지 제거 | 불필요한 선택지를 숨기거나 제거 |
| 🌐 NPC 관점 | 유저 또는 NPC 관점의 선택지 생성 지원 |
| 🔥 궁극기 시스템 | 스탯별 게이지 충전 후 발동 — 무조건 대성공(Critical Success) 강제 (BETA) |
| 🤝 보조 판정 시스템 | 파티원 보조 주사위로 실패 결과를 상쇄 — outcome 단계 업그레이드 (Phase 4) |
| 🛡️ 연속 실패 보정 | 3회 이상 연속 실패 시 다음 판정에 +1~+5 자동 보정 — Pity System (Phase 5) |

---

## 📁 프로젝트 구조 (Project Structure)

```
📦 choice-module-capsule-extension
├── 📄 README.md                              # 이 문서
├── 📂 lorebook/                              # 로어북 항목들
│   ├── 01_main_prompt.md                     # 메인 프롬프트
│   ├── 07_manifest_lb.md                     # LightBoard 매니페스트
│   ├── 08_choicemodule_lb.md                 # LightBoard 태스크 할당
│   ├── 09_choicemodule_lb_job.md             # LightBoard 작업 설명
│   ├── 10_choicemodule_lb_format.md          # LightBoard 출력 형식
│   ├── 11_choicemodule_lb_thoughts.md        # LightBoard 단계별 사고
│   ├── 12_choicemodule_lb_onoutput.md        # LightBoard 출력 후처리 (Lua)
│   ├── 13_choicemodule_lb_interaction.md     # LightBoard 인터랙션 태스크
│   ├── 14_choicemodule_lb_thoughts_interaction.md  # LightBoard 인터랙션 단계별 사고
│   └── 15_choicemodule_actions.md            # 액션 스크립트 (로어북 Lua) 문서
├── 📂 scripts/
│   ├── main.lua                              # 메인 Lua 트리거 스크립트
│   ├── actions.lua                           # 선택지 액션 Lua 스크립트 (로어북 항목)
│   ├── 02_request_omit_choice.md             # editprocess: 선택지 제거 규칙
│   ├── 03_request_fix_dice.md                # editprocess: 주사위 수정 규칙
│   ├── 04_display_menu.md                    # editdisplay: 메뉴 표시 규칙
│   ├── 05_output_remove_dice.md              # editoutput: 주사위 출력 제거 규칙
│   └── 06_display_lazy.md                    # editdisplay: 지연 로딩 표시 규칙
└── 📂 docs/
    └── usage.md                              # 상세 사용법 가이드
```

---

## ⚙️ 설정 변수 (Configuration)

모듈의 동작은 아래 전역 변수(Global Variables)로 제어합니다:

| 변수명 | 타입 | 설명 |
|--------|------|------|
| `toggle_choicemodule_length` | number (0–4) | 선택지 텍스트 길이 (0=상세, 1=일반, 2=짧게, 3=간결, 4=한 줄) |
| `toggle_choicemodule_perspective` | boolean | NPC 관점 선택지 포함 여부 |
| `toggle_choicemodule_menu` | boolean | 메뉴 버튼 표시 여부 |
| `toggle_choicemodule_hidden` | boolean | 주사위 결과 숨김 여부 |
| `toggle_choicemodule_diversity` | boolean | 다양성 강조 모드 |
| `toggle_choicemodule_proactivity` | boolean | 능동적 제안 모드 |
| `toggle_ChoiceModule.mode` | boolean | 모듈 전체 활성/비활성 |
| `toggle_ChoiceModule.korean` | boolean | 한국어 출력 모드 |
| `toggle_ChoiceModule.noLorebook` | number | 1이면 LightBoard 로어북 참조 비활성 |
| `toggle_lightboard.thoughts` | number | LightBoard 사고 단계 상세도 (3 미만이면 8단어 제한) |
| `toggle_choicemodule_ultimate` | boolean | 궁극기(Ultimate) 시스템 활성화 여부 (BETA, 기본값 false) |
| `toggle_choicemodule_ally` | boolean | 보조(Ally) 판정 시스템 활성화 여부 (기본값 false) |
| `toggle_choicemodule_ally_name` | string | 보조 판정 캐릭터 이름 (기본값 "파티원") |

---

## 🎲 주사위 시스템 (Dice System)

### D20 방식 (6단계 판정)

- 1~20 사이의 난수를 굴립니다.
- **난이도(difficulty_class, DC)**: 판정 기준값 (기본값 10)

| 결과 | 조건 (DC=12 예시) |
|------|------|
| 🌟 Critical Success | 롤 = 20 |
| ✅ Success | 롤 ≥ DC+3 (15~19) |
| 🔼 Narrow Success | 롤 ≥ DC (12~14) |
| 🔽 Narrow Failure | 롤 ≥ DC-3 (9~11) |
| ❌ Failure | 롤 ≥ 2 (2~8) |
| 💀 Critical Failure | 롤 = 1 |

> **Narrow 판정 OOC 안내**: Narrow Success 또는 Narrow Failure가 나오면 유저 메시지에 근소한 결과임을 알리는 OOC 안내가 자동 추가됩니다.

---

## ⚔️ D&D 스탯 시스템 (Stat System)

각 선택지에는 D&D 스타일 6개 스탯 중 하나가 반드시 할당됩니다.  
**5개 선택지는 모두 서로 다른 스탯을 사용해야 합니다** (6개 중 5개).

| 스탯 | 약어 | 설명 |
|------|------|------|
| Strength | STR | 근력 — 물리적 힘, 격투, 무기 공격 |
| Dexterity | DEX | 민첩 — 회피, 속도, 은신, 원거리 공격 |
| Constitution | CON | 건강 — 지구력, 체력, 독 저항 |
| Intelligence | INT | 지능 — 지식, 마법, 추론, 수사 |
| Wisdom | WIS | 지혜 — 직관, 인식, 의지력 |
| Charisma | CHA | 매력 — 설득, 속임수, 사회적 상호작용 |

각 `<Suggestion>`에는 `stat={ STR|DEX|CON|INT|WIS|CHA }` 속성이 필수입니다.  
5개 선택지에 사용할 스탯은 맥락에 맞게 선택하며, 사용하지 않는 1개 스탯은 상황에 따라 달라질 수 있습니다.

---

## 🔥 궁극기 시스템 (Ultimate System) — BETA

> `toggle_choicemodule_ultimate = true`로 활성화합니다.

### 개요

스탯별 독립 **게이지**를 충전하여 FULL 상태에서 해당 스탯 선택지를 고르면 **무조건 대성공(Critical Success)**을 발동하는 시스템입니다.

### 게이지 변수

| 변수 (chatVar) | 설명 |
|----------------|------|
| `ChoiceModule.ult_STR` | 🪓 Strength 게이지 (0–5) |
| `ChoiceModule.ult_DEX` | 🏃 Dexterity 게이지 (0–5) |
| `ChoiceModule.ult_CON` | 🛡️ Constitution 게이지 (0–5) |
| `ChoiceModule.ult_INT` | 🧠 Intelligence 게이지 (0–5) |
| `ChoiceModule.ult_WIS` | 👁️ Wisdom 게이지 (0–5) |
| `ChoiceModule.ult_CHA` | 💬 Charisma 게이지 (0–5) |

### 충전 규칙

| 상황 | 충전량 |
|------|--------|
| 스탯 선택지 선택 (일반 / Narrow) | +1 |
| Critical Failure (크리 실패) | +2 |
| Success / Critical Success | +1 |
| 파티원 보조 성공 *(Phase 4 예정)* | 충전 없음 |
| stat 정보 없는 구형 선택지 | 충전 없음 |

### 발동 조건 및 효과

- 해당 스탯 게이지가 **5/5 (FULL)** 상태에서 그 스탯 선택지 선택 시 궁극기 발동
- **주사위 굴림 없이** `outcome = "Critical Success"`, `rolled = 20`으로 고정
- 게이지를 **0으로 리셋**
- 유저 메시지에 다음 OOC 지시문이 자동 삽입됨:

```
* OOC: {{user}}의 🪓 STR 궁극기가 발동됩니다! 무조건 대성공입니다. STR 능력이 극한까지 발휘되는 극적인 장면을 연출하세요.
```

### UI

- 각 `<Choice>` 블록 하단에 스탯별 게이지 바 표시: `🪓 STR [███░░] 3/5`
- FULL 게이지 스탯은 🔥, 일반은 스탯 이모지로 표시: `🔥 STR [█████] 5/5`
- FULL 게이지 선택지 버튼에 CSS 강조 클래스 `choicemodule-ult-ready` 적용 (BETA)

### 후방 호환

- `toggle_choicemodule_ultimate`가 false/0이거나 설정되지 않은 경우 완전히 비활성 → 기존 동작 유지
- `stat` 속성 없는 구형 선택지: 게이지 충전/발동 없음

---

## 🤝 보조 판정 시스템 (Ally Assist System) — Phase 4

> 활성화: `toggle_choicemodule_ally = true`

### 개요

파티원이 유저의 **실패/패널티 결과를 보조**하여 outcome을 한 단계 이상 올려주는 협동 판정 시스템입니다.  
유저의 주사위 결과가 실패 계열(Critical Failure / Failure / Narrow Failure)일 때 파티원이 **보조 주사위**를 굴려 결과를 상쇄시킬 수 있습니다.

### 보조 판정 규칙

| 유저 결과 | 보조 발동 여부 |
|-----------|---------------|
| Critical Failure | ✅ 보조 가능 |
| Failure | ✅ 보조 가능 |
| Narrow Failure | ✅ 보조 가능 |
| Narrow Success 이상 | ❌ 보조 불필요 (발동 안 함) |

| 보조 결과 | 업그레이드 |
|-----------|-----------|
| 🔼 Narrow Success | +1 단계 |
| ✅ Success | +2 단계 |
| 🌟 Critical Success | +3 단계 (최대 Critical Success) |
| Failure 계열 | 변화 없음, 출력 없음 |

### 예시 업그레이드

```
유저: Critical Failure(0) + 보조 Narrow Success(+1) → Failure(1)
유저: Failure(1)          + 보조 Success(+2)        → Narrow Success(3)
유저: Narrow Failure(2)   + 보조 Critical Success(+3)→ Critical Success(5)
```

### OOC 자동 삽입

보조 판정으로 outcome이 변화된 경우 유저 메시지에 다음 OOC가 자동 추가됩니다:

```
* (OOC: '엘리아'가 {{user}}의 실패를 보조하여 Narrow Failure로 상쇄시킵니다. 유저의 행동을 서포트하는 묘사를 포함하세요.)
```

보조가 실패(Failure 계열)하면 아무런 출력도 추가되지 않습니다.

### 궁극기와의 관계

- 궁극기가 발동된 경우 보조 판정은 **완전히 건너뜁니다** (궁극기 우선).
- 보조 성공으로 outcome이 변경되더라도 **궁극기 게이지는 충전되지 않습니다**.

### UI 표시

주사위 결과 테이블 아래에 보조 정보가 표시됩니다 (결과 미숨김 시):

```
🤝 보조: [ 15 ] → Narrow Success ｜ 최종: [ Narrow Failure ]
```

`Outcome` 셀에는 항상 **최종 outcome**(보조 적용 후)이 표시됩니다.

### 설정 변수

| 변수명 | 타입 | 기본값 | 설명 |
|--------|------|--------|------|
| `toggle_choicemodule_ally` | boolean | false | 보조 판정 시스템 활성화 여부 |
| `toggle_choicemodule_ally_name` | string | "파티원" | OOC에 표시될 보조 캐릭터 이름 |

### 후방 호환

- `toggle_choicemodule_ally`가 false/0이거나 설정되지 않은 경우 완전히 비활성 → 기존 동작 유지
- 궁극기 시스템과 독립적으로 동작합니다 (둘 다 활성화 가능)

---

## 🗂️ 로어북 항목 설명 (Lorebook Entries)

| 항목 | 타입 | 설명 |
|------|------|------|
| `⚖️ Choice Module: Capsule Extension 💊` | lorebook | AI에게 선택지 형식을 지시하는 시스템 프롬프트 |
| `---` | (구분선) | 시각적 구분용 비활성 항목 |
| `manifest.lb` | lorebook | LightBoard 통합 매니페스트 |
| `ChoiceModule.lb` | lorebook | LightBoard 모드 태스크 할당 지시문 |
| `ChoiceModule.lb.job` | lorebook | LightBoard 모드 작업 설명 |
| `ChoiceModule.lb.format` | lorebook | LightBoard 모드 출력 형식 템플릿 |
| `ChoiceModule.lb.thoughts` | lorebook | LightBoard 단계별 사고 유도 |
| `ChoiceModule.lb.onOutput` | lorebook | LightBoard 출력 후처리 Lua 함수 |
| `ChoiceModule.lb.interaction` | lorebook | LightBoard 인터랙션 태스크 업데이트 |
| `ChoiceModule.lb.thoughts-interaction` | lorebook | LightBoard 인터랙션 단계별 사고 유도 |
| `ChoiceModule.actions` | lorebook | 버튼 액션 처리 Lua 스크립트 |
| `🗑️ Request: Omit Choice` | editprocess | `<Choice>` 태그 패턴을 감지해 선택지 블록을 제거 |
| `🗑️ Request: Fix Dice` | editprocess | 구형 주사위 포맷을 신형 포맷으로 변환 |
| `🖥️ Display: Menu` | editdisplay | 마지막 메시지에 모듈 메뉴 버튼 추가 |
| `🖨️ Output: Remove Dice` | editoutput | 출력에서 주사위 원문 태그 제거 |
| `🖥️ Display: Lazy` | editdisplay | 선택지를 접을 수 있는 지연 로딩 UI 표시 |

---

## 🔌 LightBoard 통합 (LightBoard Integration)

**LightBoard 모드**는 선택지 생성을 별도의 AI 호출(독립 생성)로 처리하는 고급 통합 방식입니다.  
`toggle_ChoiceModule.mode`를 LightBoard 모드로 설정하면 아래 항목들이 활성화됩니다.

| 항목 | 역할 |
|------|------|
| `manifest.lb` | LightBoard 호출 시 포함할 컨텍스트 범위를 정의 |
| `ChoiceModule.lb` | 태스크 지시문 |
| `ChoiceModule.lb.job` | 작업 설명 |
| `ChoiceModule.lb.format` | 출력 XML 형식 템플릿 |
| `ChoiceModule.lb.thoughts` | 단계별 추론 유도 |
| `ChoiceModule.lb.onOutput` | 출력 결과의 ID 타임스탬프 처리 |
| `ChoiceModule.lb.interaction` | 유저 인터랙션 반영 |
| `ChoiceModule.lb.thoughts-interaction` | 인터랙션 시 단계별 추론 유도 |

---

## 📜 Lua 스크립트 (Scripts)

### `scripts/main.lua`

모듈의 핵심 동작을 담당하는 메인 스크립트입니다:

- **`onButtonClick`**: 선택지 버튼 클릭 이벤트 처리
  - `op` (option): 선택지 선택 및 AI 재생성 처리
  - `mn` (menu): 선택지 모듈 메뉴 (재생성, 요청+재생성, 삭제)
  - `mg` (merge): OOC 선택지를 이전 AI 응답에 병합
  - `rr` (reroll): 주사위 리롤 (취소/리롤/강제 성공·실패)
  - `rm` (remove): 특정 선택지 블록 제거
- **`onOutput`**: AI 응답 출력 후 마지막 채팅 ID 저장
- **`listenEdit("editDisplay", ...)`**: 채팅 표시 시 선택지 HTML 변환
  - `<Choice>` → 체크박스 토글 래퍼로 변환
  - `<ChoiceModule>` → 접기/펼치기 상세 UI로 변환
  - `<Suggestion>` → 버튼으로 변환
  - `<?checked ...?>` → 주사위 결과 테이블 UI로 변환

### `scripts/actions.lua`

로어북 항목 `ChoiceModule.actions`의 원본 콘텐츠입니다.  
`main.lua`의 `getLoreBooks()`를 통해 동적으로 로드됩니다.

> **참고**: `@`는 런타임에 `-`로 치환되는 난독화 문자입니다.  
> 예: `.@` → `.-` (비탐욕 패턴), `@@` → `--` (주석), `@1` → `-1`

---

## 📋 선택지 포맷 (Choice Format)

AI가 출력해야 하는 선택지 형식:

```xml
<ChoiceModule>
  <Suggestion id="1" stat="STR">
    <Check for="행동 설명" comment="설명" difficulty_class=12 />
    선택지 텍스트
  </Suggestion>
  <Suggestion id="2" stat="DEX">선택지 텍스트</Suggestion>
  <Suggestion id="3" stat="CON">선택지 텍스트</Suggestion>
  <Suggestion id="4" stat="INT">선택지 텍스트</Suggestion>
  <Suggestion id="5" stat="WIS">선택지 텍스트</Suggestion>
</ChoiceModule>
```

---

## 🛡️ 연속 실패 보정 시스템 (Pity System) — Phase 5

### 개요

유저가 **연속으로 실패**할 때 확률을 보정하는 시스템입니다.  
3회 이상 연속 실패(Failure / Critical Failure / Narrow Failure) 시 다음 판정에 자동으로 **+1~+5 보정**이 추가됩니다.

### 발동 조건

| 결과 | failStreak 변화 |
|------|----------------|
| Critical Success | 0으로 리셋 |
| Success | 0으로 리셋 |
| Narrow Success | 변화 없음 |
| Narrow Failure | +1 증가 |
| Failure | +1 증가 |
| Critical Failure | +1 증가 |

### 보정 규칙

- **3회 이상 연속 실패** 시: 다음 판정에서 D20 결과에 **+1~+5(랜덤) 보정** 자동 적용
- 보정값은 롤 결과에 더해지며 최대 20을 초과하지 않습니다
- 보정이 적용된 경우 유저 메시지에 OOC 안내가 자동 추가됩니다:

```
* (OOC: 연속된 실패로, 이번 판정엔 +2 보정이 적용되었습니다.)
```

### 저장 변수

| 변수 (chatVar) | 설명 |
|----------------|------|
| `ChoiceModule.failStreak` | 연속 실패 카운터 (0~N) |

### 궁극기와의 관계

- 궁극기가 발동된 경우 Pity 보정은 **완전히 건너뜁니다** (궁극기 우선)
- 궁극기 발동 결과(Critical Success)는 failStreak를 0으로 리셋합니다

### 후방 호환

- 별도 토글 없이 항상 활성 (스트릭이 3 미만이면 보정 없이 기존 동작 유지)
- `ChoiceModule.failStreak`가 초기화되지 않은 경우 0으로 처리

---

## 📄 라이선스 (License)

Copyright 2025 All rights reserved by [arca.live/b/characterai](https://arca.live/b/characterai)

---

## 🔗 관련 링크 (Related Links)

- [아카라이브 캐릭터AI 채널](https://arca.live/b/characterai)
- [RisuAI](https://github.com/kwaroran/RisuAI)
- [SillyTavern](https://github.com/SillyTavern/SillyTavern)
