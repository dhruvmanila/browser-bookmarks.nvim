local google_chrome = require "telescope._extensions.bookmarks.google_chrome"

local microsoft_edge = {}

---Collect all the bookmarks for the Microsoft Edge browser.
---NOTE: Microsoft Edge and Google Chrome uses the same underlying format to store bookmarks.
---@param state ConfigState
---@return Bookmark[]|nil
function microsoft_edge.collect_bookmarks(state)
  return google_chrome.collect_bookmarks(state)
end

return microsoft_edge
