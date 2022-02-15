local chrome = require "telescope._extensions.bookmarks.chrome"

local chrome_beta = {}

---Collect all the bookmarks for Google Chrome Beta.
---@param state ConfigState
---@return Bookmark[]|nil
function chrome_beta.collect_bookmarks(state)
  return chrome.collect_bookmarks(state)
end

return chrome_beta
