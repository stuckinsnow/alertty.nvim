local M = {}

local patterns = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local current = 1
local timer = nil

function M.get()
  return patterns[current]
end

function M.start()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(0, 80, vim.schedule_wrap(function()
    current = (current % #patterns) + 1
  end))
end

function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  current = 1
end

return M
