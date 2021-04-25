local google_chrome = require('telescope._extensions.bookmarks.google_chrome')

local brave = {}

---Collect all the bookmarks for the Brave browser.
---NOTE: Brave and Google Chrome uses the same underlying format to store bookmarks.
---@param state table
---@return table
function brave.collect_bookmarks(state)
  return google_chrome.collect_bookmarks(state)
end

return brave
