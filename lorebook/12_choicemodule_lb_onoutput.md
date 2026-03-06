# ChoiceModule.lb.onOutput — LightBoard 출력 후처리 (Lua)

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `ChoiceModule.lb.onOutput` |
| **bookVersion** | `2` |

---

## 콘텐츠 (Content)

```lua
function onOutput(triggerId, output)
  if not string.find(output, "</lb%-choice>") then
    output = output .. '\n</lb-choice>'
  end
  
  local ct = os.time()

  output = output:gsub("<lb%-choice>(.-)</lb%-choice>", function(data)
    return string.format("<choice-module id=%d>%s</choice-module>", ct, data)
  end)

  output = output:gsub("<[sS]uggestion%s+id=[{%s]-(%d+)[%s}]-", function(id)
    return string.format("<Suggestion id={ %d }", tonumber(id) + ct)
  end)

  return output
end

return onOutput
```

---

## 설명

LightBoard 모드에서 AI 출력을 후처리하는 Lua 함수입니다.

- `</lb-choice>` 닫는 태그가 없으면 자동으로 추가
- `os.time()`으로 현재 타임스탬프(`ct`)를 생성
- `<lb-choice>...</lb-choice>` 블록을 `<choice-module id=TIMESTAMP>...</choice-module>`으로 변환
- 각 `<Suggestion id=N>`의 ID에 타임스탬프를 더해 전역적으로 유일한 ID를 부여
  - 예: `<Suggestion id={ 1 }>` → `<Suggestion id={ 1 + ct }>`
