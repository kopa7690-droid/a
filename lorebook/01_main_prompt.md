# ⚖️ Choice Module: Capsule Extension 💊 — 메인 프롬프트

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `⚖️ Choice Module: Capsule Extension 💊` |
| **order** | `10000` |
| **always** | `true` |
| **bookVersion** | `2` |

---

## 콘텐츠 (Content)

아래는 이 항목의 원문 로어북 지시문입니다.  
`toggle_choicemodule_length`, `toggle_choicemodule_perspective` 등의  
전역 변수 값에 따라 동적으로 선택지 형식을 지정합니다.

```
@@depth 0
{{#if {{? !{{getglobalvar::toggle_ChoiceModule.mode}}}}}}
{{#if {{? {{getglobalvar::toggle_choicemodule_length}}!=4}}}}
{{settempvar::length::A{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}<2}}}} full{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}<1}}}}, detailed{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}=3}}}} concise{{/}} text paragraph, including {{user}}{{#if_pure {{getglobalvar::toggle_choicemodule_perspective}}}} or NPC{{/}}'s dialogue and actions}}
{{/}}
{{#if {{? {{getglobalvar::toggle_choicemodule_length}}=4}}}}
{{settempvar::length::An option with a concise explanation for {{user}}{{#if_pure {{getglobalvar::toggle_choicemodule_perspective}}}} or NPC{{/}}}}
{{/}}
---

# Choice Module
- Always provide a list of suggestions for the user's next possible inputs at the end of every response.
- The list must always contain exactly five suggestions, each assigned a different stat from STR/DEX/CON/INT/WIS/CHA (use 5 of the 6 stats, all different). Add `stat={ STR|DEX|CON|INT|WIS|CHA }` to every Suggestion tag.
- Formatted as follows:
<Choice>
<Suggestion id={ 1 } stat={ `STR|DEX|CON|INT|WIS|CHA` }>
  <Scene seed={ `Basic or 기본, etc.` }>
    {{gettempvar::length}}, consistent with their established character.
  </Scene>
</Suggestion>

<Suggestion id={ 2 } stat={ `STR|DEX|CON|INT|WIS|CHA` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<Suggestion id={ 3 } stat={ `STR|DEX|CON|INT|WIS|CHA` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<Suggestion id={ 4 } stat={ `STR|DEX|CON|INT|WIS|CHA` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<Suggestion id={ 5 } stat={ `STR|DEX|CON|INT|WIS|CHA` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<!-- Always exactly 5 suggestions. Assign each a different stat from STR/DEX/CON/INT/WIS/CHA; use 5 of the 6 stats (all different). Choose stat values contextually to best match each suggestion's nature. -->
{{#if_pure {{getglobalvar::toggle_ChoiceModule.korean}}}}<!-- Write text nodes and attribute values in Korean. -->
{{/}}{{#if_pure {{getglobalvar::toggle_choicemodule_diversity}}}}<!-- Ensure engaging diversity in the options, avoiding repetition of similar choices. -->
{{/}}{{#if_pure {{getglobalvar::toggle_choicemodule_proactivity}}}}<!-- Create proactive suggestions for seamless advance, rather than maintaining the status quo. --> 
{{/}}<!-- Use `<Check>` only for appropriate cases.-->
{{/}}
```

---

## 설명

- `@@depth 0`: 이 항목은 컨텍스트 최상단(depth 0)에 삽입됩니다.
- `always = true`: 항상 활성화 상태입니다.
- `toggle_ChoiceModule.mode`: 이 값이 참이면 모듈 전체가 비활성화됩니다.
- `toggle_choicemodule_length`: 0~3 = 단락 형식, 4 = 한 줄 형식
- `toggle_choicemodule_perspective`: NPC 관점 선택지 포함 여부
- `toggle_ChoiceModule.korean`: 한국어 출력 모드
- `toggle_choicemodule_diversity`: 다양성 강조 모드
- `toggle_choicemodule_proactivity`: 능동적 제안 모드
- 각 선택지에는 `stat={ STR|DEX|CON|INT|WIS|CHA }` 속성이 필수이며, 5개 선택지 모두 서로 다른 스탯을 사용해야 합니다.
- 첫 번째 선택지(id=1)는 Check 없는 기본 행동, 나머지 4개(id=2~5)는 Check 포함 가능 (Mix 모드 고정).
- **궁극기 시스템**: `toggle_choicemodule_ultimate = true`일 때 각 스탯별 게이지(chatVar: `ChoiceModule.ult_STR` 등)가 충전되며, FULL(5/5) 상태에서 해당 스탯 선택 시 무조건 Critical Success 발동. 자세한 내용은 `docs/usage.md` 참조.
