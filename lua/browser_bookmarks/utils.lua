local utils = {}

local Job = require "plenary.job"
local path_sep = require("plenary.path").path.sep

local Browser = require("browser_bookmarks.enum").Browser
local config = require("browser_bookmarks.config").values

local default_config_dir = {
  Darwin = {
    [Browser.BRAVE] = {
      "Library",
      "Application Support",
      "BraveSoftware",
      "Brave-Browser",
    },
    [Browser.BRAVE_BETA] = {
      "Library",
      "Application Support",
      "BraveSoftware",
      "Brave-Browser-Beta",
    },
    [Browser.CHROME] = {
      "Library",
      "Application Support",
      "Google",
      "Chrome",
    },
    [Browser.CHROME_BETA] = {
      "Library",
      "Application Support",
      "Google",
      "Chrome Beta",
    },
    [Browser.CHROMIUM] = {
      "Library",
      "Application Support",
      "Chromium",
    },
    [Browser.EDGE] = {
      "Library",
      "Application Support",
      "Microsoft Edge",
    },
    [Browser.FIREFOX] = {
      "Library",
      "Application Support",
      "Firefox",
    },
    [Browser.QUTEBROWSER] = {
      ".qutebrowser",
    },
    [Browser.SAFARI] = {
      "Library",
      "Safari",
    },
    [Browser.VIVALDI] = {
      "Library",
      "Application Support",
      "Vivaldi",
    },
    [Browser.WATERFOX] = {
      "Library",
      "Application Support",
      "Waterfox",
    },
  },
  Linux = {
    [Browser.BRAVE] = {
      ".config",
      "BraveSoftware",
      "Brave-Browser",
    },
    [Browser.BRAVE_BETA] = {
      ".config",
      "BraveSoftware",
      "Brave-Browser-Beta",
    },
    [Browser.CHROME] = {
      ".config",
      "google-chrome",
    },
    [Browser.CHROME_BETA] = {
      ".config",
      "google-chrome-beta",
    },
    [Browser.CHROMIUM] = {
      ".config",
      "chromium",
    },
    [Browser.EDGE] = {
      ".config",
      "microsoft-edge",
    },
    [Browser.FIREFOX] = {
      ".mozilla",
      "firefox",
    },
    [Browser.QUTEBROWSER] = {
      ".config",
      "qutebrowser",
    },
    [Browser.VIVALDI] = {
      ".config",
      "vivaldi",
    },
    [Browser.WATERFOX] = {
      ".waterfox",
    },
  },
  Windows_NT = {
    [Browser.BRAVE] = {
      "AppData",
      "Local",
      "BraveSoftware",
      "Brave-Browser",
      "User Data",
    },
    [Browser.BRAVE_BETA] = {
      "AppData",
      "Local",
      "BraveSoftware",
      "Brave-Browser-Beta",
      "User Data",
    },
    [Browser.CHROME] = {
      "AppData",
      "Local",
      "Google",
      "Chrome",
      "User Data",
    },
    [Browser.CHROME_BETA] = {
      "AppData",
      "Local",
      "Google",
      "Chrome Beta",
      "User Data",
    },
    [Browser.CHROMIUM] = {
      "AppData",
      "Local",
      "Chromium",
      "User Data",
    },
    [Browser.EDGE] = {
      "AppData",
      "Local",
      "Microsoft",
      "Edge",
      "User Data",
    },
    [Browser.FIREFOX] = {
      "AppData",
      "Roaming",
      "Mozilla",
      "Firefox",
    },
    [Browser.QUTEBROWSER] = {
      "AppData",
      "Roaming",
      "qutebrowser",
      "config",
    },
    [Browser.VIVALDI] = {
      "AppData",
      "Local",
      "Vivaldi",
      "User Data",
    },
    [Browser.WATERFOX] = {
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
---@param selected_browser Browser
---@return string?
function utils.get_config_dir(selected_browser)
  local config_dir = config.config_dir
  if config_dir ~= nil then
    if not utils.path_exists(config_dir) then
      utils.warn(
        (
          "No such directory for %s browser: %s "
          .. "(make sure to provide the absolute path which includes "
          .. "the home directory as well)"
        ):format(selected_browser, config_dir)
      )
      return nil
    end
    return config_dir
  end
  local os_name = vim.loop.os_uname().sysname
  local components = (default_config_dir[os_name] or {})[selected_browser]
  if components == nil then
    -- This assumes that the check for browser support was already done before
    -- calling this function, thus the message for unsupported OS.
    utils.warn(
      ("Unsupported OS for %s browser: %s"):format(selected_browser, os_name)
    )
    return nil
  end
  return utils.join_path(vim.loop.os_homedir(), components)
end

---Emit a debug message. The given arguments are passed through `vim.inspect`
---function and then shown.
---@vararg any
function utils.debug(...)
  if not config.debug then
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
  vim.notify(msg, vim.log.levels.WARN, { title = "browser-bookmarks.nvim" })
end

-- Return the output of the given command. If the command fails, it'll raise
-- an error using the stderr output.
---@param cmd string[]
---@return string
function utils.get_os_command_output(cmd)
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, code = Job:new({
    command = command,
    args = cmd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync()
  if code > 0 then
    error(table.concat(stderr, "\n"))
  end
  return table.concat(stdout, "\n")
end

---Return a path string made up of the given mix of strings or tables in the
---order they are provided.
---@param ... string|string[]
---@return string
function utils.join_path(...)
  return table.concat(vim.tbl_flatten { ... }, path_sep)
end

-- A mapping from browser to the title to be displayed on the search bar.
---@type table<Browser, string>
local title = {
  [Browser.BRAVE] = "Brave",
  [Browser.BRAVE_BETA] = "Brave",
  [Browser.BUKU] = "Buku",
  [Browser.CHROME] = "Chrome",
  [Browser.CHROME_BETA] = "Chrome",
  [Browser.CHROMIUM] = "Chromium",
  [Browser.EDGE] = "Edge",
  [Browser.FIREFOX] = "Firefox",
  [Browser.QUTEBROWSER] = "qutebrowser",
  [Browser.SAFARI] = "Safari",
  [Browser.VIVALDI] = "Vivaldi",
  [Browser.WATERFOX] = "Waterfox",
}

-- Construct and return the prompt for the given browser. If no browser name
-- is provided, the value will be picked up from the config table.
---@param selected_browser? Browser
---@return string
function utils.construct_prompt(selected_browser)
  selected_browser = selected_browser or config.selected_browser
  return "Select " .. title[selected_browser] .. " Bookmarks"
end

return utils
