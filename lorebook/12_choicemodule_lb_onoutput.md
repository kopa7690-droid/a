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

  -- Parse <Director> block and store values as chatVar
  local director = output:match("<Director>(.-)</Director>")
  if director then
    local tension = director:match('level=[{%s]*[`"\']-?(%w+)')
    if tension then
      setChatVar(triggerId, "ChoiceModule.auto_tension", tension)
    end

    local ally_name = director:match('name=[{%s]*[`"\']-?([^`"\'}>]+)')
    local ally_avail = director:match('available=[{%s]*[`"\']-?(%w+)')
    if ally_avail then
      setChatVar(triggerId, "ChoiceModule.auto_ally", ally_avail)
      if ally_name and ally_name ~= "none" then
        setChatVar(triggerId, "ChoiceModule.auto_ally_name", ally_name)
      else
        setChatVar(triggerId, "ChoiceModule.auto_ally_name", "")
      end
    end

    local dc_min = director:match('suggested_min=[{%s]*[`"\']-?(%d+)')
    local dc_max = director:match('suggested_max=[{%s]*[`"\']-?(%d+)')
    if dc_min then setChatVar(triggerId, "ChoiceModule.auto_dc_min", dc_min) end
    if dc_max then setChatVar(triggerId, "ChoiceModule.auto_dc_max", dc_max) end

    local diff_mod = director:match('value=[{%s]*[`"\']-?(%-?%d+)')
    if diff_mod then setChatVar(triggerId, "ChoiceModule.auto_diff_mod", diff_mod) end

    -- Remove Director block from output (not needed in UI)
    output = output:gsub("<Director>.-</Director>%s*", "")
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
- **Director 파싱**: `<Director>...</Director>` 블록이 있으면 `tension`, `ally`, `ally_name`, `dc_min`, `dc_max`, `diff_mod` 값을 `ChoiceModule.auto_` 접두사를 가진 chatVar에 저장하고, 출력에서 블록을 제거합니다.
- `os.time()`으로 현재 타임스탬프(`ct`)를 생성
- `<lb-choice>...</lb-choice>` 블록을 `<choice-module id=TIMESTAMP>...</choice-module>`으로 변환
- 각 `<Suggestion id=N>`의 ID에 타임스탬프를 더해 전역적으로 유일한 ID를 부여
  - 예: `<Suggestion id={ 1 }>` → `<Suggestion id={ 1 + ct }>`
