local chrome = require "telescope._extensions.bookmarks.chrome"

local brave = {}

---Collect all the bookmarks for the Brave browser.
---NOTE: Brave and Google Chrome uses the same underlying format to store bookmarks.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function brave.collect_bookmarks(state, config)
  return chrome.collect_bookmarks(state, config)
end

return brave
