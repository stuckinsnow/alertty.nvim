local M = {}

M.options = {
  timeout = 3000,
  width = 60,
  border = "none",
  position = "bottom_right",
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
