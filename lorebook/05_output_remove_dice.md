# 🖨️ Output: Remove Dice — 주사위 출력 태그 제거

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `🖨️ Output: Remove Dice` |
| **type** | `editoutput` |
| **ableFlag** | `true` |

---

## 패턴 (Pattern)

```regex
[\s`]*<\?checked\s*for=.+?\?>[`\s]*
```

**플래그**: `gs`

---

## 치환 (Replace)

```
{{br}}{{br}}
```

---

## 설명

출력(output) 단계에서 `<?checked ...?>` 주사위 결과 원문 태그를 제거하고  
두 줄 바꿈(`{{br}}{{br}}`)으로 대체합니다.

- 주사위 표시 UI는 `editdisplay` 단계에서 따로 렌더링됩니다.
- 이 규칙은 AI에게 전달되는 컨텍스트에서 주사위 원문 태그를 정리합니다.
