local M = {}

local config = require("alertty.config")
local ui = require("alertty.ui")
local stub = require("alertty.stub")

function M.setup(opts)
  config.setup(opts)
  stub.inject()
end

function M.notify(msg, hl_group)
  ui.show_float(msg, hl_group)
end

function M.dismiss()
  ui.dismiss()
end

return M
