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
{{#if_pure {{equal::{{getglobalvar::toggle_choicemodule_type}}::0}}}}<Suggestion id={ 1 }>
  <Scene seed={ `Basic or 기본, etc.` }>
    {{gettempvar::length}}, consistent with their established character.
  </Scene>
</Suggestion>

{{/}}{{#if {{less::{{getglobalvar::toggle_choicemodule_type}}::3}}}}
<Suggestion id={ {{? ({{getglobalvar::toggle_choicemodule_type}}=0)+1}} }>
  <Scene seed={ `Context-relevant keywords such as abilities, skills, traits, topics, objects, or etc.` }>
    {{gettempvar::length}}, inspired by the given seed keywords.
  </Scene>{{#if_pure {{not_equal::{{getglobalvar::toggle_choicemodule_type}}::1}}}}
  <Check for={ `Specific action, ability, situation, or etc.` }
    comment={ `Brief in-world reflections, responses, inner thoughts, meta-comments, flavor quips, or etc., from nearby NPC or {{user}}, about the likelihood, potential consequences, or etc.` }{{#if_pure {{not::{{getglobalvar::toggle_choicemodule_dice}}}}}}
    success_probability={ `0% (impossible or invalid) to 100% (trivial or guaranteed)` } />{{/}}{{#if_pure {{getglobalvar::toggle_choicemodule_dice}}}}
    difficulty_class={ `1 (trivial) to 20 (nearly impossible)` } />{{/}}{{/}}{{#if_pure {{equal::{{getglobalvar::toggle_choicemodule_type}}::1}}}}
  <Bubble>
	Nearby NPC or {{user}}: Brief responses, reflections, inner thoughts, flavor quips, or etc.
  </Bubble>{{/}}
</Suggestion>
{{/}}{{#if {{equal::{{getglobalvar::toggle_choicemodule_type}}::3}}}}
<Suggestion id={ 1 }>
<Scene seed={ `Basic or 기본, etc.` }>
{{gettempvar::length}}, consistent with their established character.
</Scene>
<Bubble>
Nearby NPC or {{user}}: Brief responses, reflections, inner thoughts, flavor quips, or etc.
</Bubble>
</Suggestion>

<Suggestion id={ 2 }>
<Scene seed={ `Positive, Favorable, or etc.` }>
{{gettempvar::length}} that would result in a positive or favorable interaction.
</Scene>
<Bubble>
Nearby NPC or {{user}}: Brief responses, reflections, inner thoughts, flavor quips, or etc.
</Bubble>
</Suggestion>

<Suggestion id={ 3 }>
<Scene seed={ `Witty, Sarcastic, Humorous, or etc.` }>
{{gettempvar::length}} that takes a clever, sarcastic, or humorous approach to the situation, possibly breaking tension or catching others off-guard. This response should still reflect their personality, but with a twist of wit or mischief.
</Scene>
<Bubble>
Nearby NPC or {{user}}: Brief responses, reflections, inner thoughts, flavor quips, or etc.
</Bubble>
</Suggestion>
{{/}}
<!-- Add more suggestions in same format as needed -->
````

---

## 설명

LightBoard 모드에서 AI에게 제공하는 출력 형식 템플릿입니다.

- `{{trim::...}}`: 앞뒤 공백을 제거하여 깔끔하게 출력
- `<lb-choice>` 태그로 감싸진 선택지 블록
- 메인 프롬프트(`01_main_prompt.md`)의 `<Choice>` 형식과 동일한 구조
- `Nearby NPC` (대문자 N): 캡슐 확장 프롬프트와 달리 `Nearby`가 대문자임에 유의
- `toggle_choicemodule_type`에 따라 다양한 선택지 포맷 적용
