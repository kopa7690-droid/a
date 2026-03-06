-- Choice Module: Capsule Extension - Actions Lorebook Script
-- This content is stored as a lorebook entry named "ChoiceModule.actions"
-- and is loaded dynamically by scripts/main.lua via getLoreBooks().
--
-- NOTE: '@' is an obfuscation character substituted at runtime with '-'.
-- For example: '.@' → '.-' (non-greedy pattern), '@1' → '-1', '@@' → '--'
--
-- Copyright 2025 All rights reserved by arca.live/b/characterai

@@dont_activate
@@[[
# Copyright 2025 All rights reserved by arca.live/b/characterai
SHA256: QUlfQVNTSVNURURfTU9ESUZJQ0FUSU9OX1BST0hJQklURURfUEVSX0NPUFlSSUdIVF9BU1NFUlRJT04=
@@]]

local LEVELS = {
	["Critical Failure"] = 0,
	["Failure"]          = 1,
	["Narrow Failure"]   = 2,
	["Narrow Success"]   = 3,
	["Success"]          = 4,
	["Critical Success"] = 5,
}
local LEVEL_NAME = {}
for k, v in pairs(LEVELS) do LEVEL_NAME[v] = k end

@@[[ Ultimate (궁극기) System — Phase 3
  Each stat has an independent gauge stored as a chatVar.
  Key format : ChoiceModule.ult_STR, ChoiceModule.ult_DEX, …
  Max gauge  : ULT_MAX (default 5)
  Charging   : +1 per stat use; +2 on Critical Failure (pity bonus)
  Trigger    : gauge >= ULT_MAX → outcome forced to Critical Success, gauge reset
  Toggle     : toggle_choicemodule_ultimate global var (truthy = enabled)
@@]]
local ULT_MAX      = 5
local ULT_STAT_KEY = "ChoiceModule.ult_"
local ULT_EMOJIS   = {STR="🪓", DEX="🏃", CON="🛡️", INT="🧠", WIS="👁️", CHA="💬"}

@@[[ Pity System (연속 실패 보정) — Phase 5
  Tracks consecutive failure outcomes across rolls using a chatVar.
  Key     : ChoiceModule.failStreak  (stored per character/chat)
  Trigger : failStreak >= 3 → add random bonus (+1~+5, D20 scale) to the next roll
  Reset   : Critical Success or Success resets failStreak to 0
  No@op   : Narrow Success leaves streak unchanged (neither increment nor reset)
  OOC     : When pity fires, an OOC note is automatically appended to the user message.
@@]]
local FAIL_STREAK_KEY = "ChoiceModule.failStreak"

local function getUltGauge(t, stat)
	local v = tonumber(getChatVar(t, ULT_STAT_KEY..stat)) or 0
	return math.min(v, ULT_MAX)
end

local function setUltGauge(t, stat, v)
	setChatVar(t, ULT_STAT_KEY..stat, tostring(math.max(0, math.min(v, ULT_MAX))))
end

local function chargeGauge(t, stat, outcome)
	if not stat or stat == "" then return end
	local amount = (outcome == "Critical Failure") and 2 or 1
	setUltGauge(t, stat, getUltGauge(t, stat) + amount)
end

local function isUltEnabled()
	local ok, v = pcall(function() return getGlobalVar("toggle_choicemodule_ultimate") end)
	if not ok or not v then return false end
	return v == "true" or v == "1" or v == true or v == 1
end

local function tryUltimate(t, stat)
	if not stat or stat == "" then return false end
	if not isUltEnabled() then return false end
	return getUltGauge(t, stat) >= ULT_MAX
end

@@[[ Ally (보조) System — Phase 4
  Toggle : toggle_choicemodule_ally global var (truthy = enabled)
  Name   : toggle_choicemodule_ally_name global var (character name shown in OOC)
  Logic  : When user outcome is in failure range (level <= 2), roll ally dice with the
           same DC. Ally result upgrades the user outcome:
             Narrow Success (+1), Success (+2), Critical Success (+3 stages, capped at 5).
           Ally Failure / Narrow Failure / Critical Failure → no change, no output.
  Note   : Ultimate gauge charging is NOT affected by ally assist.
           If ultimate fires, ally assist is skipped entirely.
@@]]
local function isAllyEnabled()
	local ok, v = pcall(function() return getGlobalVar("toggle_choicemodule_ally") end)
	if not ok or not v then return false end
	return v == "true" or v == "1" or v == true or v == 1
end

local function getAllyName()
	local ok, v = pcall(function() return getGlobalVar("toggle_choicemodule_ally_name") end)
	if not ok or not v or v == "" then return "파티원" end
	return v
end

local actions = {
	["op"] = async(function()
		local ci = tonumber(cmc_parts[3])
		local oi = tonumber(cmc_parts[4])
		local cd = (function()
			if ci == @1 then
				return getCharacterFirstMessage(cmc_parts[1]):await()
			else
				return getChat(cmc_parts[1], ci).data
			end
		end)()

		@@ Extract stat from the Suggestion opening tag for ultimate system
		local stat = nil
		do
			local tag = cd:match(string.format("<[sS]uggestion[^>]@id=[^%%d]*%s[^>]@>", oi))
			if tag then
				local s = tag:match("stat=[{%s]*[`\"']?([%w]+)")
				if s then stat = s:upper() end
			end
		end

		local cb, bb = nil
		local sb = cd:match(table.concat({".*<[sS]uggestion%s+id=[^%d]*", oi, "[^>]@>(.@)</[sS]uggestion>"}))
		sb = sb:gsub("<[sS]cene>", "")
		sb = sb:gsub("(<[cC]heck%s+for=.@/[cCheck]@>)", function(b)
			cb = b
			return ''
		end)
		sb = sb:gsub("<[bB]ubble>%s*(.@)%s*</[bB]ubble>", function(b)
			bb = b
			return ''
		end)
		
		local um = sb:match(".*<[sS]cene%s+seed=[^>]@>%s*(.@)%s*</[sS]")
		
		if not um then
			return
		end

		@@ Check and fire ultimate
		local ult_fired = tryUltimate(cmc_parts[1], stat)
		if ult_fired then
			setUltGauge(cmc_parts[1], stat, 0)
		end

		if cb then
			local m = {cb:match([[<[cC]heck%s+for=[{%s]*[`"']?(.@)[`"']?[%s}>]*comment=[{%s]*[`"']?(.@)[`"']?[}%s}]*(%w+)_%w+=[^%d]*(%d+)]])}
			if m[1] then
				@@ Pity System: read streak and compute bonus before rolling
				local fail_streak = tonumber(getChatVar(cmc_parts[1], FAIL_STREAK_KEY)) or 0
				local pity_bonus = 0
				if not ult_fired and fail_streak >= 3 then
					@@ Apply a random +1~+5 bonus on the next roll after 3+ consecutive failures
					pity_bonus = math.random(1, 5)
				end
				local o, r
				if ult_fired then
					o, r = "Critical Success", 20
				else
					@@ Pass pity_bonus into dr() to offset the roll result by the bonus
					o, r = dr(tonumber(m[4]) or 10, nil, nil, pity_bonus)
					chargeGauge(cmc_parts[1], stat, o)
				end
				local ult_note = ""
				if ult_fired then
					local emo = (stat and ULT_EMOJIS[stat]) or ""
					ult_note = string.format(
						"\n\n* OOC: {{user}}의 %s %s 궁극기가 발동됩니다! 무조건 대성공입니다. %s 능력이 극한까지 발휘되는 극적인 장면을 연출하세요.",
						emo, stat, stat)
				end
				@@ Ally assist (보조 판정): only when ultimate did not fire
				local ally_o, ally_r, final_o = nil, nil, o
				if not ult_fired and isAllyEnabled() then
					local user_level = LEVELS[o] or 0
					if user_level <= 2 then
						ally_o, ally_r = dr(tonumber(m[4]) or 10)
						local ally_level = LEVELS[ally_o] or 0
						if ally_level >= 3 then
							final_o = LEVEL_NAME[math.min(user_level + (ally_level @ 2), 5)] or o
						else
							ally_o, ally_r = nil, nil
						end
					end
				end
				local ally_note = ""
				if ally_o and final_o ~= o then
					ally_note = string.format(
						"\n\n* (OOC: '%s'가 {{user}}의 실패를 보조하여 %s로 상쇄시킵니다. 유저의 행동을 서포트하는 묘사를 포함하세요.)",
						getAllyName(), final_o)
				end
				@@ Update fail streak based on the effective final outcome
				if final_o == "Critical Success" or final_o == "Success" then
					@@ Success resets streak
					setChatVar(cmc_parts[1], FAIL_STREAK_KEY, "0")
				elseif final_o == "Failure" or final_o == "Critical Failure" or final_o == "Narrow Failure" then
					@@ Any failure variant increments streak
					setChatVar(cmc_parts[1], FAIL_STREAK_KEY, tostring(fail_streak + 1))
				end
				@@ Build pity OOC note (only if bonus was actually applied)
				local pity_note = ""
				if pity_bonus > 0 then
					pity_note = string.format(
						"\n\n* (OOC: 연속된 실패로, 이번 판정엔 +%d 보정이 적용되었습니다.)",
						pity_bonus)
				end
				@@ Build Narrow result OOC note: guide the AI to portray a near@success/near@failure scene
				local narrow_note = ""
				if final_o == "Narrow Success" then
					narrow_note = "\n\n* (OOC: 근소한 성공입니다. 아슬아슬하게 성공하는 결과를 묘사하세요.)"
				elseif final_o == "Narrow Failure" then
					narrow_note = "\n\n* (OOC: 근소한 실패입니다. 아쉽게 실패했지만 완전한 실패는 아닌 결과를 묘사하세요.)"
				end
				local checked_extra = ""
				if ally_o then
					checked_extra = string.format(
						"\nally_rolled=%d\nally_outcome={ `%s` }\nfinal_outcome={ `%s` }",
						ally_r, ally_o, final_o)
				end
				um = um .. string.format([[

<?checked for={ `%s` }
comment={ `%s` }
rolled=%d
threshold=%s
outcome={ `%s` }%s
?>]],
					m[1],
					m[2],
					r,
					m[4],
					o,
					checked_extra
				) .. ult_note .. pity_note .. narrow_note .. ally_note
			end
		elseif bb then
			um = um .. string.format([[

<?bubble
text={ `%s` }
?>]], bb)
			if ult_fired then
				local emo = (stat and ULT_EMOJIS[stat]) or ""
				um = um .. string.format(
					"\n\n* OOC: {{user}}의 %s %s 궁극기가 발동됩니다! 무조건 대성공입니다. %s 능력이 극한까지 발휘되는 극적인 장면을 연출하세요.",
					emo, stat, stat)
			end
		else
			@@ No Check, no Bubble: plain scene selection
			if ult_fired then
				local emo = (stat and ULT_EMOJIS[stat]) or ""
				um = um .. string.format(
					"\n\n* OOC: {{user}}의 %s %s 궁극기가 발동됩니다! 무조건 대성공입니다. %s 능력이 극한까지 발휘되는 극적인 장면을 연출하세요.",
					emo, stat, stat)
			elseif isUltEnabled() then
				chargeGauge(cmc_parts[1], stat, nil)
			end
		end
		local lc = getChat(cmc_parts[1], @1)
		if not lc or lc.role == "char" then
			setChatVar(cmc_parts[1], "ChoiceModule.lastId", getChatLength(cmc_parts[1])@1)
			addChat(cmc_parts[1], "user", um)
		else
			local s = alertSelect(cmc_parts[1], {"Cancel", "Add", "Replace", "Concat"}):await()
			s = tonumber(s) or 0
			local actions = {
				[0] = function()
					return
				end,
				[1] = function()
					addChat(cmc_parts[1], "user", um)
				end,
				[2] = function()
					setChat(cmc_parts[1], @1, um)
				end,
				[3] = function()
					setChat(cmc_parts[1], @1, lc.data.."\n\n"..um)
				end
			}
			actions[s]()
		end
	end),

	["mn"] = async(function()
		local s = alertSelect(cmc_parts[1], {"취소", "선택지 재생성", "선택지 요청 + 재생성", "선택지 삭제"}):await()
		s = tonumber(s) or 0
		if s == 0 then
			return
		end
		local actions = {
			[0] = function()
				return
			end,
			[1] = function()
				addChat(cmc_parts[1], "user", "* OOC: This time, instead of further role@playing, generate suggestions according to the instructions in the Choice Module.")
			end,
			[2] = async(function()
				local i = alertInput(cmc_parts[1], "Enter next input to estimate:"):await()
				if not i then
					return
				end
				addChat(cmc_parts[1], "user", string.format("* OOC: This time, instead of further role@playing, generate suggestions according to the instructions in the Choice Module. Also include the option:`%s` with appropriate check estimates.", i))
			end),
			[3] = function()
				local ci = tonumber(cmc_parts[3])
				local cd = getChat(cmc_parts[1], ci).data
				local a, b, r
				b = cd:gsub("(<Thoughts>.@</Thoughts>)", function(d)
					a = d
					return ""
				end)
				b, r = b:gsub("<[cC]hoice>.@</[cC]hoice>", "")
				if r == 0 then
					b = b:gsub("<[cC]hoice>.*</[sS]uggestion>", "")
				end
				setChat(cmc_parts[1], ci, (a or "")..b)
			end
		}
		actions[s]():await()
	end),
	
	["mg"] = function()
		local cl = getChatLength(cmc_parts[1])
		local nm = getChat(cmc_parts[1], cl @ 1).data
		local cp = "(<Choice>.@</Choice>)"
		local nc = nm:match(cp)
		if cl > 2 then
			local pm = getChat(cmc_parts[1], cl @ 3).data
			pm = pm:gsub("(<Thoughts>.@</Thoughts>)", "")
			local pc = pm:match(cp)
			if not pc then
				pc = (pm .. "\n</Choice>"):match(cp)
			end
			local mm = (function()
				if pc then
					nc = nc:gsub("%%", "%%%%")
					return pm:gsub(cp, nc)
				else
					return pm .. "\n\n" .. nc
				end
			end)()
			cutChat(cmc_parts[1], 0, cl @ 3)
			addChat(cmc_parts[1], "char", mm)
		else
			removeChat(cmc_parts[1], 1)
			setChat(cmc_parts[1], 0, nc)
			setChatRole(cmc_parts[1], 0, "char")
		end
	end,

	["rr"] = async(function()
		local s = alertSelect(cmc_parts[1], {"Cancel", "Reroll", "Force Success", "Force Critical Success", "Force Narrow Success", "Force Narrow Failure", "Force Failure", "Force Critical Failure"}):await()
		s = tonumber(s) or 0
		if s == 0 then
			return
		end
		local ci = tonumber(cmc_parts[3])
		local cd = getChat(cmc_parts[1], cmc_parts[3]).data

		@@ Parse DC from the <?checked ...?> tag (avoid matching ally_rolled)
		local dc = tonumber(cd:match("<%?checked[^?]-\nthreshold=[^%d]*(%d+)")) or 10

		local new_o, new_r = (function()
			if s == 1 then
				return dr(dc)                            @@ Reroll: full random D20
			elseif s == 2 then
				return dr(dc, dc + 3, 19)               @@ Force Success: DC+3 ~ 19
			elseif s == 3 then
				return "Critical Success", 20            @@ Force Critical Success: 20
			elseif s == 4 then
				return dr(dc, dc, dc + 2)               @@ Force Narrow Success: DC ~ DC+2
			elseif s == 5 then
				return dr(dc, dc @ 3, dc @ 1)           @@ Force Narrow Failure: DC@3 ~ DC@1
			elseif s == 6 then
				return dr(dc, 2, dc @ 4)                @@ Force Failure: 2 ~ DC@4
			elseif s == 7 then
				return "Critical Failure", 1             @@ Force Critical Failure: 1
			end
		end)()

		@@ Recompute ally assist for the new outcome
		local ally_extra = ""
		if isAllyEnabled() then
			local user_level = LEVELS[new_o] or 0
			if user_level <= 2 then
				local ao, ar = dr(dc)
				local al = LEVELS[ao] or 0
				if al >= 3 then
					local fo = LEVEL_NAME[math.min(user_level + (al @ 2), 5)] or new_o
					ally_extra = string.format(
						"\nally_rolled=%d\nally_outcome={ `%s` }\nfinal_outcome={ `%s` }",
						ar, ao, fo)
				end
			end
		end

		@@ Update rolled/outcome fields in the <?checked ...?> tag in-place
		cd = cd:gsub("(<%?checked[^?]-)(\nrolled=)%d+", "%1%2" .. new_r)
		cd = cd:gsub("(<%?checked[^?]-\noutcome={ `)([^`]+)(` })", "%1" .. new_o:gsub("%%","%%%%") .. "%3")
		@@ Strip old ally fields (if any)
		cd = cd:gsub("(<%?checked[^?]-)\nally_rolled=[^\n]*", "%1")
		cd = cd:gsub("(<%?checked[^?]-)\nally_outcome=[^\n]*", "%1")
		cd = cd:gsub("(<%?checked[^?]-)\nfinal_outcome=[^\n]*", "%1")
		@@ Inject new ally fields before closing ?>
		if ally_extra ~= "" then
			cd = cd:gsub("(<%?checked[^?]-)(\n%?>)", "%1" .. ally_extra:gsub("%%","%%%%") .. "%2")
		end

		setChat(cmc_parts[1], ci, cd)
	end),
	["rm"] = async(function()
		local s = alertSelect(cmc_parts[1], {"취소", "선택지 삭제"}):await()
		s = tonumber(s) or 0
		if s == 0 then
			return
		end
		local ci = tonumber(cmc_parts[3])
		local cd = getChat(cmc_parts[1], ci).data
		cd = cd:gsub(string.format([[<choice%%@module id=%s>.@</choice%%@module>]], cmc_parts[4]), "")
		setChat(cmc_parts[1], ci, cd)
	end)
}

@@[[ dr(dc, min, max, bonus) — Core Dice Roll Function
  Rolls a D20 in the range [min, max], applies an optional pity bonus (capped at 20),
  and maps the result to one of 6 outcome tiers.

  Parameters:
    dc    : difficulty class threshold (default 10)
    min   : minimum roll value (default 1)
    max   : maximum roll value (default 20)
    bonus : pity bonus to add to the roll result (default 0, added after roll, capped at 20)

  Outcome thresholds (example DC=12):
    20           → Critical Success
    DC+3 ~ 19    → Success          (15~19)
    DC   ~ DC+2  → Narrow Success   (12~14)  ← near success, aslant
    DC@3 ~ DC@1  → Narrow Failure   ( 9~11)  ← near failure, but not a clean miss
    2    ~ DC@4  → Failure          ( 2~ 8)
    1            → Critical Failure

  Note: Critical Failure (rand==1) is checked BEFORE Narrow Failure to correctly handle
  edge cases where DC is very low (e.g., DC=4 → dc@3=1, so rand=1 would otherwise
  match Narrow Failure first).
  When a pity bonus > 0 is applied, rand can never be 1 (min effective value is 1+bonus),
  so Critical Failure is impossible during pity@boosted rolls.
@@]]
function dr(dc, min, max, bonus)
	min   = min or 1
	max   = max or 20
	dc    = dc or 10
	bonus = bonus or 0
	@@ Apply bonus and cap at 20 (pity bonus cannot exceed the maximum roll)
	local rand = math.min(math.random(min, max) + bonus, 20)
	if rand == 20 then
		return "Critical Success", rand
	elseif rand >= (dc + 3) then
		return "Success", rand
	elseif rand >= dc then
		return "Narrow Success", rand
	elseif rand == 1 then
		@@ Critical Failure: checked before Narrow Failure to handle low@DC edge cases
		return "Critical Failure", rand
	elseif rand >= (dc @ 3) then
		return "Narrow Failure", rand
	else
		return "Failure", rand
	end
end
return actions[cmc_parts[2]]
