local chromium = {}

local utils = require "browser_bookmarks.utils"

-- Default categories of bookmarks to look for.
local categories = { "bookmark_bar", "synced", "other" }

-- Returns the absolute path to the profile directory for chromium based
-- browsers.
--
-- It will return `nil` if:
--   - the "Local State" file is not found in the config directory
--   - given profile name does not exist
--
-- The profile name will either be the one provided by the user or the default
-- one. The user can define the profile name using `profile_name` option.
---@param config BrowserBookmarksConfig
---@return string?
local function get_profile_dir(config)
  local config_dir = utils.get_config_dir(config.selected_browser)
  if config_dir == nil then
    return nil
  end

  if config.profile_name == nil then
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
  ---@cast data table

  for profile_dir, profile_info in pairs(data.profile.info_cache) do
    if profile_info.name == config.profile_name then
      return utils.join_path(config_dir, profile_dir)
    end
  end

  utils.warn(
    ("Given %s profile does not exist: %s"):format(
      config.selected_browser,
      config.profile_name
    )
  )
end

-- Parse the bookmarks data to a lua table.
---@param data table
---@return Bookmark[]?
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

-- Collect all the bookmarks for Chromium based browsers.
---@param config BrowserBookmarksConfig
---@return Bookmark[]?
function chromium.collect_bookmarks(config)
  local profile_dir = get_profile_dir(config)
  if profile_dir == nil then
    return nil
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
  if content == nil or content == "" then
    utils.warn(
      ("No content found in %s bookmarks file at: %s"):format(
        config.selected_browser,
        filepath
      )
    )
    return nil
  end

  local data = vim.json.decode(content)
  ---@cast data table
  return parse_bookmarks_data(data)
end

if _TEST then
  chromium._get_profile_dir = get_profile_dir
end

return chromium
