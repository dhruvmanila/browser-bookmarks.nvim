local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local telescope_config = require("telescope.config").values
local actions = require "telescope.actions"
local entry_display = require "telescope.pickers.entry_display"

local smart_url_opener =
  require("telescope._extensions.bookmarks.actions").smart_url_opener

---@type TelescopeBookmarksState
local state = {
  os_name = vim.loop.os_uname().sysname,
  os_homedir = vim.loop.os_homedir(),
}

---@type TelescopeBookmarksConfig
local config = {
  full_path = true,
  selected_browser = "brave",
  url_open_command = "open",
  url_open_plugin = nil,
  firefox_profile_name = nil,
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
  vivaldi = "Vivaldi",
}

---Main entrypoint for Telescope.
---@param opts table
local function bookmarks(opts)
  opts = opts or {}
  local selected_browser = config.selected_browser

  if not title[selected_browser] then
    local supported = table.concat(vim.tbl_keys(title), ", ")
    error(
      string.format("Unsupported browser: %s (%s)", selected_browser, supported)
    )
  end

  local browser = require(
    "telescope._extensions.bookmarks." .. selected_browser
  )
  local results = browser.collect_bookmarks(state, config)
  if not results or vim.tbl_isempty(results) then
    return
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 0.5 },
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
        local name = (config.full_path and entry.path or entry.name) or ""
        return {
          display = make_display,
          name = name,
          value = entry.url,
          ordinal = name .. " " .. entry.url,
        }
      end,
    },
    previewer = false,
    sorter = telescope_config.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(smart_url_opener(state))
      return true
    end,
  }):find()
end

return telescope.register_extension {
  setup = function(ext_config)
    config = vim.tbl_extend("force", config, ext_config)
  end,
  exports = { bookmarks = bookmarks },
}
