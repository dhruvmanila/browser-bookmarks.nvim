local utils = {}

local Browser = require("browser_bookmarks.enum").Browser
local config = require "browser_bookmarks.config"
local state = require "browser_bookmarks.state"

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
  local _, err = vim.loop.fs_stat(path)
  return err == nil
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
  local config_dir = config.values.config_dir
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
  local components = (default_config_dir[state.os_name] or {})[selected_browser]
  if components == nil then
    -- This assumes that the check for browser support was already done before
    -- calling this function, thus the message for unsupported OS.
    utils.warn(
      ("Unsupported OS for %s browser: %s"):format(
        selected_browser,
        state.os_name
      )
    )
    return nil
  end
  return utils.join_path(state.os_homedir, components)
end

-- Emit a debug message. The given arguments are passed through `vim.inspect`
-- function and then shown.
---@vararg any
function utils.debug(...)
  if not config.values.debug then
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
    ("[browser-bookmarks] [%s] [DEBUG]: %s\n"):format(
      os.date "%Y-%m-%d %H:%M:%S",
      table.concat(parts, " ")
    )
  )
end

-- Emit a warning message.
---@param msg string
function utils.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "browser-bookmarks.nvim" })
end

-- Timeout value for job execution. The unit is milliseconds.
local timeout = 5 * 1000

-- Return the output of the given command.
--
-- An error is raised in the following cases:
--    - invalid arguments
--    - cmd[0] is not executable
--    - execution timed out
--    - cmd exited with non-zero exit code
--
-- This uses Neovim's |job-control| API to run the cmd.
--
-- Timeout value is 5 seconds. After that, `jobstop` is used to stop the job.
---@param cmd string
---@return string
function utils.get_os_command_output(cmd)
  local stdout, stderr

  -- Channel callback for stdout and stderr.
  ---@param data string[]
  ---@param event 'stdout'|'stderr'
  local function on_data(_, data, event)
    -- Remove the trailing newline which in the table is an empty string
    -- as the last element.
    data = table.concat(vim.list_slice(data, 1, #data - 1), "\n")
    utils.debug(event .. ":", data)
    if event == "stdout" then
      stdout = data
    elseif event == "stderr" then
      stderr = data
    end
  end

  utils.debug("executing cmd:", cmd)
  local jobid = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = on_data,
    on_stderr = on_data,
  })
  if jobid <= 0 then
    error("invalid command: " .. cmd)
  end

  local exitcode = vim.fn.jobwait({ jobid }, timeout)[1]
  if exitcode == -1 then
    -- Make sure to stop the job after timeout.
    vim.fn.jobstop(jobid)
    error(("timeout (%ds) while executing '%s'"):format(timeout / 1000, cmd))
  elseif exitcode > 0 then
    error(stderr)
  end

  return stdout
end

-- The character used by the operating system to separate pathname components.
-- This is '/' for POSIX and '\\' for Windows.
local sep = package.config:sub(1, 1)

-- Return a path string made up of the given mix of strings or tables in the
-- order they are provided.
---@param ... string|string[]
---@return string
function utils.join_path(...)
  return table.concat(vim.tbl_flatten { ... }, sep)
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
  selected_browser = selected_browser or config.values.selected_browser
  return "Select " .. title[selected_browser] .. " Bookmarks"
end

return utils
