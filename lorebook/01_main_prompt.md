# ⚖️ Choice Module: Capsule Extension 💊 — 메인 프롬프트

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `⚖️ Choice Module: Capsule Extension 💊` |
| **order** | `10000` |
| **type** | lorebook (system prompt) |

---

## 콘텐츠 (Content)

아래는 이 항목의 원문 로어북 지시문입니다.  
`toggle_choicemodule_type`, `toggle_choicemodule_length`, `toggle_choicemodule_perspective` 등의  
전역 변수 값에 따라 동적으로 선택지 형식을 지정합니다.

```
@@depth 0
{{#if {{? {{getglobalvar::toggle_choicemodule_type}}<4&!{{getglobalvar::toggle_ChoiceModule.mode}}}}}}
{{#if {{? {{getglobalvar::toggle_choicemodule_length}}!=4}}}}
{{settempvar::length::A{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}<2}}}} full{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}<1}}}}, detailed{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}=3}}}} concise{{/}} text paragraph, including {{user}}{{#if_pure {{getglobalvar::toggle_choicemodule_perspective}}}} or NPC{{/}}'s dialogue and actions}}
{{/}}
{{#if {{? {{getglobalvar::toggle_choicemodule_length}}=4}}}}
{{settempvar::length::An option with a concise explanation for {{user}}{{#if_pure {{getglobalvar::toggle_choicemodule_perspective}}}} or NPC{{/}}}}
{{/}}
---

# Choice Module
- Always provide a list of suggestions for the user's next possible inputs at the end of every response.
- The list should contain at least one and up to five suggestions, formatted as follows:
```

---

## 설명

- `@@depth 0`: 이 항목은 컨텍스트 최상단(depth 0)에 삽입됩니다.
- `toggle_choicemodule_type < 4`: 모듈이 활성 상태일 때만 프롬프트를 삽입합니다.
- `toggle_choicemodule_length`: 0~3 = 단락 형식, 4 = 한 줄 형식
- `toggle_choicemodule_perspective`: NPC 관점 선택지 포함 여부
