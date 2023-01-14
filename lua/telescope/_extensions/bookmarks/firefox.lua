local ok, sqlite = pcall(require, "sqlite")
if not ok then
  error "Firefox depends on sqlite.lua (https://github.com/kkharji/sqlite.lua)"
end

local firefox = {}

local utils = require "telescope._extensions.bookmarks.utils"
local ini = require "telescope._extensions.bookmarks.parser.ini"

-- Path components to the default Firefox config directory for the respective OS.
local default_config_dir = {
  Darwin = {
    firefox = { "Library", "Application Support", "Firefox" },
    waterfox = { "Library", "Application Support", "Waterfox" },
  },
  Linux = {
    firefox = { ".mozilla", "firefox" },
    waterfox = { ".waterfox" },
  },
  Windows_NT = {
    firefox = { "AppData", "Roaming", "Mozilla", "Firefox" },
    waterfox = { "AppData", "Roaming", "Waterfox" },
  },
}

-- Names to be excluded from the full bookmark name.
local exclude_names = { "menu", "toolbar" }

---Return the profile information available in the given profiles config file.
---
---The return value will be a mapping of profile name to the information
---available, `nil` if unable to parse the config file.
---@param profiles_file string
---@return table<string, table>|nil
local function collect_profiles(profiles_file)
  local profiles_config = ini.load(profiles_file)
  if vim.tbl_isempty(profiles_config) then
    return nil
  end

  local profiles = {}
  for section, info in pairs(profiles_config) do
    if vim.startswith(section, "Profile") then
      profiles[info.Name] = info
    end
  end
  return profiles
end

-- Returns the absolute path to the Firefox profile directory.
--
-- It will return `nil` if:
--   - the OS is not supported by the plugin
--   - it failed to parse the config file
--   - given profile name does not exist
--   - unable to deduce the profile directory for some unknown reason
--
-- The profile name will either be the one provided by the user or the default
-- one. The user can define the profile name using `firefox_profile_name` option.
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
  local profiles_file = utils.join_path(config_dir, "profiles.ini")

  local profiles = collect_profiles(profiles_file)
  if not profiles then
    utils.warn(
      ("Unable to parse %s profiles config file: %s"):format(
        config.selected_browser,
        profiles_file
      )
    )
    return nil
  end

  local user_profile = config[config.selected_browser .. "_profile_name"]

  local profile_info
  if vim.tbl_count(profiles) == 1 then
    -- Use the only profile available
    _, profile_info = next(profiles)
  elseif user_profile ~= nil then
    profile_info = vim.tbl_get(profiles, user_profile)
    if profile_info == nil then
      utils.warn(
        ("Given %s profile does not exist: %s"):format(
          config.selected_browser,
          user_profile
        )
      )
      return nil
    end
  else
    for _, info in pairs(profiles) do
      -- The browser sets the default profile when it's opened for the first
      -- time or when a new profile is created and there was only one profile
      -- present before that which was not the default profile. This does not
      -- correspond to the default profile as set by the user. So, we will use
      -- it only as a fallback.
      if info.Default == 1 then
        profile_info = info
        break
      end
    end
  end

  if profile_info == nil then
    utils.warn(
      (
        "Unable to deduce the default %s profile name. "
        .. "Please provide one with `%s_profile_name` option."
      ):format(config.selected_browser, config.selected_browser)
    )
    return nil
  end

  if profile_info.IsRelative == 1 then
    return utils.join_path(config_dir, profile_info.Path)
  else
    return profile_info.Path
  end
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

  local db_file = utils.join_path(profile_dir, "places.sqlite")
  if not vim.loop.fs_stat(db_file) then
    utils.warn(
      (
        "Bookmarks database file for %s browser is not present "
        .. "in the profile directory: %s"
      ):format(config.selected_browser, db_file)
    )
    return nil
  end

  local uri = "file:" .. db_file .. "?immutable=1"
  local db = sqlite.new(uri, { open_mode = "ro" }):open()
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
  firefox._collect_profiles = collect_profiles
end

return firefox
