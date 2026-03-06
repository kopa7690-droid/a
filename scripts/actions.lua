-- Choice Module: Capsule Extension - Actions Lorebook Script
-- This content is stored as a lorebook entry named "ChoiceModule.actions"
-- and is loaded dynamically by scripts/main.lua via getLoreBooks().
--
-- NOTE: The original source uses '@' as an obfuscated placeholder for '-'
-- that is substituted at runtime. This file contains the decoded version.
--
-- Copyright 2025 All rights reserved by arca.live/b/characterai

local actions = {

-- ── op: Option Selected ────────────────────────────────────────────────
-- Called when the user clicks a <Suggestion> button.
-- Appends the chosen option text to the chat and triggers AI regeneration.
["op"] = async(function()
local pm = getChat(cmc_parts[1], 0).data
local nc = cmc_parts[4]

-- Identify the last user message index
local cmc_len = getChatLength(cmc_parts[1])
local cl = 0
for i = cmc_len - 1, 0, -1 do
if getChat(cmc_parts[1], i).role == "user" then
cl = i
break
end
end

-- Build a pattern from the last user message to find its position in pm
local cp = getChat(cmc_parts[1], cl).data:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
local pc = pm:match(cp)

local mm = (function()
if pc then
nc = nc:gsub("%%", "%%%%")
return pm:gsub(cp, nc)
else
return pm .. "\n\n" .. nc
end
end)()
cutChat(cmc_parts[1], 0, cl - 3)
addChat(cmc_parts[1], "char", mm)
end),

-- ── rr: Reroll Dice ────────────────────────────────────────────────────
-- Called when the user clicks the dice reroll button.
-- Allows cancelling, normal reroll, or forcing specific outcomes.
["rr"] = async(function()
local s = alertSelect(cmc_parts[1], {"Cancel", "Reroll", "Force Success", "Force Critical Success", "Force Failure", "Force Critical Failure"}):await()
s = tonumber(s) or 0
if s == 0 then
return
end
local ci = tonumber(cmc_parts[3])
local m = {getChat(cmc_parts[1], cmc_parts[3]).data:match("(.+rolled=)(%d+)([^=]+=)(%d+)([^=]+={ `)(.-)(`  }.+)")}
local dt = getGlobalVar(cmc_parts[1], "toggle_choicemodule_dice")
dt = tonumber(dt) or 0

-- Default threshold: 50 for D100 mode, 10 for D20 mode
m[4] = tonumber(m[4]) or 50 - 40 * dt

m[6], m[2] = (function()
if s == 1 then
-- Normal reroll
return dr(m[4], dt)
elseif s == 2 then
-- Force Success
if dt == 0 then
return dr(m[4], 0, 0, m[4])
else
return dr(m[4], 1, m[4], 20)
end
elseif s == 3 then
-- Force Critical Success
if dt == 0 then
return dr(m[4], 0, 0, math.min(5, m[4]))
else
return "Critical Success", 20
end
elseif s == 4 then
-- Force Failure
if dt == 0 then
return dr(m[4], 0, m[4] + 1, 100)
else
return dr(m[4], 1, 1, m[4] - 1)
end
elseif s == 5 then
-- Force Critical Failure
if dt == 0 then
return dr(m[4], 0, math.max(95, m[4]), 100)
else
return "Critical Failure", 1
end
end
end)()
setChat(cmc_parts[1], ci, table.concat(m))
end),

-- ── rm: Remove Choice Block ────────────────────────────────────────────
-- Removes a specific <ChoiceModule id=N> block from a chat message.
["rm"] = async(function()
local s = alertSelect(cmc_parts[1], {"취소", "선택지 삭제"}):await()
s = tonumber(s) or 0
if s == 0 then
return
end
local ci = tonumber(cmc_parts[3])
local cd = getChat(cmc_parts[1], ci).data
cd = cd:gsub(string.format([[<choice%%-module id="%s">.-</choice%%-module>]], cmc_parts[4]), "")
setChat(cmc_parts[1], ci, cd)
end)
}

-- ── dr: Dice Roll ──────────────────────────────────────────────────────────
-- Rolls a die and returns the outcome label and numeric value.
--
-- @param o  number  Success threshold (D100) or difficulty class (D20)
-- @param t  number  Dice type: 0 = D100 (percentile), 1 = D20
-- @param min number Optional minimum roll value
-- @param max number Optional maximum roll value
-- @return   string, number  Outcome label, rolled value
function dr(o, t, min, max)
t = t or 0
if t == 0 then
-- D100 percentile mode
min = min or 1
max = max or 100
o = o or max
local rand = math.random(min, max)
if rand <= o then
if rand <= 5 then
return "Critical Success", rand
else
return "Success", rand
end
else
if rand >= 95 then
return "Critical Failure", rand
else
return "Failure", rand
end
end
else
-- D20 mode
min = min or 1
max = max or 20
o = o or min
local rand = math.random(min, max)
if rand >= o then
if rand == 20 then
return "Critical Success", rand
else
return "Success", rand
end
else
if rand == 1 then
return "Critical Failure", rand
else
return "Failure", rand
end
end
end
end

return actions[cmc_parts[2]]
