# 🗑️ Request: Strip Party — 파티 보조 OOC 제거

## 항목 정보

| 필드 | 값 |
|------|---|
| **name** | `🗑️ Request: Strip Party` |
| **type** | `editprocess` |
| **ableFlag** | `{{getglobalvar::toggle_choicemodule_noparty}}` |

---

## 패턴 (Pattern)

```regex
\s*<party>OOC:.*?</party>
```

**플래그**: `gs`

---

## 치환 (Replace)

(빈 문자열)

---

## 설명

파티 보조 토글이 OFF일 때 (`toggle_choicemodule_noparty` 가 활성화된 경우),
AI에게 보내는 컨텍스트에서 `<party>OOC: ...</party>` 블록 전체를 제거합니다.

파티원이 주사위를 굴려도 AI에게 보조 instructions가 전달되지 않아,
다른 시스템은 유지하면서 파티 보조 시스템만 끌 수 있습니다.
