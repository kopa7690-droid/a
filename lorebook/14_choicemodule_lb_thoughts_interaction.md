# ChoiceModule.lb.thoughts-interaction — LightBoard 인터랙션 단계별 사고

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `ChoiceModule.lb.thoughts-interaction` |
| **bookVersion** | `2` |

---

## 콘텐츠 (Content)

```
Think step-by-step before final submission. Keep each step concise.
{{#if {{? {{getglobalvar::toggle_lightboard.thoughts}} < 3 }} }}
Maximum 8 words per step, excluding step labels.
{{/if}}

Step:
1. Context: (Understand current context)
2. POV & Tense: (Check the tenses and points of view used in the previous narrative)
3. Character Dynamics: (Capture relevant character dynamics)
4. Genre & Tag: (Refer to relevant genres and tags)
5. Keywords: (Gather from creative materials that could inspire narrative idea.)
```

---

## 설명

LightBoard 인터랙션 모드에서 최종 제출 전 AI가 단계별로 사고하도록 유도하는 항목입니다.  
`ChoiceModule.lb.thoughts`와 동일한 구조이며, 유저 인터랙션 컨텍스트에서 사용됩니다.

- `toggle_lightboard.thoughts < 3`: 이 값이 3 미만이면 각 단계를 8단어 이하로 제한
- `...` 생략 없이 동일한 5단계 사고 과정을 적용
