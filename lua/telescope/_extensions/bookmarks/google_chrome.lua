local utils = require('telescope._extensions.bookmarks.utils')

---Default categories of bookmarks to look for.
local categories = {"bookmark_bar", "synced", "other"}

---Path components to the bookmarks file for the respective OS and browser.
---Brave and Google Chrome uses the same underlying format to store bookmarks.
local bookmarks_filepath = {
  Darwin = {
    brave = {"Library", "Application Support", "BraveSoftware", "Brave-Browser", "Default", "Bookmarks"},
    google_chrome = {"Library", "Application Support", "Google", "Chrome", "Default", "Bookmarks"},
  },
  Linux = {
    brave = {".config", "BraveSoftware", "Brave-Browser", "Default", "Bookmarks"},
    google_chrome = {".config", "google-chrome", "Default", "Bookmarks"},
  },
  Windows_NT = {
    brave = {"AppData", "Local", "BraveSoftware", "Brave-Browser", "User Data", "Default", "Bookmarks"},
    google_chrome = {"AppData", "Local", "Google", "Chrome", "User Data", "Default", "Bookmarks"},
  },
}

local google_chrome = {}

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
    local name = parent
      and (parent ~= "" and parent .. "/" .. bookmark.name or bookmark.name)
      or ""
    if bookmark.type == "folder" then
      for _, child in ipairs(bookmark.children) do
        insert_items(name, child)
      end
    else
      table.insert(items, {name = name, url = bookmark.url})
    end
  end

  for _, category in ipairs(categories) do
    insert_items(nil, data.roots[category])
  end
  return items
end

---Collect all the bookmarks for the Google Chrome browser.
---@param state table
---@return table
function google_chrome.collect_bookmarks(state)
  local components = bookmarks_filepath[state.os_name][state.selected_browser]
  local filepath = vim.fn.join(components, state.path_sep)
  filepath = state.os_home .. state.path_sep .. filepath
  local file = io.open(filepath, "r")

  if not file then
    utils.warn("No Google Chrome bookmarks file found at: " .. filepath)
    return nil
  end

  local content = file:read("*a")
  file:close()
  local data = vim.fn.json_decode(content)
  return parse_bookmarks_data(data)
end

return google_chrome
