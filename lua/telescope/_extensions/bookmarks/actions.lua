local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local action_utils = require "telescope.actions.utils"

local utils = require "telescope._extensions.bookmarks.utils"

local plugin_actions = {}

local url_plugin_function = {
  open_browser = "openbrowser#open",
  vim_external = "external#browser",
}

-- Smart URL opener.
--
-- If `config.url_open_plugin` is given, then open it using the plugin function
-- otherwise open it using `config.url_open_command`.
---@param config TelescopeBookmarksConfig
---@return function
function plugin_actions.smart_url_opener(config)
  return function(prompt_bufnr)
    local urls = {}
    action_utils.map_selections(prompt_bufnr, function(selection)
      table.insert(urls, selection.value)
    end)
    if vim.tbl_isempty(urls) then
      table.insert(urls, action_state.get_selected_entry().value)
    end
    actions.close(prompt_bufnr)

    local plugin_name = config.url_open_plugin
    if plugin_name and plugin_name ~= "" then
      local fname = url_plugin_function[plugin_name]
      if not fname then
        local supported = table.concat(vim.tbl_keys(url_plugin_function), ", ")
        utils.warn(
          string.format(
            "Unsupported plugin opener: %s (%s)",
            plugin_name,
            supported
          )
        )
        return
      end

      for _, url in ipairs(urls) do
        vim.fn[fname](url)
      end
    else
      local command = ('%s "%s"'):format(
        config.url_open_command,
        table.concat(urls, '" "')
      )
      local exit_code = os.execute(command)
      if exit_code ~= 0 then
        utils.warn("Failed to open the url(s) with command: " .. command)
      end
    end
  end
end

return plugin_actions
