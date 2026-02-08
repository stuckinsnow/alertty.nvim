# alertty.nvim

A lightweight Neovim plugin that intercepts `noice.nvim` calls and displays notifications in a simple bottom-right float window.

## Features

- Intercepts all `require("noice")` calls
- Displays notifications in a bottom-right floating window
- Auto-dismisses after configurable timeout
- Zero dependencies

## Installation

### lazy.nvim

```lua
{
  "stuckinsnow/alertty.nvim",
  priority = 10000,
  config = function()
    require("alertty").setup({
      timeout = 3000,  -- milliseconds
      width = 60,      -- max width
      border = "none", -- "none", "single", "double", "rounded"
    })
  end,
}
```

## Configuration

Default options:

```lua
{
  timeout = 3000,
  width = 60,
  border = "none",
  position = "bottom_right",
}
```

## API

```lua
-- Show a notification
require("alertty").notify("Hello, world!")

-- Dismiss current notification
require("alertty").dismiss()
```

## How it works

The plugin injects itself into `package.loaded["noice"]` before any other plugin can load noice, effectively replacing it with a minimal implementation.
