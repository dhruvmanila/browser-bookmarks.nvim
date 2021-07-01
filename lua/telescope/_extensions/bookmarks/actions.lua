local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local plugin_actions = {}

local url_plugin_function = {
  open_browser = "openbrowser#open",
  vim_external = "external#browser",
}

---Smart URL opener.
---If `state.url_open_plugin` is given, then open it using the plugin function
---otherwise open it using `state.url_open_command`.
---@param state table
---@return function
function plugin_actions.smart_url_opener(state)
  return function(prompt_bufnr)
    local plugin_name = state.url_open_plugin
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)

    if plugin_name and plugin_name ~= "" then
      local fname = url_plugin_function[plugin_name]
      if not fname then
        local supported = table.concat(vim.tbl_keys(url_plugin_function), ", ")
        error(
          string.format(
            "Unsupported plugin opener: %s (%s)",
            plugin_name,
            supported
          )
        )
      end

      vim.fn[fname](selection.value)
    else
      os.execute(
        string.format('%s "%s"', state.url_open_command, selection.value)
      )
    end
  end
end

return plugin_actions
