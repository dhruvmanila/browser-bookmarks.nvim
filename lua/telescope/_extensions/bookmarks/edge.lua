local chrome = require "telescope._extensions.bookmarks.chrome"

local edge = {}

---Collect all the bookmarks for Microsoft Edge browser.
---NOTE: Microsoft Edge and Google Chrome uses the same underlying format to store bookmarks.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function edge.collect_bookmarks(state, config)
  return chrome.collect_bookmarks(state, config)
end

return edge
