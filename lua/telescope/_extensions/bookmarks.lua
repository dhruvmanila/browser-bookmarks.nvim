local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local telescope_config = require("telescope.config").values
local actions = require "telescope.actions"
local entry_display = require "telescope.pickers.entry_display"

local utils = require "telescope._extensions.bookmarks.utils"
local smart_url_opener =
  require("telescope._extensions.bookmarks.actions").smart_url_opener

---@type TelescopeBookmarksState
local state = {
  os_name = vim.loop.os_uname().sysname,
  os_homedir = vim.loop.os_homedir(),
}

---@type TelescopeBookmarksConfig
local config = {}

---@enum Browser
local Browser = {
  BRAVE = "brave",
  BRAVE_BETA = "brave_beta",
  BUKU = "buku",
  CHROME = "chrome",
  CHROME_BETA = "chrome_beta",
  CHROMIUM = "chromium",
  EDGE = "edge",
  FIREFOX = "firefox",
  QUTEBROWSER = "qutebrowser",
  SAFARI = "safari",
  VIVALDI = "vivaldi",
  WATERFOX = "waterfox",
}

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

-- An array of browser which supports specifying profile name.
---@type Browser[]
local profile_browsers = {
  Browser.BRAVE,
  Browser.BRAVE_BETA,
  Browser.CHROME,
  Browser.CHROME_BETA,
  Browser.CHROMIUM,
  Browser.EDGE,
  Browser.FIREFOX,
  Browser.VIVALDI,
  Browser.WATERFOX,
}

-- Set the configuration state.
---@param opt_name string
---@param value any
---@param default any
local function set_config(opt_name, value, default)
  if value == nil then
    config[opt_name] = default
  else
    config[opt_name] = value
  end
end

---Main entrypoint for Telescope.
---@param opts table
local function bookmarks(opts)
  opts = opts or {}
  utils.debug("opts:", opts)

  local selected_browser = config.selected_browser
  if not title[selected_browser] then
    error(
      string.format(
        "Unsupported browser: %s (supported: %s)",
        selected_browser,
        table.concat(vim.tbl_keys(title), ", ")
      )
    )
  end

  if config.profile_name ~= nil then
    if not vim.tbl_contains(profile_browsers, selected_browser) then
      utils.warn(
        ("Unsupported browser for 'profile_name': %s (supported: %s)"):format(
          selected_browser,
          table.concat(profile_browsers, ", ")
        )
      )
      return nil
    end
  end

  local browser =
    require("telescope._extensions.bookmarks." .. selected_browser)
  local results = browser.collect_bookmarks(state, config)
  if not results then
    return nil
  end
  if vim.tbl_isempty(results) then
    return utils.warn(
      ("No bookmarks available for %s browser"):format(selected_browser)
    )
  end

  local displayer = entry_display.create {
    separator = " ",
    items = config.buku_include_tags and {
      { width = 0.3 },
      { width = 0.2 },
      { remaining = true },
    } or {
      { width = 0.5 },
      { remaining = true },
    },
  }

  local function make_display(entry)
    local display_columns = {
      entry.name,
      { entry.value, "Comment" },
    }
    if config.buku_include_tags then
      table.insert(display_columns, 2, { entry.tags, "Special" })
    end
    return displayer(display_columns)
  end

  pickers
    .new(opts, {
      prompt_title = "Search " .. title[selected_browser] .. " Bookmarks",
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          local name = (config.full_path and entry.path or entry.name) or ""
          return {
            display = make_display,
            name = name,
            value = entry.url,
            tags = entry.tags,
            ordinal = name .. " " .. (entry.tags or "") .. " " .. entry.url,
          }
        end,
      },
      previewer = false,
      sorter = telescope_config.generic_sorter(opts),
      attach_mappings = function()
        actions.select_default:replace(smart_url_opener(config))
        return true
      end,
    })
    :find()
end

return telescope.register_extension {
  setup = function(ext_config)
    if ext_config.debug then
      _G._TELESCOPE_BOOKMARKS_DEBUG = true
    end

    set_config("full_path", ext_config.full_path, true)
    set_config("selected_browser", ext_config.selected_browser, "brave")
    set_config("url_open_command", ext_config.url_open_command, "open")
    set_config("url_open_plugin", ext_config.url_open_plugin, nil)
    set_config("profile_name", ext_config.profile_name, nil)
    set_config("config_dir", ext_config.config_dir, nil)
    set_config("buku_include_tags", ext_config.buku_include_tags, false)

    utils.debug("state:", state)
    utils.debug("config:", config)
  end,
  exports = {
    bookmarks = bookmarks,
  },
  _config = _TEST and config,
}
