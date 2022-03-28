local chrome = {}

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
    chrome = {
      "Library",
      "Application Support",
      "Google",
      "Chrome",
      "Default",
      "Bookmarks",
    },
    chrome_beta = {
      "Library",
      "Application Support",
      "Google",
      "Chrome Beta",
      "Default",
      "Bookmarks",
    },
    edge = {
      "Library",
      "Application Support",
      "Microsoft Edge",
      "Default",
      "Bookmarks",
    },
    vivaldi = {
      "Library",
      "Application Support",
      "Vivaldi",
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
    chrome = {
      ".config",
      "google-chrome",
      "Default",
      "Bookmarks",
    },
    chrome_beta = {
      ".config",
      "google-chrome-beta",
      "Default",
      "Bookmarks",
    },
    edge = {
      ".config",
      "microsoft-edge",
      "Default",
      "Bookmarks",
    },
    vivaldi = {
      ".config",
      "vivaldi",
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
    chrome = {
      "AppData",
      "Local",
      "Google",
      "Chrome",
      "User Data",
      "Default",
      "Bookmarks",
    },
    chrome_beta = {
      "AppData",
      "Local",
      "Google",
      "Chrome Beta",
      "User Data",
      "Default",
      "Bookmarks",
    },
    edge = {
      "AppData",
      "Local",
      "Microsoft",
      "Edge",
      "User Data",
      "Default",
      "Bookmarks",
    },
    vivaldi = {
      "AppData",
      "Local",
      "Vivaldi",
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
    local path = parent
        and (parent ~= "" and parent .. "/" .. bookmark.name or bookmark.name)
      or ""
    if bookmark.type == "folder" then
      for _, child in ipairs(bookmark.children) do
        insert_items(path, child)
      end
    else
      table.insert(items, {
        name = bookmark.name,
        path = path,
        url = bookmark.url,
      })
    end
  end

  for _, category in ipairs(categories) do
    insert_items(nil, data.roots[category])
  end
  return items
end

---Collect all the bookmarks for Chromium based browsers.
---@param state ConfigState
---@return Bookmark[]|nil
function chrome.collect_bookmarks(state)
  local components =
    (bookmarks_filepath[state.os_name] or {})[state.selected_browser]
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
  local data = vim.json.decode(content)
  return parse_bookmarks_data(data)
end

return chrome
