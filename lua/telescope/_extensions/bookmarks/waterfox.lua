local ok = pcall(require, "sqlite")
if not ok then
  error "Waterfox depends on sqlite.lua (https://github.com/kkharji/sqlite.lua)"
end

local firefox = require "telescope._extensions.bookmarks.firefox"

local waterfox = {}

---Collect all the bookmarks for the Waterfox browser.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function waterfox.collect_bookmarks(state, config)
  return firefox.collect_bookmarks(state, config)
end

return waterfox
