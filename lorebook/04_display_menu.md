# 🖥️ Display: Menu — 메뉴 버튼 표시 규칙

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `🖥️ Display: Menu` |
| **type** | `editdisplay` |
| **flags** | `g` |

---

## 패턴 (Pattern)

```regex
$
```

(문서 끝에 항상 삽입)

---

## 치환 (Replace)

```
{{#if {{? {{getglobalvar::toggle_choicemodule_menu}}&!{{getglobalvar::toggle_ChoiceModule.mode}} }} }}
{{#if {{equal::{{role}}::char}} }}
{{#if {{? {{lastmessageid}}>0&({{lastmessageid}}={{chat_index}})|({{isfirstmsg}}&({{lastmessageid}}=-1))}}}}
<p></p>
<button class="choicemodule-button choicemodule-circle choicemodule-menu"
        risu-btn="choicemodule_mn_{{chat_index}}">
  <div class="choicemodule-bubble">선택지 모듈 메뉴</div>
</button>
{{#if_pure {{? {{contains::{{lastusermessage}}::* OOC}} & {{contains::{{lastmessage}}::<choice>}} }} }}
<button class="choicemodule-button choicemodule-circle choicemodule-merge"
        risu-btn="choicemodule_mg">
  <div class="choicemodule-bubble">이전 응답에 합치기</div>
</button>
{{/}}
{{/}}
{{/}}
{{/}}
```

---

## 설명

마지막 AI 응답 메시지 끝에 **선택지 모듈 메뉴** 버튼을 표시합니다.

- `toggle_choicemodule_menu`: 메뉴 표시 여부
- `toggle_ChoiceModule.mode`: 모듈 전체 비활성화 여부
- 마지막 메시지(`lastmessageid == chat_index`)에만 표시
- OOC 메시지이고 `<choice>` 태그가 있으면 **이전 응답에 합치기** 버튼도 표시
