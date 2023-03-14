local M = {}

local actions = require "browser_bookmarks.actions"
local browsers = require "browser_bookmarks.browsers"
local config = require "browser_bookmarks.config"
local utils = require "browser_bookmarks.utils"

-- Collect all the bookmarks for either the given browser or the selected
-- browser in the config table.
--
-- An error will be raised if the selected browser is unsupported.
-- A warning notification will be sent using `vim.notify` if there's any
-- kind of problem while collecting the bookmarks.
---@param selected_browser? Browser
---@return Bookmark[]?
function M.collect(selected_browser)
  -- This config table includes the selected browser without overriding
  -- the actual selection during plugin setup.
  local current_config = vim.tbl_extend("force", config.values, {
    selected_browser = selected_browser,
  })
  return browsers[current_config.selected_browser].collect_bookmarks(
    current_config
  )
end

-- Select a bookmark using `vim.ui.select` and open it in the default browser.
--
-- If the `selected_browser` parameter is not given, the value is taken from
-- the config table. The `kind` option value in `vim.ui.select` is
-- "browser-bookmarks".
--
-- Error / warning is given in the same way as the `collect` function.
---@param selected_browser? Browser
function M.select(selected_browser)
  local bookmarks = M.collect(selected_browser)
  if bookmarks == nil then
    return
  end

  local opts = {
    prompt = utils.construct_prompt(selected_browser),
    ---@param item Bookmark
    ---@return string
    format_item = function(item)
      local name = (config.values.full_path and item.path or item.name) or ""
      if config.values.buku_include_tags then
        name = ("%s (%s)"):format(name, item.tags)
      end
      return ("%s (%s)"):format(name, item.url)
    end,
    kind = "browser-bookmarks",
  }

  vim.ui.select(
    bookmarks,
    opts,
    ---@param item Bookmark?
    function(item)
      if item then
        actions.open_urls { item.url }
      end
    end
  )
end

-- Setup function for the plugin.
---@param opts? BrowserBookmarksConfig
function M.setup(opts)
  config.setup(opts)
end

return M
