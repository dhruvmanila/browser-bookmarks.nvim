local utils = {}

local telescope_utils = require "telescope.utils"

local path_sep = require("plenary.path").path.sep

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
    chromium = {
      "Library",
      "Application Support",
      "Chromium",
    },
    edge = {
      "Library",
      "Application Support",
      "Microsoft Edge",
    },
    firefox = {
      "Library",
      "Application Support",
      "Firefox",
    },
    qutebrowser = {
      ".qutebrowser",
    },
    safari = {
      "Library",
      "Safari",
    },
    vivaldi = {
      "Library",
      "Application Support",
      "Vivaldi",
    },
    waterfox = {
      "Library",
      "Application Support",
      "Waterfox",
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
    chromium = {
      ".config",
      "chromium",
    },
    edge = {
      ".config",
      "microsoft-edge",
    },
    firefox = {
      ".mozilla",
      "firefox",
    },
    qutebrowser = {
      ".config",
      "qutebrowser",
    },
    vivaldi = {
      ".config",
      "vivaldi",
    },
    waterfox = {
      ".waterfox",
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
    chromium = {
      "AppData",
      "Local",
      "Chromium",
      "User Data",
    },
    edge = {
      "AppData",
      "Local",
      "Microsoft",
      "Edge",
      "User Data",
    },
    firefox = {
      "AppData",
      "Roaming",
      "Mozilla",
      "Firefox",
    },
    qutebrowser = {
      "AppData",
      "Roaming",
      "qutebrowser",
      "config",
    },
    vivaldi = {
      "AppData",
      "Local",
      "Vivaldi",
      "User Data",
    },
    waterfox = {
      "AppData",
      "Roaming",
      "Waterfox",
    },
  },
}

-- Returns true if the given path exists, false otherwise.
---@param path string
---@return boolean
function utils.path_exists(path)
  local stat = vim.loop.fs_stat(path) or {}
  return not vim.tbl_isempty(stat)
end

-- Return the absolute path to the config directory for the respective OS and
-- browser.
--
-- It first checks if the user provided the path in the configuration, else
-- uses the default path.
--
-- It returns nil if:
--    - the OS or browser is not supported
--    - user provided config path does not exists
---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return string|nil
function utils.get_config_dir(state, config)
  local config_dir = config.config_dir
  if config_dir ~= nil then
    if not utils.path_exists(config_dir) then
      utils.warn(
        (
          "No such directory for %s browser: %s "
          .. "(make sure to provide the absolute path which includes "
          .. "the home directory as well)"
        ):format(config.selected_browser, config_dir)
      )
      return nil
    end
    return config_dir
  end
  local components = (default_config_dir[state.os_name] or {})[config.selected_browser]
  if components == nil then
    -- This assumes that the check for browser support was already done before
    -- calling this function, thus the message for unsupported OS.
    utils.warn(
      ("Unsupported OS for %s browser: %s"):format(
        config.selected_browser,
        state.os_name
      )
    )
    return nil
  end
  return utils.join_path(state.os_homedir, components)
end

---Emit a debug message. The given arguments are passed through `vim.inspect`
---function and then shown.
---@vararg any
function utils.debug(...)
  if not _TELESCOPE_BOOKMARKS_DEBUG then
    return
  end

  local parts = {}
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    if arg == nil then
      table.insert(parts, "nil")
    elseif type(arg) == "string" then
      table.insert(parts, arg)
    else
      table.insert(parts, vim.inspect(arg))
    end
  end

  vim.api.nvim_out_write(
    ("[telescope-bookmarks] [%s] [DEBUG]: %s\n"):format(
      os.date "%Y-%m-%d %H:%M:%S",
      table.concat(parts, " ")
    )
  )
end

---Emit a warning message.
---@param msg string
function utils.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "telescope-bookmarks.nvim" })
end

---Wrapper around telescope utility function `get_os_command_output` to raise
---an error if there are any, otherwise return the output as it is.
---@param command table
---@return table
function utils.get_os_command_output(command)
  local output, code, err = telescope_utils.get_os_command_output(command)
  if code > 0 then
    error(table.concat(err, "\n"))
  end
  return output
end

---Return a path string made up of the given mix of strings or tables in the
---order they are provided.
---@param ... string|string[]
---@return string
function utils.join_path(...)
  return table.concat(vim.tbl_flatten { ... }, path_sep)
end

return utils
