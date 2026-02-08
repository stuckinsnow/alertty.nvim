local M = {}

local ns
local messages = {}
local msg_win
local msg_timer

local icons = {
	[":"] = "",
	["/"] = "",
	["?"] = "",
}

local active_cmdline

local function update_cmdline()
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
	update_cmdline()
end

local function on_hide()
	active_cmdline = nil
	update_cmdline()
end

local function on_pos(pos, level)
	if active_cmdline and active_cmdline.level == level then
		active_cmdline.pos = pos
		update_cmdline()
	end
end

local function hide_msg()
	if msg_timer then
		msg_timer:stop()
		msg_timer = nil
	end
	if msg_win and vim.api.nvim_win_is_valid(msg_win) then
		vim.api.nvim_win_close(msg_win, true)
		msg_win = nil
	end
end

function M.show_msg(text)
	table.insert(messages, { text = text, time = os.time() })

	if #text > 120 then
		text = text:sub(1, 117) .. "..."
	end

	hide_msg()

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

	local width = vim.fn.strdisplaywidth(text)
	local uis = vim.api.nvim_list_uis()
	if #uis == 0 then
		return
	end
	local ui = uis[1]
	local col = ui.width - width - 2

	msg_win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = ui.height - 2,
		col = col,
		width = width,
		height = 1,
		style = "minimal",
		focusable = false,
	})

	local ns_hl = vim.api.nvim_create_namespace("alertty_error_hl")
	vim.api.nvim_buf_set_extmark(buf, ns_hl, 0, 0, {
		end_col = #text,
		hl_group = "AlerttyError",
	})

	msg_timer = (vim.uv or vim.loop).new_timer()
	if msg_timer then
		msg_timer:start(2000, 0, vim.schedule_wrap(hide_msg))
	end
end

function M.setup()
	vim.api.nvim_set_hl(0, "AlerttyCmdlineIcon", { fg = "#ff8800", default = true })
	vim.api.nvim_set_hl(0, "AlerttyCmdlineText", { fg = "#a0a0a0", default = true })
	vim.api.nvim_set_hl(0, "AlerttyError", { link = "ErrorMsg", default = true })

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

	local orig_notify = vim.notify
	local in_notify = false
	vim.notify = function(msg, level, opts)
		if not in_notify and msg and msg ~= "" then
			in_notify = true
			M.show_msg(tostring(msg):gsub("\n", " "))
			in_notify = false
		end
	end

	local orig_echo = vim.api.nvim_echo
	vim.api.nvim_echo = function(chunks, history, opts)
		if history and chunks and #chunks > 0 then
			local text = table.concat(vim.tbl_map(function(c) return c[1] or "" end, chunks), "")
			if text ~= "" then
				M.show_msg(text:gsub("\n", " "))
				return
			end
		end
		orig_echo(chunks, history, opts)
	end

	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		callback = function()
			local diag = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.WARN } })
			if #diag > 0 then
				local d = diag[#diag]
				M.show_msg(d.message:gsub("\n", " "))
			end
		end,
	})

	local orig_err = vim.api.nvim_err_writeln
	vim.api.nvim_err_writeln = function(msg)
		if msg and msg ~= "" then
			local text = tostring(msg):gsub("\n", " ")
			M.show_msg(text)
		end
	end
end

function M.get_messages()
	return messages
end

function M.show_messages()
	if #messages == 0 then
		vim.notify("No messages", vim.log.levels.INFO)
		return
	end

	local has_fzf, fzf = pcall(require, "fzf-lua")
	if not has_fzf then
		vim.notify("fzf-lua not found", vim.log.levels.ERROR)
		return
	end

	local entries = {}
	for _, msg in ipairs(messages) do
		table.insert(entries, string.format("[%s] %s", os.date("%H:%M:%S", msg.time), msg.text))
	end

	fzf.fzf_exec(entries, {
		prompt = "Messages> ",
		previewer = false,
		actions = {
			["default"] = function(selected)
				if selected and selected[1] then
					vim.notify(selected[1], vim.log.levels.INFO)
				end
			end,
		},
	})
end

return M
