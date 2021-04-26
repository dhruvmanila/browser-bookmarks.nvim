local firefox = require('telescope._extensions.bookmarks.firefox')

local firefox_dev = {}

---Collect all the bookmarks for the Firefox Developer Edition browser.
---@param state table
---@return table
function firefox_dev.collect_bookmarks(state)
  return firefox.collect_bookmarks(state)
end

return firefox_dev
