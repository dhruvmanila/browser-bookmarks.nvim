local Browser = require("browser_bookmarks.enum").Browser

-- Browser module interface.
--
-- Every browser module needs to implement this interface which is used
-- to collect and/or select the bookmarks.
---@alias BrowserInterface { collect_bookmarks: fun(config: BrowserBookmarksConfig): Bookmark[]? }

-- An array of all the supported browsers.
---@type string[]
local supported_browsers = vim.tbl_values(Browser)

-- An array of all the chromium based browsers.
---@type Browser[]
local chromium_based_browsers = {
  Browser.ARC,
  Browser.BRAVE,
  Browser.BRAVE_BETA,
  Browser.CHROME,
  Browser.CHROME_BETA,
  Browser.CHROMIUM,
  Browser.EDGE,
  Browser.VIVALDI,
}

-- An array of browsers which are dependent on `sqlite.lua` as the bookmarks
-- are stored in a local database file.
---@type Browser[]
local sqlite_dependency_browsers = {
  Browser.BUKU,
  Browser.FIREFOX,
  Browser.WATERFOX,
}

-- Check if the `sqlite.lua` dependency is installed, raise an error if not.
---@param selected_browser Browser
local function check_sqlite_dependency(selected_browser)
  local ok = pcall(require, "sqlite")
  if not ok then
    error(
      selected_browser
        .. " depends on sqlite.lua (https://github.com/kkharji/sqlite.lua)"
    )
  end
end

---@type table<Browser, BrowserInterface>
local M = setmetatable({}, {
  ---@param self table
  ---@param selected_browser string
  ---@return BrowserInterface
  __index = function(self, selected_browser)
    if not vim.tbl_contains(supported_browsers, selected_browser) then
      error(
        string.format(
          "Unsupported browser: %s (supported: %s)",
          selected_browser,
          table.concat(supported_browsers, ", ")
        )
      )
    end

    -- Entrypoint for all chromium based browsers is "chromium.lua". But,
    -- the module should be stored with the original name.
    local browser = selected_browser
    if vim.tbl_contains(chromium_based_browsers, selected_browser) then
      browser = Browser.CHROMIUM
    end

    if vim.tbl_contains(sqlite_dependency_browsers, selected_browser) then
      check_sqlite_dependency(selected_browser)
      -- Firefox and Waterfox have the same backend.
      if selected_browser == Browser.WATERFOX then
        browser = Browser.FIREFOX
      end
    end

    local mod = require("browser_bookmarks.browsers." .. browser)
    ---@cast mod BrowserInterface
    rawset(self, selected_browser, mod)

    return mod
  end,
})

return M
