local cwd = vim.fn.getcwd()

-- Setup runtime path for dependencies
vim.opt.runtimepath:append {
  cwd .. "/.deps/sqlite.lua",
  cwd .. "/.deps/telescope.nvim",
  cwd .. "/.deps/plenary.nvim",
}
