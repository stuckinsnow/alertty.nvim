local M = {}

local config = require("alertty.config")

local win, buf, timer

function M.show_float(msg, hl_group)
  local lines = vim.split(tostring(msg), "\n")

  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.min(config.options.width, math.max(1, unpack(vim.tbl_map(function(l) return #l end, lines))) + 2)
  local height = #lines
  local cfg = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 2,
    row = vim.o.lines - height - 3,
    style = "minimal",
    border = config.options.border,
  }

  if not win or not vim.api.nvim_win_is_valid(win) then
    win = vim.api.nvim_open_win(buf, false, cfg)
  else
    vim.api.nvim_win_set_config(win, cfg)
  end
  
  if hl_group then
    vim.api.nvim_set_option_value("winhighlight", "Normal:" .. hl_group, { win = win })
  end

  if timer then timer:stop() end
  timer = vim.defer_fn(function()
    M.dismiss()
  end, config.options.timeout)
end

function M.dismiss()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
    buf = nil
  end
end

return M
