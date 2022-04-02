local chrome = require "telescope._extensions.bookmarks.chrome"

local chrome_beta = {}

---Collect all the bookmarks for Google Chrome Beta.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function chrome_beta.collect_bookmarks(state, config)
  return chrome.collect_bookmarks(state, config)
end

return chrome_beta
