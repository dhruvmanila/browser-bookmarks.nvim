local cwd = vim.fn.getcwd()

-- Setup runtime path for dependencies
vim.opt.runtimepath:append {
  cwd .. "/.deps/sqlite.lua",
  cwd .. "/.deps/telescope.nvim",
  cwd .. "/.deps/plenary.nvim",
}

-- A flag to export private elements from the module for testing purposes.
-- The element name will be prefixed with an underscore to avoid collision.
---@see http://olivinelabs.com/busted/#private
_G._TEST = true
