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
	local tid = t  -- save trigger ID before any inner callbacks shadow 't'
	local c, r = ""

	-- Extract and temporarily remove <Thoughts> block
	d = d:gsub("(<Thoughts>.-</Thoughts>)", function(e)
		c = e
		return ""
	end)

	-- ── Ultimate (궁극기) gauge bar ────────────────────────────────────────────
	-- Reads per-stat gauges from chatVar and renders a compact bar row.
	-- Only rendered when toggle_choicemodule_ultimate is truthy.
	local function buildGaugeBar(cid)
		local ult_on = getGlobalVar(cid, "toggle_choicemodule_ultimate")
		if not ult_on or ult_on == "false" or ult_on == "0" then
			return ""
		end
		local STATS = {"STR","DEX","CON","INT","WIS","CHA"}
		local EMOJIS = {STR="🪓",DEX="🏃",CON="🛡️",INT="🧠",WIS="👁️",CHA="💬"}
		local MAX = 5
		local parts = {}
		for _, s in ipairs(STATS) do
			local g = math.min(tonumber(getChatVar(cid, "ChoiceModule.ult_"..s)) or 0, MAX)
			local ico = (g >= MAX) and "🔥" or EMOJIS[s]
			table.insert(parts, ico.." "..s.." ["..string.rep("█",g)..string.rep("░",MAX-g).."] "..g.."/"..MAX)
		end
		return '<div class="choicemodule-ult-gauge">'..table.concat(parts, "  ").."</div>"
	end
	local gauge_html  = buildGaugeBar(t)
	-- Escape bare '%' so the string is safe to embed in a gsub replacement
	local gauge_safe  = gauge_html:gsub("%%", "%%%%")
	local wh_gauge    = gauge_safe ~= "" and ("\n"..gauge_safe) or ""

	-- Wrapper template: <Choice> → checkbox toggle
	local wh = [[<p></p>
<label>
<input type="checkbox" class="choicemodule-toggle" />
<div class="choicemodule-wrapper">
%1]] .. wh_gauge .. [[
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
		d = d:gsub("<[sS]uggestion(%s[^>]-)>%s*(.-)%s*</[sS]uggestion>%s-",
		function(attrs, d)
			local i = attrs:match("id=[^%d]*(%d+)")
			if not i then return "" end
			local stat_raw = attrs:match("stat=[{%s]*[`\"']?([%w]+)")
			local stat = stat_raw and stat_raw:upper()
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
			-- Determine ultimate-ready glow class (BETA)
			local ult_class = ""
			if stat then
				local ult_on = getGlobalVar(tid, "toggle_choicemodule_ultimate")
				if ult_on and ult_on ~= "false" and ult_on ~= "0" then
					local gauge = tonumber(getChatVar(tid, "ChoiceModule.ult_"..stat)) or 0
					if gauge >= 5 then
						ult_class = " choicemodule-ult-ready"
					end
				end
			end
			return table.concat({[[<button risu-btn="choicemodule_op_{{chat_index}}_]], i, [[" class="choicemodule-button]], ult_class, [[">]], d, "</button>\n"})
		end)
	else
		-- Convert <?checked ...?> dice result → interactive dice table UI
		-- Supports new 3-block format (checked + support + final) and legacy single-block format

		-- Shared renderer: builds the dice table HTML for both formats
		local function renderDiceHTML(rolled, thresh, outcome, ally_rolled, ally_o, final_o)
			local has_ally = ally_rolled and ally_o and ally_o ~= "" and final_o and final_o ~= ""
			local ov = has_ally and final_o or outcome
			local function esc(s) return (s or ""):gsub("%%","%%%%") end

			-- Ally summary block shown only when dice results are visible (non-hidden mode)
			local ally_block = ""
			if has_ally then
				ally_block =
					"{{#if_pure {{? {{gettempvar::cmh}}=0}}}}" ..
					"<div class=\"dicemodule-ally\">" ..
					"🤝 보조: [ " .. esc(ally_rolled) .. " ] → " .. esc(ally_o) ..
					" ｜ 최종: [ " .. esc(final_o) .. " ]" ..
					"</div>{{/}}"
			end

			return
				"{{#if_pure {{? {{getglobalvar::toggle_choicemodule_hidden}}&{{getvar::ChoiceModule.lastId}}>0}}}}" ..
				"{{settempvar::cmh::{{? {{chat_index}}>{{getvar::ChoiceModule.lastId}}}}}}" ..
				"{{/}}{{settempvar::cmt::{{? {{chat_index}}<({{lastmessageid}}-6)}}}}" ..
				"{{#if {{gettempvar::cmt}}}}\n<details>\n  <summary>🎲 주사위</summary>\n{{/}}" ..
				"<table class=\"dicemodule-table\">\n" ..
				"<tr><td><strong>Rolled:</td>\n" ..
				"<td><b>{{#if_pure {{? {{gettempvar::cmh}}=0}}}}\n" ..
				"[ " .. esc(rolled) .. " ]</td>\n" ..
				"<td rowspan=\"3\" style=\"vertical-align: bottom\"><center>\n" ..
				"<button risu-btn=\"choicemodule_rr_{{chat_index}}\">\n" ..
				"<div class=\"dicemodule-cube dicemodule-throw\">\n" ..
				"<div class=\"dicemodule-side dicemodule-side1\">" .. esc(rolled) .. "</div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side2\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side3\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side4\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side5\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side6\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-cover dicemodule-cover-x\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-cover dicemodule-cover-y\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-cover dicemodule-cover-z\"></div>\n" ..
				"</div></button></td></tr>\n" ..
				"<tr><td><strong>Difficulty:</td>\n" ..
				"<td><b>[ " .. esc(thresh) .. " ]</td></tr>\n" ..
				"<tr><td><strong>Outcome:</td>\n" ..
				"<td><b>" .. esc(ov) .. "{{/}}{{#if_pure {{gettempvar::cmh}}}}\n" ..
				"[ ? ]</td>\n" ..
				"<td rowspan=\"3\" style=\"vertical-align: bottom\"><center>\n" ..
				"<div class=\"dicemodule-cube dicemodule-throw\">\n" ..
				"<div class=\"dicemodule-side dicemodule-side1\">?</div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side2\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side3\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side4\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side5\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-side6\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-cover dicemodule-cover-x\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-cover dicemodule-cover-y\"></div>\n" ..
				"<div class=\"dicemodule-side dicemodule-cover dicemodule-cover-z\"></div>\n" ..
				"</div></td></tr>\n" ..
				"<tr><td><strong>Difficulty:</td>\n" ..
				"<td><b>[ " .. esc(thresh) .. " ]</td></tr>\n" ..
				"<tr><td><strong>Outcome:</td>\n" ..
				"<td><b>[ ? ]{{/}}\n" ..
				"</td></tr><tr></table>" .. ally_block .. "<div></div>\n" ..
				"{{#if_pure {{gettempvar::cmt}}}}</details>{{/}}"
		end

		-- First pass: new 3-block format (<?checked?> + <?'ally' support checked?> + <?final checked?>)
		d = d:gsub("<%?checked(.-)%?>%s*<%?'([^']*)'%s+support%s+checked(.-)%?>%s*<%?final%s+checked(.-)%?>",
			function(b1, _ally_name, b2, b3)
				local rolled = b1:match("rolled=(%d+)")
				local thresh = b1:match("threshold=[^%d]*(%d+)")
				local outcome_raw = b1:match("outcome={%s*`([^`]+)`")
				if not rolled or not thresh or not outcome_raw then return end
				local outcome = outcome_raw:match("^%s*(.-)%s*$") or outcome_raw
				local ally_rolled = b2:match("rolled=(%d+)")
				local ally_o_raw = b2:match("outcome={%s*`([^`]+)`")
				local ally_o = ally_o_raw and (ally_o_raw:match("^%s*(.-)%s*$") or ally_o_raw) or ""
				local final_o_raw = b3:match("outcome={%s*`([^`]+)`")
				local final_o = final_o_raw and (final_o_raw:match("^%s*(.-)%s*$") or final_o_raw) or ""
				return renderDiceHTML(rolled, thresh, outcome,
					ally_rolled, ally_o ~= "" and ally_o or nil, final_o ~= "" and final_o or nil)
			end)

		-- Second pass: legacy/standalone checked blocks (single block, may have old ally fields)
		d = d:gsub("<%?checked(.-)%?>", function(block)
			local rolled  = block:match("rolled=(%d+)")
			local thresh  = block:match("threshold=[^%d]*(%d+)")
			local outcome = block:match("outcome={%s*`?([%w%s]+)[`%s}]")
			if not rolled or not thresh or not outcome then return end
			outcome = outcome:match("^%s*(.-)%s*$") or outcome
			local ally_rolled = block:match("ally_rolled=(%d+)")
			local ao = (block:match("ally_outcome={%s*`?([%w%s]+)[`%s}]") or ""):match("^%s*(.-)%s*$")
			local fo = (block:match("final_outcome={%s*`?([%w%s]+)[`%s}]") or ""):match("^%s*(.-)%s*$")
			return renderDiceHTML(rolled, thresh, outcome,
				ally_rolled, ao ~= "" and ao or nil, fo ~= "" and fo or nil)
		end)
	end
	-- OOC 노트 숨기기: AI 지시용 메모를 유저 화면에서 제거
	d = d:gsub("\n*%*%s*%(OOC:.-%)%s*", "")
	d = d:gsub("\n*%*%s*OOC:.-\n", "\n")
	d = d:gsub("\n*%*%s*OOC:.-$", "")
	return c..d
end)

cmc_parts = {}
