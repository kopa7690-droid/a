# manifest.lb — LightBoard 매니페스트

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `manifest.lb` |
| **bookVersion** | `2` |

---

## 콘텐츠 (Content)

```
{{#if {{less::{{getglobalvar::toggle_choicemodule_type}}::4}}}}
identifier=ChoiceModule
authorsNote=true
charDesc=true{{#if_pure {{? {{getglobalvar::toggle_ChoiceModule.noLorebook}}!=1}}}}
loreBooks=true{{/}}
personaDesc=true
rerollBehavior=remove-prev
{{/}}
```

---

## 설명

LightBoard 통합 모드에서 사용하는 매니페스트 항목입니다.

- `identifier=ChoiceModule`: LightBoard 모듈 식별자
- `authorsNote=true`: 작가 노트 포함
- `charDesc=true`: 캐릭터 설명 포함
- `loreBooks=true`: 로어북 포함 (단, `toggle_ChoiceModule.noLorebook=1`이면 제외)
- `personaDesc=true`: 페르소나 설명 포함
- `rerollBehavior=remove-prev`: 리롤 시 이전 결과 제거
- `toggle_choicemodule_type < 4`일 때만 활성화
