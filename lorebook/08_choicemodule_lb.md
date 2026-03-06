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
- The list must always contain exactly five suggestions. Each suggestion must be assigned a different stat from STR/DEX/CON/INT/WIS/CHA (use 5 of the 6 stats, all different). Add `stat={ STR|DEX|CON|INT|WIS|CHA }` to every Suggestion tag.{{#if_pure {{getglobalvar::toggle_choicemodule_diversity}}}}
- Ensure engaging diversity in the options, avoiding repetition of similar choices.{{/}}{{#if_pure {{getglobalvar::toggle_choicemodule_proactivity}}}}
- Create proactive suggestions for seamless advance, rather than maintaining the status quo.{{/}}
- Use `Check` only for appropriate cases.{{#if_pure {{getglobalvar::toggle_ChoiceModule.korean}}}}
- User Request: Write text nodes and attribute values in Korean.{{/}}{{#if_pure {{getglobalvar::toggle_choicemodule_auto}}}}
- Before listing suggestions, output a <Director> block analyzing the current scene:
  • Tension: Assess the intensity of the current situation (low/medium/high/critical).
  • AllyReady: Based on nearby NPCs and party members, determine if an ally would naturally help the user. Provide the character's name if available.
  • DCRange: Suggest an appropriate difficulty range (D20 scale) for this scene based on context, stakes, and character capabilities.
{{/}}
```

---

## 설명

LightBoard 모드에서 AI에게 부여하는 태스크 지시문입니다.

- 현재 컨텍스트(마지막 챕터 중심)를 수집하고 항상 5개의 선택지 목록을 생성하도록 지시합니다.
- 각 선택지에는 STR/DEX/CON/INT/WIS/CHA 중 하나의 스탯을 부여하며, 5개 모두 서로 다른 스탯을 사용해야 합니다.
- `toggle_choicemodule_perspective=0`: 유저(`{{user}}`)를 명시적으로 언급
- `toggle_choicemodule_diversity`: 다양한 선택지 생성 지시
- `toggle_choicemodule_proactivity`: 능동적인 진행 제안 지시
- `toggle_ChoiceModule.korean`: 한국어 출력 요청
- `toggle_choicemodule_auto`: AI 자동 판단 모드 활성화 시, `<Director>` 블록 출력 지시 추가. AI가 긴장도·파티원 보조 가능 여부·DC 범위를 자동으로 판단합니다.
