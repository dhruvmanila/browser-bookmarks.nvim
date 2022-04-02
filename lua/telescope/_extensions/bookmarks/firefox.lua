local ok, sqlite = pcall(require, "sqlite")
if not ok then
  error "Firefox depends on sqlite.lua (https://github.com/tami5/sqlite.lua)"
end

local firefox = {}

local utils = require "telescope._extensions.bookmarks.utils"
local ini = require "telescope._extensions.bookmarks.parser.ini"

-- Path components to the default Firefox config directory for the respective OS.
local default_config_dir = {
  Darwin = { "Library", "Application Support", "Firefox" },
  Linux = { ".mozilla", "firefox" },
  Windows_NT = { "AppData", "Roaming", "Mozilla", "Firefox" },
}

-- Names to be excluded from the full bookmark name.
local exclude_names = { "menu", "toolbar" }

-- Returns the absolute path to the Firefox profile directory, nil if the OS
-- is not supported by the plugin or if it failed to parse the config file.
--
-- The profile name will either be the one provided by the user or the default
-- one. The user can define the profile name using `firefox_profile_name` option.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return string|nil
local function get_profile_dir(state, config)
  local components = default_config_dir[state.os_name]
  if not components then
    utils.warn("Unsupported OS for firefox browser: " .. state.os_name)
    return nil
  end

  local default_dir = utils.join_path(state.os_homedir, components)
  local config_file = utils.join_path(default_dir, "profiles.ini")

  local profiles_config = ini.load(config_file)
  if vim.tbl_isempty(profiles_config) then
    utils.warn("Unable to parse firefox profiles config file: " .. config_file)
    return nil
  end

  local profile_dir
  local user_profile = config.firefox_profile_name
  for section, info in pairs(profiles_config) do
    if vim.startswith(section, "Profile") then
      if
        user_profile == info.Name or (info.Default == 1 and not user_profile)
      then
        if info.IsRelative == 1 then
          profile_dir = utils.join_path(default_dir, info.Path)
        else
          profile_dir = info.Path
        end
      end
    end
  end

  if profile_dir == nil then
    if user_profile then
      utils.warn("Given firefox profile does not exist: " .. user_profile)
    else
      utils.warn(
        "Unable to deduce the default firefox profile name. "
          .. "Please provide one with `firefox_profile_name` option."
      )
    end
  end

  return profile_dir
end

-- Collect all the bookmarks for the Firefox browser.
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function firefox.collect_bookmarks(state, config)
  local profile_dir = get_profile_dir(state, config)
  if profile_dir == nil then
    return nil
  end

  local db = sqlite.new(utils.join_path(profile_dir, "places.sqlite")):open()
  local rows = db:select("moz_bookmarks", {
    keys = { "fk", "parent", "title" },
    where = { type = 1 },
  })

  local bookmarks = {}
  for _, row in ipairs(rows) do
    -- Extract the URL for the bookmark.
    local urldata = db:select("moz_places", {
      keys = { "url" },
      where = { id = row.fk },
    })
    local url = urldata[1].url

    -- Extract the full path to the bookmark.
    local path = { row.title }
    local parent_id = row.parent
    while parent_id ~= 1 do
      local folderdata = db:select("moz_bookmarks", {
        keys = { "title", "parent" },
        where = { id = parent_id },
      })
      local folder_name = folderdata[1].title
      if not vim.tbl_contains(exclude_names, folder_name) then
        table.insert(path, 1, folder_name)
      end
      parent_id = folderdata[1].parent
    end

    table.insert(bookmarks, {
      name = row.title,
      path = table.concat(path, "/"),
      url = url,
    })
  end

  db:close()
  return bookmarks
end

if _TEST then
  firefox._get_profile_dir = get_profile_dir
end

return firefox
