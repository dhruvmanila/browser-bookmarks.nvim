local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')

local state = {}
local os_name = vim.loop.os_uname().sysname
local os_home = vim.loop.os_homedir()

local path = {
  Darwin = {
    brave = "/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks",
    google_chrome = "/Library/Application Support/Google/Chrome/Default/Bookmarks",
  },
  Linux = {
    brave = "/.config/BraveSoftware/Brave-Browser/Default/Bookmarks",
    google_chrome = "/.config/google-chrome/Default/Bookmarks",
  },
  Windows = {
    brave = "/AppData/Local/BraveSoftware/Brave-Browser/User Data/Default/Bookmarks",
    google_chrome = "/AppData/Local/Google/Chrome/User Data/Default/Bookmarks",
  },
}

---Default categories of bookmarks to look for.
local categories = {'bookmark_bar', 'synced', 'other'}

---Set the configuration state.
---@param opt_name string
---@param value any
---@param default any
local function set_config_state(opt_name, value, default)
  state[opt_name] = value == nil and default or value
end

---Collect all the bookmarks in a table in the following form:
---{
---  {name = bookmark.name, url = bookmark.url},
---  ...,
---}
---@return table
local function collect_bookmarks()
  local items = {}
  local filename = os_home .. path[os_name][state.selected_browser]
  local file = io.open(filename, "r")

  if not file then
    error("Unable to find the bookmarks file at: ", filename)
  end

  local content = file:read("*a")
  file:close()
  local json_content = vim.fn.json_decode(content)

  local function insert_items(parent, bookmark)
    local name = parent
      and (parent ~= '' and parent .. '/' .. bookmark.name or bookmark.name)
      or ''
    if bookmark.type == 'folder' then
      for _, child in ipairs(bookmark.children) do
        insert_items(name, child)
      end
    else
      table.insert(items, {name = name, url = bookmark.url})
    end
  end

  for _, category in ipairs(categories) do
    insert_items(nil, json_content.roots[category])
  end
  return items
end

---@type function
local displayer = entry_display.create {
  separator = ' ',
  items = {
    {width = 65},
    {remaining = true},
  },
}

---@param entry table
local function make_display(entry)
  return displayer {
    entry.name,
    {entry.value, 'Comment'},
  }
end

---Entry maker for the telescope finder.
---@param entry table
---@return table
local function entry_maker(entry)
  return {
    display = make_display,
    name = entry.name,
    value = entry.url,
    ordinal = entry.name .. ' ' .. entry.url,
  }
end

local function bookmarks(opts)
  opts = opts or {}
  local results = collect_bookmarks()

  pickers.new(opts, {
    prompt_title = 'Search Bookmarks',
    finder = finders.new_table {
      results = results,
      entry_maker = entry_maker,
    },
    previewer = false,
    sorter = config.file_sorter(opts),
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
  end,
  exports = {bookmarks = bookmarks},
}
