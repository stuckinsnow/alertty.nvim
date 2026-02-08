local M = {}

local ui = require("alertty.ui")

local noop = function() end
local noop_str = function() return "" end
local noop_false = function() return false end

function M.inject()
  package.loaded["noice"] = {
    notify = ui.show_float,
    dismiss = ui.dismiss,
    api = {
      status = {
        command = { get = noop_str, has = noop_false },
        mode = { get = noop_str, has = noop_false },
      },
    },
  }

  package.loaded["noice.text.format"] = {
    format = function(msg)
      if type(msg) == "table" and msg.opts and msg.opts.progress then
        local p = msg.opts.progress
        return (p.client or "") .. " " .. (p.message or "")
      end
      return tostring(msg)
    end,
  }

  package.loaded["noice.message"] = function()
    return { opts = { progress = {} } }
  end

  package.loaded["noice.message.manager"] = {
    add = function(msg) ui.show_float(msg) end,
    remove = noop,
  }

  package.loaded["noice.message.router"] = { update = noop }
end

return M
