local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error "Telescope interface requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)"
end

local action_state = require "telescope.actions.state"
local action_utils = require "telescope.actions.utils"
local entry_display = require "telescope.pickers.entry_display"
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local telescope_actions = require "telescope.actions"
local telescope_config = require("telescope.config").values

local actions = require "browser_bookmarks.actions"
local browser_bookmarks = require "browser_bookmarks"
local config = require "browser_bookmarks.config"
local utils = require "browser_bookmarks.utils"

-- Smart URL opener with multi-selection support.
--
-- If `config.url_open_plugin` is given, then open it using the plugin function
-- otherwise open it using `config.url_open_command`.
---@param prompt_bufnr number
local function smart_url_opener(prompt_bufnr)
  local urls = {}
  action_utils.map_selections(prompt_bufnr, function(selection)
    table.insert(urls, selection.value)
  end)
  if vim.tbl_isempty(urls) then
    table.insert(urls, action_state.get_selected_entry().value)
  end
  telescope_actions.close(prompt_bufnr)
  actions.open_urls(urls)
end

---Main entrypoint for Telescope.
---@param opts table
local function bookmarks(opts)
  opts = opts or {}
  utils.debug("telescope opts:", opts)

  local results = browser_bookmarks.collect()
  if not results then
    return nil
  end
  if vim.tbl_isempty(results) then
    return utils.warn(
      ("No bookmarks available for %s browser"):format(
        config.values.selected_browser
      )
    )
  end

  local displayer = entry_display.create {
    separator = " ",
    items = config.values.buku_include_tags and {
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
    if config.values.buku_include_tags then
      table.insert(display_columns, 2, { entry.tags, "Special" })
    end
    return displayer(display_columns)
  end

  pickers
    .new(opts, {
      prompt_title = utils.construct_prompt(config.values.selected_browser),
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          local name = (config.values.full_path and entry.path or entry.name)
            or ""
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
        telescope_actions.select_default:replace(smart_url_opener)
        return true
      end,
    })
    :find()
end

return telescope.register_extension {
  setup = function(ext_config)
    if ext_config and not vim.tbl_isempty(ext_config) then
      utils.warn(
        "Configuring the plugin using the telescope extension is deprecated. "
          .. "Please use the `setup` function from the main module:\n\n"
          .. ("require('browser_bookmarks').setup(%s)"):format(
            vim.inspect(ext_config)
          )
      )
    end
  end,
  exports = {
    bookmarks = bookmarks,
  },
}
