# 🗑️ Request: Strip Dice — 주사위 블록 제거 (AI용)

## 항목 정보

| 필드 | 값 |
|------|---|
| **name** | `🗑️ Request: Strip Dice` |
| **type** | `editprocess` |
| **ableFlag** | `true` |

---

## 패턴 (Pattern)

```regex
[\s`]*<\?checked\s+for=.+?\?>[`\s]*
```

**플래그**: `gs`

---

## 치환 (Replace)

```
(빈 문자열 — 아무것도 넣지 않음)
```

---

## 설명

AI에게 보내는 컨텍스트에서 `<?checked ... ?>` 블록 전체를 제거합니다.
주사위 숫자(rolled, threshold)를 AI에게 노출하지 않기 위함입니다.

AI가 참고할 정보(instructions, OOC 메모)는 블록 바깥에 있으므로 유지됩니다.
