local M = {}

local config = require "browser_bookmarks.config"
local utils = require "browser_bookmarks.utils"

local url_plugin_function = {
  open_browser = "openbrowser#open",
  vim_external = "external#browser",
}

-- Open the given URLs using a plugin.
---@param urls string[]
local function open_urls_with_plugin(urls)
  local fname = url_plugin_function[config.values.url_open_plugin]
  if not fname then
    local supported = table.concat(vim.tbl_keys(url_plugin_function), ", ")
    utils.warn(
      string.format(
        "Unsupported plugin opener: %s (supported: %s)",
        config.values.url_open_plugin,
        supported
      )
    )
    return
  end

  for _, url in ipairs(urls) do
    vim.fn[fname](url)
  end
end

-- Open the URLs with a command.
---@param urls string[]
local function open_urls_with_command(urls)
  local command = ('%s "%s"'):format(
    config.values.url_open_command,
    table.concat(urls, '" "')
  )
  local exit_code = os.execute(command)
  if exit_code ~= 0 then
    utils.warn("Failed to open the url(s) with command: " .. command)
  end
end

-- Open the URLs in the default browser.
--
-- If `config.url_open_plugin` is given, then open it using the plugin function
-- otherwise open it using `config.url_open_command`.
---@param urls string[]
function M.open_urls(urls)
  local plugin_name = config.values.url_open_plugin
  if plugin_name and plugin_name ~= "" then
    open_urls_with_plugin(urls)
  else
    open_urls_with_command(urls)
  end
end

return M
