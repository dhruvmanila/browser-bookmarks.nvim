local chrome = {}

local utils = require "telescope._extensions.bookmarks.utils"

---Default categories of bookmarks to look for.
local categories = { "bookmark_bar", "synced", "other" }

-- Path components to the default config directory for the respective OS
-- and browser.
local default_config_dir = {
  Darwin = {
    brave = {
      "Library",
      "Application Support",
      "BraveSoftware",
      "Brave-Browser",
    },
    brave_beta = {
      "Library",
      "Application Support",
      "BraveSoftware",
      "Brave-Browser-Beta",
    },
    chrome = {
      "Library",
      "Application Support",
      "Google",
      "Chrome",
    },
    chrome_beta = {
      "Library",
      "Application Support",
      "Google",
      "Chrome Beta",
    },
    edge = {
      "Library",
      "Application Support",
      "Microsoft Edge",
    },
    vivaldi = {
      "Library",
      "Application Support",
      "Vivaldi",
    },
  },
  Linux = {
    brave = {
      ".config",
      "BraveSoftware",
      "Brave-Browser",
    },
    brave_beta = {
      ".config",
      "BraveSoftware",
      "Brave-Browser-Beta",
    },
    chrome = {
      ".config",
      "google-chrome",
    },
    chrome_beta = {
      ".config",
      "google-chrome-beta",
    },
    edge = {
      ".config",
      "microsoft-edge",
    },
    vivaldi = {
      ".config",
      "vivaldi",
    },
  },
  Windows_NT = {
    brave = {
      "AppData",
      "Local",
      "BraveSoftware",
      "Brave-Browser",
      "User Data",
    },
    brave_beta = {
      "AppData",
      "Local",
      "BraveSoftware",
      "Brave-Browser-Beta",
      "User Data",
    },
    chrome = {
      "AppData",
      "Local",
      "Google",
      "Chrome",
      "User Data",
    },
    chrome_beta = {
      "AppData",
      "Local",
      "Google",
      "Chrome Beta",
      "User Data",
    },
    edge = {
      "AppData",
      "Local",
      "Microsoft",
      "Edge",
      "User Data",
    },
    vivaldi = {
      "AppData",
      "Local",
      "Vivaldi",
      "User Data",
    },
  },
}

-- Returns the absolute path to the profile directory for chromium based
-- browsers.
--
-- It will return `nil` if:
--   - the OS is not supported by the plugin
--   - the "Local State" file is not found in the config directory
--   - given profile name does not exist
--
-- The profile name will either be the one provided by the user or the default
-- one. The user can define the profile name using `profile_name` option.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return string|nil
local function get_profile_dir(state, config)
  local components = (default_config_dir[state.os_name] or {})[config.selected_browser]
  if not components then
    utils.warn(
      ("Unsupported OS for %s browser: %s"):format(
        config.selected_browser,
        state.os_name
      )
    )
    return nil
  end

  local config_dir = utils.join_path(state.os_homedir, components)
  local user_profile = config.profile_name
  if not user_profile then
    return utils.join_path(config_dir, "Default")
  end

  local state_file = utils.join_path(config_dir, "Local State")
  local file = io.open(state_file, "r")
  if not file then
    utils.warn(
      ("No state file found for %s at: %s"):format(
        config.selected_browser,
        state_file
      )
    )
    return nil
  end

  local content = file:read "*a"
  file:close()
  local data = vim.json.decode(content)
  for profile_dir, profile_info in pairs(data.profile.info_cache) do
    if profile_info.name == user_profile then
      return utils.join_path(config_dir, profile_dir)
    end
  end

  utils.warn(
    ("Given %s profile does not exist: %s"):format(
      config.selected_browser,
      user_profile
    )
  )
end

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
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function chrome.collect_bookmarks(state, config)
  local profile_dir = get_profile_dir(state, config)
  if profile_dir == nil then
    return
  end

  local filepath = utils.join_path(profile_dir, "Bookmarks")
  local file = io.open(filepath, "r")
  if not file then
    utils.warn(
      ("No %s bookmarks file found at: %s"):format(
        config.selected_browser,
        filepath
      )
    )
    return nil
  end

  local content = file:read "*a"
  file:close()
  if not content then
    utils.warn(
      ("No content found in %s bookmarks file at: %s"):format(
        config.selected_browser,
        filepath
      )
    )
    return nil
  end
  local data = vim.json.decode(content)
  return parse_bookmarks_data(data)
end

return chrome
