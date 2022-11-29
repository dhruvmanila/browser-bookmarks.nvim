local chrome = require "telescope._extensions.bookmarks.chrome"

local brave_beta = {}

---Collect all the bookmarks for the Brave browser beta.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function brave_beta.collect_bookmarks(state, config)
  return chrome.collect_bookmarks(state, config)
end

return brave_beta
