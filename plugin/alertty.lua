return {
  name = "alertty",
  dir = vim.fn.stdpath("config") .. "/alertty",
  priority = 10000,
  config = function()
    require("alertty").setup({
      -- timeout = 3000,
      -- width = 60,
      -- border = "none",
    })
  end,
}
