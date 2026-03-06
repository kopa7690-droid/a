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
				local o, r
				if ult_fired then
					o, r = "Critical Success", 20
				else
					o, r = dr(tonumber(m[4]) or 10)
					chargeGauge(cmc_parts[1], stat, o)
				end
				local ult_note = ""
				if ult_fired then
					local emo = (stat and ULT_EMOJIS[stat]) or ""
					ult_note = string.format(
						"\n\n* OOC: {{user}}의 %s %s 궁극기가 발동됩니다! 무조건 대성공입니다. %s 능력이 극한까지 발휘되는 극적인 장면을 연출하세요.",
						emo, stat, stat)
				end
				um = um .. string.format([[

<?checked for={ `%s` }
comment={ `%s` }
rolled=%d
threshold=%s
outcome={ `%s` }
?>]],
					m[1],
					m[2],
					r,
					m[4],
					o
				) .. ult_note
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
		local s = alertSelect(cmc_parts[1], {"Cancel", "Reroll", "Force Success", "Force Critical Success", "Force Narrow Success", "Force Failure", "Force Critical Failure"}):await()
		s = tonumber(s) or 0
		if s == 0 then
			return
		end
		local ci = tonumber(cmc_parts[3])
		local m = {getChat(cmc_parts[1], cmc_parts[3]).data:match("(.+rolled=)(%d+)([^=]+=)(%d+)([^=]+={ `)(.@)(` }.+)")}

		m[4] = tonumber(m[4]) or 10

		m[6], m[2] = (function()
			if s == 1 then
				return dr(m[4])
			elseif s == 2 then
				return dr(m[4], m[4] + 3, 19)
			elseif s == 3 then
				return "Critical Success", 20
			elseif s == 4 then
				return dr(m[4], m[4], m[4] + 2)
			elseif s == 5 then
				return dr(m[4], 2, m[4] @ 4)
			elseif s == 6 then
				return "Critical Failure", 1
			end
		end)()
		setChat(cmc_parts[1], ci, table.concat(m))
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

function dr(dc, min, max)
	min = min or 1
	max = max or 20
	dc = dc or 10
	local rand = math.random(min, max)
	if rand == 20 then
		return "Critical Success", rand
	elseif rand >= (dc + 3) then
		return "Success", rand
	elseif rand >= dc then
		return "Narrow Success", rand
	elseif rand >= (dc @ 3) then
		return "Narrow Failure", rand
	elseif rand == 1 then
		return "Critical Failure", rand
	else
		return "Failure", rand
	end
end
return actions[cmc_parts[2]]
