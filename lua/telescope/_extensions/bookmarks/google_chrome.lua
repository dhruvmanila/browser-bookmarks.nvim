local google_chrome = {}

local utils = require "telescope._extensions.bookmarks.utils"

---Default categories of bookmarks to look for.
local categories = { "bookmark_bar", "synced", "other" }

---Path components to the bookmarks file for the respective OS and browser.
---Brave and Google Chrome uses the same underlying format to store bookmarks.
local bookmarks_filepath = {
  Darwin = {
    brave = {
      "Library",
      "Application Support",
      "BraveSoftware",
      "Brave-Browser",
      "Default",
      "Bookmarks",
    },
    google_chrome = {
      "Library",
      "Application Support",
      "Google",
      "Chrome",
      "Default",
      "Bookmarks",
    },
    microsoft_edge = {
      "Library",
      "Application Support",
      "Microsoft Edge",
      "Default",
      "Bookmarks",
    },
  },
  Linux = {
    brave = {
      ".config",
      "BraveSoftware",
      "Brave-Browser",
      "Default",
      "Bookmarks",
    },
    google_chrome = {
      ".config",
      "google-chrome",
      "Default",
      "Bookmarks",
    },
    microsoft_edge = {
      ".config",
      "microsoft-edge",
      "Default",
      "Bookmarks",
    },
  },
  Windows_NT = {
    brave = {
      "AppData",
      "Local",
      "BraveSoftware",
      "Brave-Browser",
      "User Data",
      "Default",
      "Bookmarks",
    },
    google_chrome = {
      "AppData",
      "Local",
      "Google",
      "Chrome",
      "User Data",
      "Default",
      "Bookmarks",
    },
    microsoft_edge = {
      "AppData",
      "Local",
      "Microsoft",
      "Edge",
      "User Data",
      "Default",
      "Bookmarks",
    },
  },
}

---Parse the bookmarks data to a lua table.
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
      table.insert(items, { name = name, url = bookmark.url })
    end
  end

  for _, category in ipairs(categories) do
    insert_items(nil, data.roots[category])
  end
  return items
end

---Collect all the bookmarks for Google Chrome or Brave browser.
---@param state ConfigState
---@return Bookmark[]|nil
function google_chrome.collect_bookmarks(state)
  local components = bookmarks_filepath[state.os_name][state.selected_browser]
  if not components then
    utils.warn(
      ("Unsupported OS for %s: %s"):format(
        state.selected_browser,
        state.os_name
      )
    )
    return nil
  end

  local filepath = utils.join_path(state.os_homedir, components)
  local file = io.open(filepath, "r")
  if not file then
    utils.warn(
      ("No %s bookmarks file found at: %s"):format(
        state.selected_browser,
        filepath
      )
    )
    return nil
  end

  local content = file:read "*a"
  file:close()
  local data = vim.fn.json_decode(content)
  return parse_bookmarks_data(data)
end

return google_chrome
