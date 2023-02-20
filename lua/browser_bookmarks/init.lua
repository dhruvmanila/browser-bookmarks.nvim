local M = {}

local Browser = require("browser_bookmarks.enum").Browser
local actions = require "browser_bookmarks.actions"
local browsers = require "browser_bookmarks.browsers"
local config = require "browser_bookmarks.config"
local utils = require "browser_bookmarks.utils"

local os_name = vim.loop.os_uname().sysname

-- Collect all the bookmarks for either the given browser or the selected
-- browser in the config table.
--
-- An error will be raised if the selected browser is unsupported.
-- A warning notification will be sent using `vim.notify` if there's any
-- kind of problem while collecting the bookmarks.
--
---@param selected_browser? Browser
---@return Bookmark[]?
function M.collect(selected_browser)
  -- This config table includes the selected browser without overriding
  -- the actual selection during plugin setup.
  local current_config = vim.tbl_extend("force", {}, config.values, {
    selected_browser = selected_browser,
  })
  return browsers[current_config.selected_browser].collect_bookmarks(
    current_config
  )
end

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
      if item.tags then
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

---@param opts BrowserBookmarksConfig
function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("BrowserBookmarks", function(info)
    local selected_browser
    if info.args ~= "" then
      selected_browser = info.args
    end
    M.select(selected_browser)
  end, {
    nargs = "?",
    complete = function(arglead)
      arglead = arglead and (".*" .. arglead .. ".*")
      return vim.tbl_filter(function(browser)
        if os_name ~= "Darwin" and browser == Browser.SAFARI then
          return false
        end
        return browser:match(arglead)
      end, vim.tbl_values(Browser))
    end,
    desc = "Select bookmark(s) for a browser",
  })
end

return M
