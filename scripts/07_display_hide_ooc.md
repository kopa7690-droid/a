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
\n*\*\s*\(OOC:.*?\)\s*
```

**플래그**: `gs`

---

## 치환 (Replace)

```
(빈 문자열)
```

---

## 설명

`* (OOC: ...)` 형식의 AI 지시용 메모를 화면에서 제거합니다.

- `\n*` — 앞의 빈 줄도 같이 제거
- `\*\s*` — `* ` 또는 `*` (마크다운 리스트)
- `\(OOC:.*?\)` — `(OOC: 내용)` 전체 (non-greedy)
- `\s*` — 뒤의 공백/개행 정리
- `gs` 플래그: dotall + 전체 치환
