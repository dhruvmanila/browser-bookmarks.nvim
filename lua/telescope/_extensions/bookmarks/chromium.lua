local chrome = require "telescope._extensions.bookmarks.chrome"

local chromium = {}

---Collect all the bookmarks for Chromium browser.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function chromium.collect_bookmarks(state, config)
  return chrome.collect_bookmarks(state, config)
end

return chromium
