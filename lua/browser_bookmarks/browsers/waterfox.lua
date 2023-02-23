local ok = pcall(require, "sqlite")
if not ok then
  error "Waterfox depends on sqlite.lua (https://github.com/kkharji/sqlite.lua)"
end

local firefox = require "browser_bookmarks.browsers.firefox"

local waterfox = {}

-- Collect all the bookmarks for the Waterfox browser.
---@param config BrowserBookmarksConfig
---@return Bookmark[]?
function waterfox.collect_bookmarks(config)
  return firefox.collect_bookmarks(config)
end

return waterfox
