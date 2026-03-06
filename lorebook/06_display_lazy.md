# 🖥️ Display: Lazy — 지연 로딩 선택지 표시

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `🖥️ Display: Lazy` |
| **type** | `editdisplay` |

---

## 패턴 (Pattern)

```regex
<lb-lazy id[entifr]="" choicemodule="" [=""><]*\/[lb\-lazy]*>\n?
```

---

## 치환 (Replace)

```html
{{#if {{greater_equal::{{chat_index}}::{{lastmessageid}}}}}}
<div class="lb-module-root" data-id="lb-choicemodule">
  <button class="lb-lazyloader" risu-btn="lb-reroll__ChoiceModule">
    <span class="lb-opener">
      <span>⚖️ 선택지 불러오기<lb-reroll-icon></lb-reroll-icon></span>
    </span>
  </button>
</div>
{{/if}}
```

---

## 설명

`<lb-lazy>` 태그가 감지되면 **"⚖️ 선택지 불러오기"** 버튼을 렌더링합니다.  
선택지를 즉시 로드하지 않고, 사용자가 버튼을 클릭할 때 로드하는 **지연 로딩(Lazy Load)** 방식입니다.

- 최신 메시지(`chat_index >= lastmessageid`)에서만 표시
- `risu-btn="lb-reroll__ChoiceModule"`: 클릭 시 선택지 재생성 요청
