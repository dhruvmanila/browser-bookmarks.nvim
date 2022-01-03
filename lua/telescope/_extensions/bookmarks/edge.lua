local chrome = require "telescope._extensions.bookmarks.chrome"

local edge = {}

---Collect all the bookmarks for Microsoft Edge browser.
---NOTE: Microsoft Edge and Google Chrome uses the same underlying format to store bookmarks.
---@param state ConfigState
---@return Bookmark[]|nil
function edge.collect_bookmarks(state)
  return chrome.collect_bookmarks(state)
end

return edge
