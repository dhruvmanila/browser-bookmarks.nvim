local utils = require('telescope.utils')

local plist_parse = require('telescope._extensions.bookmarks.plist_parser')

local safari = {}

---Path components to the bookmarks file for the respective OS.
---Safari browser is only supported in MacOS.
local bookmarks_filepath = {
  Darwin = {"Library", "Safari", "Bookmarks.plist"},
}

---Names to be excluded from the full bookmark name.
local exclude_names = {"BookmarksBar", "BookmarksMenu", "com.apple.ReadingList"}

---Parse the bookmarks data in a table in the following form:
---{
---  {name = <bookmark name>, url = <bookmark url>},
---  ...,
---}
---@param data table
---@return table
local function parse_bookmarks_data(data)
  local items = {}

  local function insert_items(parent, bookmark)
    local name = ""
    if bookmark.WebBookmarkType == 'WebBookmarkTypeList' then
      -- Exclude the category name from the final name
      if not vim.tbl_contains(exclude_names, bookmark.Title) then
        name = parent ~= "" and parent .. "/" .. bookmark.Title or bookmark.Title
      end
      local children = bookmark.Children or {}
      for _, child in ipairs(children) do
        insert_items(name, child)
      end
    elseif bookmark.WebBookmarkType == 'WebBookmarkTypeLeaf' then
      local title = bookmark.URIDictionary.title
      name = parent ~= "" and parent .. "/" .. title or title
      table.insert(items, {name = name, url = bookmark.URLString})
    end
  end

  insert_items("", data)
  return items
end

---Collect all the bookmarks for the Safari browser.
---NOTE: Only MacOS is supported for Safari bookmarks.
---@param state table
---@return table
function safari.collect_bookmarks(state)
  local components = bookmarks_filepath[state.os_name]

  if not components then
    error("Unsupported OS for Safari browser: " .. state.os_name)
  end

  local filepath = vim.fn.join(components, state.path_sep)
  filepath = state.os_home .. state.path_sep .. filepath
  local command = {"plutil",  "-convert", "xml1", "-o", "-", filepath}
  local output, code, err = utils.get_os_command_output(command)

  if code > 0 then
    error(table.concat(err, "\n"))
  end

  output = table.concat(output, "\n")
  local data = plist_parse(output)
  return parse_bookmarks_data(data)
end

return safari
