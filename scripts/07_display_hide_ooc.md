# 🖥️ Display: Hide OOC — OOC 메모 숨김

## 항목 정보

| 필드 | 값 |
|------|---|
| **name** | `🖥️ Display: Hide OOC` |
| **type** | `editdisplay` |
| **ableFlag** | `true` |

---

## 패턴 (Pattern)

```regex
\n*\s*<(?:party|diceresult)>OOC:.*?</(?:party|diceresult)>\s*|\n*\*\s*\(OOC:.*?\)\s*
```

**플래그**: `gs`

---

## 치환 (Replace)

```
(빈 문자열)
```

---

## 설명

AI 지시용 OOC 메모를 화면에서 제거합니다.

신규 XML 태그 형식:
- `<party>OOC: ...</party>` — 파티 보조 instructions
- `<diceresult>OOC: ...</diceresult>` — 주사위 결과 안내

레거시 형식 (이전 버전 호환):
- `* (OOC: ...)` — 이전 단일 포맷

`\n*\s*` / `\s*` — 앞뒤 빈 줄도 같이 제거  
`gs` 플래그: dotall + 전체 치환
