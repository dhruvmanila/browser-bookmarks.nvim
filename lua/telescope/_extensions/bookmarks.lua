local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local config = require("telescope.config").values
local actions = require "telescope.actions"
local entry_display = require "telescope.pickers.entry_display"

local utils = require "telescope._extensions.bookmarks.utils"
local smart_url_opener =
  require("telescope._extensions.bookmarks.actions").smart_url_opener

---@type ConfigState
local state = {
  os_name = vim.loop.os_uname().sysname,
  os_homedir = vim.loop.os_homedir(),
}

---Prompt title.
local title = {
  brave = "Brave",
  buku = "Buku",
  chrome = "Chrome",
  chrome_beta = "Chrome",
  edge = "Edge",
  firefox = "Firefox",
  safari = "Safari",
}

---Set the configuration state.
---@param opt_name string
---@param value any
---@param default any
local function set_config_state(opt_name, value, default)
  state[opt_name] = value == nil and default or value
end

---Main entrypoint for Telescope.
---@param opts table
local function bookmarks(opts)
  opts = opts or {}
  -- TODO: Deprecation warning start: Removal scheduled at: 31/01/2022
  if state.selected_browser == "google_chrome" then
    utils.warn "Deprecated browser name: 'google_chrome'. Please use 'chrome' instead."
    state.selected_browser = "chrome"
  end
  -- TODO: Deprecation warning end
  local selected_browser = state.selected_browser

  if not title[selected_browser] then
    local supported = table.concat(vim.tbl_keys(title), ", ")
    error(
      string.format("Unsupported browser: %s (%s)", selected_browser, supported)
    )
  end

  local browser = require(
    "telescope._extensions.bookmarks." .. selected_browser
  )
  local results = browser.collect_bookmarks(state)
  if not results or vim.tbl_isempty(results) then
    return
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 65 },
      { remaining = true },
    },
  }

  local function make_display(entry)
    return displayer {
      entry.name,
      { entry.value, "Comment" },
    }
  end

  pickers.new(opts, {
    prompt_title = "Search " .. title[selected_browser] .. " Bookmarks",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        local name = (state.full_path and entry.path or entry.name) or ""
        return {
          display = make_display,
          name = name,
          value = entry.url,
          ordinal = name .. " " .. entry.url,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(smart_url_opener(state))
      return true
    end,
  }):find()
end

return telescope.register_extension {
  setup = function(ext_config)
    set_config_state("full_path", ext_config.full_path, true)
    set_config_state("selected_browser", ext_config.selected_browser, "brave")
    set_config_state("url_open_command", ext_config.url_open_command, "open")
    set_config_state("url_open_plugin", ext_config.url_open_plugin, nil)
    set_config_state(
      "firefox_profile_name",
      ext_config.firefox_profile_name,
      nil
    )
  end,
  exports = { bookmarks = bookmarks },
}
