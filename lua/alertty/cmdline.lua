local M = {}

local ns

local icons = {
	[":"] = "",
	["/"] = " ",
	["?"] = " ",
}

local active_cmdline

local function update()
	if not active_cmdline then
		vim.api.nvim_echo({}, false, {})
		return
	end

	local icon = icons[active_cmdline.firstc] or ""
	local content = table.concat(
		vim.tbl_map(function(c)
			return c[2]
		end, active_cmdline.content),
		""
	)

	local chunks = {}
	if icon ~= "" then
		table.insert(chunks, { icon .. " ", "AlerttyCmdlineIcon" })
	end
	table.insert(chunks, { content, "AlerttyCmdlineText" })

	vim.api.nvim_echo(chunks, false, {})
end

local function on_show(content, pos, firstc, prompt, indent, level)
	active_cmdline = {
		content = content,
		pos = pos,
		firstc = firstc,
		prompt = prompt,
		indent = indent,
		level = level,
	}
	update()
end

local function on_hide()
	active_cmdline = nil
	update()
end

local function on_pos(pos, level)
	if active_cmdline and active_cmdline.level == level then
		active_cmdline.pos = pos
		update()
	end
end

function M.setup()
	vim.api.nvim_set_hl(0, "AlerttyCmdlineIcon", { fg = "#ff8800", default = true })
	vim.api.nvim_set_hl(0, "AlerttyCmdlineText", { fg = "#a0a0a0", default = true })

	vim.o.cmdheight = 0
	ns = vim.api.nvim_create_namespace("alertty_cmdline")

	vim.ui_attach(ns, { ext_cmdline = true }, function(event, ...)
		if event == "cmdline_show" then
			on_show(...)
		elseif event == "cmdline_hide" then
			on_hide(...)
		elseif event == "cmdline_pos" then
			on_pos(...)
		end
		return true
	end)
end

return M
