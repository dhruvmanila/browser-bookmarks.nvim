if vim.g.loaded_browser_bookmarks then
  return
end
vim.g.loaded_browser_bookmarks = true

local Browser = require("browser_bookmarks.enum").Browser
local browser_bookmarks = require "browser_bookmarks"
local state = require "browser_bookmarks.state"

vim.api.nvim_create_user_command("BrowserBookmarks", function(info)
  local selected_browser
  if info.args ~= "" then
    selected_browser = info.args
  end
  browser_bookmarks.select(selected_browser)
end, {
  nargs = "?",
  complete = function(arglead)
    arglead = arglead and (".*" .. arglead .. ".*")
    return vim.tbl_filter(function(browser)
      if state.os_name ~= "Darwin" and browser == Browser.SAFARI then
        return false
      end
      return browser:match(arglead)
    end, vim.tbl_values(Browser))
  end,
  desc = "Select bookmark(s) for a browser",
})
