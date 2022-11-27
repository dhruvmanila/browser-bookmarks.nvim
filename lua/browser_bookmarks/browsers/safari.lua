local safari = {}

local plist = require "browser_bookmarks.parser.plist"
local utils = require "browser_bookmarks.utils"

-- Names to be excluded from the full bookmark name.
local exclude_names = {
  "BookmarksBar",
  "BookmarksMenu",
  "com.apple.ReadingList",
}

-- Parse the bookmarks data in a lua table.
---@param data table
---@return Bookmark[]|nil
local function parse_bookmarks_data(data)
  local items = {}

  local function insert_items(parent, bookmark)
    local path = ""
    if bookmark.WebBookmarkType == "WebBookmarkTypeList" then
      -- Exclude the category name from the final name
      if not vim.tbl_contains(exclude_names, bookmark.Title) then
        path = parent ~= "" and parent .. "/" .. bookmark.Title
          or bookmark.Title
      end
      local children = bookmark.Children or {}
      for _, child in ipairs(children) do
        insert_items(path, child)
      end
    elseif bookmark.WebBookmarkType == "WebBookmarkTypeLeaf" then
      local title = bookmark.URIDictionary.title
      path = parent ~= "" and parent .. "/" .. title or title
      table.insert(items, {
        name = title,
        path = path,
        url = bookmark.URLString,
      })
    end
  end

  insert_items("", data)
  return items
end

-- Collect all the bookmarks for the Safari browser.
--
-- NOTE: Only MacOS is supported for Safari bookmarks.
---@param config BrowserBookmarksConfig
---@return Bookmark[]?
function safari.collect_bookmarks(config)
  local config_dir = utils.get_config_dir(config.selected_browser)
  if config_dir == nil then
    return nil
  end

  local bookmarks_filepath = utils.join_path(config_dir, "Bookmarks.plist")
  if not utils.path_exists(bookmarks_filepath) then
    utils.warn("Expected bookmarks file for Safari at: " .. bookmarks_filepath)
    return nil
  end

  local output =
    utils.run_os_command("plutil -convert xml1 -o - " .. bookmarks_filepath)
  local data = plist.parse(output)
  if data == nil then
    return nil
  end
  return parse_bookmarks_data(data)
end

return safari
