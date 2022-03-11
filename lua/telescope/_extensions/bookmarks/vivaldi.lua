local chrome = require "telescope._extensions.bookmarks.chrome"

local vivaldi = {}

---Collect all the bookmarks for the Vivaldi browser.
---NOTE: Vivaldi and Google Chrome uses the same underlying format to store bookmarks.
---@param state ConfigState
---@return Bookmark[]|nil
function vivaldi.collect_bookmarks(state)
  return chrome.collect_bookmarks(state)
end

return vivaldi
