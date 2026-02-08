local M = {}

local ui = require("alertty.ui")
local spinner = require("alertty.spinner")

local progress = {}

local function on_progress(data)
  local client_id = data.client_id
  local params = data.params or data.result
  local id = client_id .. "." .. params.token

  if params.value.kind == "end" then
    progress[id] = nil
    if vim.tbl_isempty(progress) then
      spinner.stop()
    end
    return
  end

  local client = vim.lsp.get_client_by_id(client_id)
  if not client then return end

  progress[id] = {
    client = client.name,
    title = params.value.title or "",
    message = params.value.message or "",
    percentage = params.value.percentage,
  }

  spinner.start()
  local msg = string.format("%s [%s] %s", spinner.get(), client.name, params.value.title or "")
  if params.value.message and params.value.message ~= "" then
    msg = msg .. ": " .. params.value.message
  end
  if params.value.percentage then
    msg = msg .. string.format(" (%d%%)", params.value.percentage)
  end

  ui.show_float(msg, "Comment")
end

local function on_message(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local client_name = client and client.name or "LSP"
  
  local hl = result.type == 1 and "ErrorMsg" or result.type == 2 and "WarningMsg" or "Normal"
  ui.show_float(string.format("[%s] %s", client_name, result.message), hl)
end

function M.setup()
  local ok = pcall(vim.api.nvim_create_autocmd, "LspProgress", {
    group = vim.api.nvim_create_augroup("alertty_lsp_progress", { clear = true }),
    callback = function(event)
      on_progress(event.data)
    end,
  })

  if not ok then
    local orig = vim.lsp.handlers["$/progress"]
    vim.lsp.handlers["$/progress"] = function(...)
      local params = select(2, ...)
      local ctx = select(3, ...)
      pcall(on_progress, { client_id = ctx.client_id, params = params })
      if orig then orig(...) end
    end
  end

  vim.lsp.handlers["window/showMessage"] = on_message
end

return M
