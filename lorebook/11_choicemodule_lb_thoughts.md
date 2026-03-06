# ChoiceModule.lb.thoughts — LightBoard 단계별 사고

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `ChoiceModule.lb.thoughts` |
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
...
```

---

## 설명

LightBoard 모드에서 최종 제출 전 AI가 단계별로 사고하도록 유도하는 항목입니다.

- `toggle_lightboard.thoughts < 3`: 이 값이 3 미만이면 각 단계를 8단어 이하로 제한
- 5개의 사고 단계:
  1. **Context**: 현재 맥락 파악
  2. **POV & Tense**: 이전 서사에서 사용된 시점과 시제 확인
  3. **Character Dynamics**: 관련 캐릭터 역학 파악
  4. **Genre & Tag**: 관련 장르와 태그 참조
  5. **Keywords**: 서사 아이디어를 영감받을 수 있는 키워드 수집
