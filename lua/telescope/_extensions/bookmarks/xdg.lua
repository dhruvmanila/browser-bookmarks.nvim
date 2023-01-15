local utils = require "telescope._extensions.bookmarks.utils"
local xdg = {}

local cache = {}

-- Default config directory components for the respective OS.
-- This excludes the home directory components.
local default_config_home = {
  Darwin = { "Library", "Application Support" },
  Linux = { ".config" },
  Windows_NT = { "AppData", "Local" },
}

-- Return the absolute path to the OS config directory as per the XDG spec.
-- This will cache the path values for the OS provided in the `state`.
---@param state TelescopeBookmarksState
---@return string
function xdg.config_dir(state)
  if cache[state.os_name] ~= nil then
    return cache[state.os_name]
  end
  local config_home = vim.env.XDG_CONFIG_HOME
  if config_home ~= nil then
    config_home = vim.fn.expand(config_home)
  end
  if config_home == nil or config_home == "" then
    config_home =
      utils.join_path(state.os_homedir, default_config_home[state.os_name])
  end
  cache[state.os_name] = config_home
  return config_home
end

if _TEST then
  function xdg.clear_cache()
    cache = {}
  end
end

return xdg
