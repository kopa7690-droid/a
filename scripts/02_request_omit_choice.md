# 🗑️ Request: Omit Choice — 선택지 제거 규칙

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `🗑️ Request: Omit Choice` |
| **type** | `editprocess` |
| **ableFlag** | `true` |

---

## 패턴 (Pattern)

```regex
^\s*<[cC]hoice-?([mM]odule)?( id=\d+)?>.*<\/[sS]uggestion>\s*(<\/[cC]hoice-?([mM]odule)?>)?
```

**플래그**: `sm`

---

## 설명

AI가 출력한 `<Choice>` 또는 `<ChoiceModule>` 블록 전체를 감지하여 제거합니다.  
선택지 출력이 필요하지 않은 상황(예: OOC 메시지, 특정 모드)에서 활성화됩니다.

- `<Choice>` 또는 `<ChoiceModule>` 태그로 시작하는 블록
- `</Suggestion>` 태그로 끝나는 블록
- 선택적으로 닫는 태그(`</ChoiceModule>`) 포함
- `sm` 플래그: 멀티라인 + 대소문자 패턴 적용
