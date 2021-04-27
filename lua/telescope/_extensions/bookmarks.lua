local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local pathlib = require("telescope.path")

local state = {
  os_name = vim.loop.os_uname().sysname,
  os_home = vim.loop.os_homedir(),
  path_sep = pathlib.separator,
}

---Aliases to be displayed in the prompt title.
local aliases = {
  brave = "Brave",
  google_chrome = "Google Chrome",
  safari = "Safari",
  firefox = "Firefox",
  firefox_dev = "Firefox Developer Edition",
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
  local selected_browser = state.selected_browser

  local module_path = 'telescope._extensions.bookmarks.' .. selected_browser
  local ok, browser = pcall(require, module_path)

  if not ok then
    if not aliases[selected_browser] then
      error("Unsupported browser: " .. selected_browser)
    else
      error(browser)
    end
  end

  local results = browser.collect_bookmarks(state)
  if not results then return end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      {width = config.width * vim.o.columns / 2},
      {remaining = true},
    },
  }

  local function make_display(entry)
    return displayer {
      entry.name,
      {entry.value, "Comment"},
    }
  end

  pickers.new(opts, {
    prompt_title = "Search " .. aliases[selected_browser] .. " Bookmarks",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          display = make_display,
          name = entry.name,
          value = entry.url,
          ordinal = entry.name .. " " .. entry.url,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        os.execute(state.url_open_command .. ' "' .. selection.value .. '" &> /dev/null')
      end)
      return true
    end,
  }):find()
end

return telescope.register_extension {
  setup = function(ext_config)
    set_config_state("selected_browser", ext_config.selected_browser, "brave")
    set_config_state("url_open_command", ext_config.url_open_command, "open")
    set_config_state("firefox_profile_name", ext_config.firefox_profile_name, nil)
  end,
  exports = {bookmarks = bookmarks},
}
