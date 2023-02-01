local qutebrowser = {}

local utils = require "telescope._extensions.bookmarks.utils"

---Collect all the bookmarks for qutebrowser.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function qutebrowser.collect_bookmarks(state, config)
  local config_dir = utils.get_config_dir(state, config)
  if config_dir == nil then
    return nil
  end

  local filepath = utils.join_path(config_dir, "bookmarks", "urls")
  local file = io.open(filepath, "r")
  if not file then
    utils.warn("No qutebrowser bookmarks file found at: " .. filepath)
    return nil
  end

  local bookmarks = {}
  for line in file:lines() do
    -- Format: "<url> <name>"
    local words = vim.split(line, "%s+", { trimempty = true })
    if vim.tbl_count(words) == 1 then
      table.insert(bookmarks, {
        name = "",
        path = "",
        url = words[1],
      })
    else
      local name = table.concat(words, " ", 2)
      table.insert(bookmarks, {
        name = name,
        path = name,
        url = words[1],
      })
    end
  end
  return bookmarks
end

return qutebrowser
