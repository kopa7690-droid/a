# ChoiceModule.lb — LightBoard 태스크 할당

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `ChoiceModule.lb` |
| **bookVersion** | `2` |

---

## 콘텐츠 (Content)

```
# Task Assignment

- Gather elements of current contetxt, focused on last chapter.
- Provide a list of suggestions for the user{{#if_pure {{? {{getglobalvar::toggle_choicemodule_perspective}}=0}}}}({{user}}){{/}}'s next possible input while maintaining previously used tone, pov, and style used in the main output.
- The list should contain at least one and up to five suggestions.{{#if_pure {{getglobalvar::toggle_choicemodule_diversity}}}}
- Ensure engaging diversity in the options, avoiding repetition of similar choices.{{/}}{{#if_pure {{getglobalvar::toggle_choicemodule_proactivity}}}}
- Create proactive suggestions for seamless advance, rather than maintaining the status quo.{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_type}}=0}}}}
- Use `Check` only for appropriate cases.{{/}}{{#if_pure {{getglobalvar::toggle_ChoiceModule.korean}}}}
- User Request: Write text nodes and attribute values in Korean.{{/}}
```

---

## 설명

LightBoard 모드에서 AI에게 부여하는 태스크 지시문입니다.

- 현재 컨텍스트(마지막 챕터 중심)를 수집하고 선택지 목록을 생성하도록 지시합니다.
- `toggle_choicemodule_perspective=0`: 유저(`{{user}}`)를 명시적으로 언급
- `toggle_choicemodule_diversity`: 다양한 선택지 생성 지시
- `toggle_choicemodule_proactivity`: 능동적인 진행 제안 지시
- `toggle_choicemodule_type=0`: `Check` 요소는 적절한 경우에만 사용
- `toggle_ChoiceModule.korean`: 한국어 출력 요청
