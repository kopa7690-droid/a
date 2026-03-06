-- Copyright 2025 All rights reserved by arca.live/b/characterai
-- Choice Module: Capsule Extension - Main Trigger Script
-- Type: start / triggerlua / lowLevelAccess: true

cmc_hash = "QUlfQVNTSVNURURfTU9ESUZJQ0FUSU9OX1BST0hJQklURURfUEVSX0NPUFlSSUdIVF9BU1NFUlRJT04="

-- ── Button Click Handler ────────────────────────────────────────────────────
-- Dispatches button actions: op (option), rr (reroll), rm (remove)
onButtonClick = async(function(t, c)
	cmc_parts = {}
	for m in (c.."_"):gmatch("(.-)".."_") do
		table.insert(cmc_parts, m)
	end
	if #cmc_parts < 2 or cmc_parts[1] ~= "choicemodule" then
		return
	end
	xpcall(function()
		local mn = cmc_hash:byte(cmc_hash:byte(2)-cmc_hash:byte(1))
		cmc_parts[1] = t
		return load(getLoreBooks(t, 'ChoiceModule.actions')[1].content:gsub(string.char(mn-38), string.char(mn-cmc_hash:byte(19))))()():await()
	end, function(err)
		--print(err)
	end)
end)

-- ── Output Hook ─────────────────────────────────────────────────────────────
-- Saves the last chat message index after AI output for UI tracking
onOutput = async(function(t)
	local l = getChatLength(t)-2
	setChatVar(t, "ChoiceModule.lastId", l)
	reloadChat(t, l)
end)

-- ── Display Edit Hook ───────────────────────────────────────────────────────
-- Converts choice/dice XML tags into interactive HTML UI elements
listenEdit("editDisplay", function(t, d)
	local c, r = ""

	-- Extract and temporarily remove <Thoughts> block
	d = d:gsub("(<Thoughts>.-</Thoughts>)", function(e)
		c = e
		return ""
	end)

	-- Wrapper template: <Choice> → checkbox toggle
	local wh = [[<p></p>
<label>
<input type="checkbox" class="choicemodule-toggle" />
<div class="choicemodule-wrapper">
%1
</div>
</label>]]

	-- Pattern 1: <Choice>...</Choice>
	d, r = d:gsub("<[cC]hoice>(.-)</[cC]hoice>", wh)

	-- Pattern 2: <Choice>...</Suggestion> (unclosed)
	if r == 0 then
		d, r = d:gsub("<[cC]hoice>(.+</[sS]uggestion>)%s*", wh)
	end

	-- Pattern 3: <ChoiceModule ...>...</ChoiceModule> → collapsible details UI
	if r == 0 then
		d, r = d:gsub("<[cC]hoice[^>o]-odule([^>]-)>(.-)</[cC]hoice[^>o]-odule>", function(a, d)
			local i = a:match("id=(%d+)") or ""
			if i ~= "" then
				i = string.format(
[[
<button risu-btn="choicemodule_rm_{{chat_index}}_%s" class="choicemodule-button choicemodule-anchor choicemodule-anchor2">
<div class="choicemodule-bubble">선택지 목록 제거</div>
</button>
]], i)
			end
			return table.concat({
[[
<div data-id="lb-choicemodule" class="lb-module-root">
<details name="ChoiceModule" class="lb-collapsible">
<summary class="lb-opener">
<span>⚖️ 선택지</span>
</summary>
<div class="choicemodule-wrapper-lb">
<button risu-btn="lb-interaction__ChoiceModule__SpecificRequest" class="choicemodule-button choicemodule-anchor">
<lb-comment-icon />
<div class="choicemodule-bubble">특정 선택지 요청</div>
</button>
]], i, d,
[[
</div>
</details>
<button type="button" risu-btn="lb-reroll__ChoiceModule" class="lb-reroll">
<lb-reroll-icon />
</button>
</div>
]]})
		end)
	end

	-- Convert <Suggestion id=N>...</Suggestion> → clickable buttons
	if r > 0 then
		d = d:gsub("<[sS]uggestion%s+id=[^%d]-(%d+)[^>]->%s*(.-)%s*</[sS]uggestion>%s-",
		function(i, d)
			local b = ""
			-- Extract <Check> dice info into bubble tooltip
			d, r = d:gsub([[%s*<[cC]heck%s+for=[{%s]*[`"']?(.-)[`"']?[%s}>]*comment=[{%s]*[`"']?(.-)[`"']?[%s}]*(%w*)_%w*=[^%d]*([%d]+).->%s*]], function(f, c, t, o)
				if t == "success" then
					b = string.format("<div class=\"choicemodule-bubble\">%s</div>🎲 %s: <strong> [ %s%% ]</strong>", c, f, o)
				else
					b = string.format("<div class=\"choicemodule-bubble\">%s</div>🎲 %s: <strong> [ %s ]</strong>", c, f, o)
				end
				return ""
			end)
			-- Extract <Bubble> custom tooltip
			if r == 0 then
				d, r = d:gsub("%s*<[bB]ubble>%s*(.-)%s*</[bB]ubble>%s*", function(f)
					b = string.format([[<div class="choicemodule-bubble choicemodule-bubble2">%s</div>]], f)
					return ""
				end)
			end
			-- Render <Scene seed=... >...</Scene>
			d = d:gsub([[<[sS]cene%s+seed=[{%s]*[`"']?(.-)[`"']?[}%s]*>[%s{`]*(.-)[`}%s]*</[sS]cene>]], function(seed, scene)
				return table.concat({"<p>🧩 ", seed:gsub("`", ""), "</p><p>📜 ", scene, "</p>", b})
			end)
			d = d:gsub("%s*<[sS]cene[^>]->%s*", "")
			return table.concat({[[<button risu-btn="choicemodule_op_{{chat_index}}_]], i, [[" class="choicemodule-button">]], d, "</button>\n"})
		end)
	else
		-- Convert <?checked ...?> dice result → interactive dice table UI
		d, r = d:gsub("<%?checked.-rolled=(.-)%s*threshold=[^%d]*(%d+)[^%s]*%s*outcome={ `?([%w%s]+)[^%?]+%?>",
[[{{#if_pure {{? {{getglobalvar::toggle_choicemodule_hidden}}&{{getvar::ChoiceModule.lastId}}>0}}}}{{settempvar::cmh::{{? {{chat_index}}>{{getvar::ChoiceModule.lastId}}}}}}{{/}}{{settempvar::cmt::{{? {{chat_index}}<({{lastmessageid}}-6)}}}}{{#if {{gettempvar::cmt}}}}
<details>
  <summary>🎲 주사위</summary>
{{/}}<table class="dicemodule-table">
<tr><td><strong>Rolled:</td>
<td><b>{{#if_pure {{? {{gettempvar::cmh}}=0}}}}
[ %1 ]</td>
<td rowspan="3" style="vertical-align: bottom"><center>
<button risu-btn="choicemodule_rr_{{chat_index}}">
<div class="dicemodule-cube dicemodule-throw">
<div class="dicemodule-side dicemodule-side1">%1</div>
<div class="dicemodule-side dicemodule-side2"></div>
<div class="dicemodule-side dicemodule-side3"></div>
<div class="dicemodule-side dicemodule-side4"></div>
<div class="dicemodule-side dicemodule-side5"></div>
<div class="dicemodule-side dicemodule-side6"></div>
<div class="dicemodule-side dicemodule-cover dicemodule-cover-x"></div>
<div class="dicemodule-side dicemodule-cover dicemodule-cover-y"></div>
<div class="dicemodule-side dicemodule-cover dicemodule-cover-z"></div>
</div></button></td></tr>
<tr><td><strong>Difficulty:</td>
<td><b>[ %2 ]</td></tr>
<tr><td><strong>Outcome:</td>
<td><b>%3{{/}}{{#if_pure {{gettempvar::cmh}}}}
[ ? ]</td>
<td rowspan="3" style="vertical-align: bottom"><center>
<div class="dicemodule-cube dicemodule-throw">
<div class="dicemodule-side dicemodule-side1">?</div>
<div class="dicemodule-side dicemodule-side2"></div>
<div class="dicemodule-side dicemodule-side3"></div>
<div class="dicemodule-side dicemodule-side4"></div>
<div class="dicemodule-side dicemodule-side5"></div>
<div class="dicemodule-side dicemodule-side6"></div>
<div class="dicemodule-side dicemodule-cover dicemodule-cover-x"></div>
<div class="dicemodule-side dicemodule-cover dicemodule-cover-y"></div>
<div class="dicemodule-side dicemodule-cover dicemodule-cover-z"></div>
</div></td></tr>
<tr><td><strong>Difficulty:</td>
<td><b>[ %2 ]</td></tr>
<tr><td><strong>Outcome:</td>
<td><b>[ ? ]{{/}}
</td></tr><tr></table><div></div>
{{#if_pure {{gettempvar::cmt}}}}</details>{{/}}]])
	end
	return c..d
end)

cmc_parts = {}
