-- Setup `nvim-test` to use `vusted` for lua instead.
--
-- To source this file automatically when Neovim is opened, set the exrc option
-- in your `init.lua` file:
--
--    `vim.opt.exrc = true`
--
-- https://github.com/klen/nvim-test

local ok, nvim_test = pcall(require, "nvim-test")
if not ok then
  return
end

nvim_test.setup {
  runners = {
    lua = "nvim-test.runners.vusted",
  },
}
