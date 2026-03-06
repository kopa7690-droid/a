# ChoiceModule.lb.format — LightBoard 출력 형식

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `ChoiceModule.lb.format` |
| **bookVersion** | `2` |

---

## 콘텐츠 (Content)

````
{{trim::
{{#if {{? {{getglobalvar::toggle_choicemodule_length}}!=4}} }}
{{settempvar::length::A{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}<2}}}} full{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}<1}}}}, detailed{{/}}{{#if_pure {{? {{getglobalvar::toggle_choicemodule_length}}=3}}}} concise{{/}} text paragraph, including {{user}}{{#if_pure {{getglobalvar::toggle_choicemodule_perspective}}}} or NPC{{/}}'s dialogue and actions}}
{{/}}
{{#if {{? {{getglobalvar::toggle_choicemodule_length}}=4}}}}
{{settempvar::length::An option with a concise explanation for {{user}}{{#if_pure {{getglobalvar::toggle_choicemodule_perspective}}}} or NPC{{/}}}}
{{/}}
}}<lb-choice>
{{#if_pure {{getglobalvar::toggle_choicemodule_auto}}}}
<Director>
  <Tension level={ `low|medium|high|critical` } />
  <AllyReady name={ `nearby character name or none` } available={ `true|false` } />
  <DCRange suggested_min={ `3~10` } suggested_max={ `12~18` } />
</Director>
{{/}}
<Suggestion id={ 1 } stat={ `STR` }>
  <Scene seed={ `Basic or 기본, etc.` }>
    {{gettempvar::length}}, consistent with their established character.
  </Scene>
</Suggestion>

<Suggestion id={ 2 } stat={ `DEX` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<Suggestion id={ 3 } stat={ `CON` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<Suggestion id={ 4 } stat={ `INT` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<Suggestion id={ 5 } stat={ `WIS` }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />
</Suggestion>
<!-- Always exactly 5 suggestions. Assign each a different stat from STR/DEX/CON/INT/WIS/CHA; use 5 of the 6 stats (all different). Choose stat values contextually to best match each suggestion's nature. -->
````

---

## 설명

LightBoard 모드에서 AI에게 제공하는 출력 형식 템플릿입니다.

- `{{trim::...}}`: 앞뒤 공백을 제거하여 깔끔하게 출력
- `<lb-choice>` 태그로 감싸진 선택지 블록
- 메인 프롬프트(`01_main_prompt.md`)의 `<Choice>` 형식과 동일한 구조
- `Nearby NPC` (대문자 N): 캡슐 확장 프롬프트와 달리 `Nearby`가 대문자임에 유의
- Mix 모드 고정: 첫 번째 선택지(id=1)는 Check 없는 기본 행동, 나머지 4개(id=2~5)는 Check 포함
- 항상 정확히 5개의 선택지를 생성하며, 각 선택지에 `stat={ STR|DEX|CON|INT|WIS|CHA }` 속성이 필수 (5개 모두 서로 다른 스탯)
- **궁극기 연동**: `stat` 속성은 `scripts/actions.lua`의 게이지 충전·발동 로직에서 사용됩니다. `toggle_choicemodule_ultimate = true`일 때 FULL 게이지 스탯 선택지는 자동으로 Critical Success를 발동합니다.
- **Director 블록**: `toggle_choicemodule_auto`가 켜져 있을 때만 `<lb-choice>` 바로 뒤에 출력됩니다. AI가 현재 장면의 긴장도(Tension), 파티원 보조 가능 여부(AllyReady), DC 범위(DCRange)를 자동으로 판단합니다. 이 블록은 `onOutput`에서 파싱 후 chatVar에 저장되고 출력에서 제거됩니다.
