local safari = {}

local utils = require "telescope._extensions.bookmarks.utils"
local plist = require "telescope._extensions.bookmarks.parser.plist"

---Path components to the bookmarks file for the respective OS.
---Safari browser is only supported in MacOS.
local bookmarks_filepath = {
  Darwin = { "Library", "Safari", "Bookmarks.plist" },
}

---Names to be excluded from the full bookmark name.
local exclude_names = {
  "BookmarksBar",
  "BookmarksMenu",
  "com.apple.ReadingList",
}

---Parse the bookmarks data in a lua table.
---@param data table
---@return table
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

---Collect all the bookmarks for the Safari browser.
---NOTE: Only MacOS is supported for Safari bookmarks.
---@param state ConfigState
---@return Bookmark[]|nil
function safari.collect_bookmarks(state)
  local components = bookmarks_filepath[state.os_name]
  if not components then
    utils.warn("Unsupported OS for Safari: " .. state.os_name)
    return nil
  end

  local filepath = utils.join_path(state.os_homedir, components)

  local output = utils.get_os_command_output {
    "plutil",
    "-convert",
    "xml1",
    "-o",
    "-",
    filepath,
  }
  output = table.concat(output, "\n")

  local data = plist.parse(output)
  return parse_bookmarks_data(data)
end

return safari
