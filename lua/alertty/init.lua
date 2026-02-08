local M = {}

local config = require("alertty.config")
local ui = require("alertty.ui")
local stub = require("alertty.stub")
local cmdline = require("alertty.cmdline")

function M.setup(opts)
  config.setup(opts)
  stub.inject()
  cmdline.setup()
end

function M.notify(msg, hl_group)
  ui.show_float(msg, hl_group)
end

function M.dismiss()
  ui.dismiss()
end

return M
