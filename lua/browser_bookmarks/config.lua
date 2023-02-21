local config = {}

-- Config table.
--
-- The table is empty until the `setup` function is called. Once the `setup`
-- function is called, this table gets updated in place. This means that
-- every module which is having a reference to this table will always view
-- the updated values.
--
-- Usage:
--
--    ```lua
--    local config = require("browser_bookmarks.config").values
--    ```
--
-- NOTE: Make sure to not mutate the table directly. Only use the `setup`
-- function to update the values.
---@type BrowserBookmarksConfig
config.values = {}

-- Default configuration for the plugin.
---@type BrowserBookmarksConfig
local defaults = {
  selected_browser = "brave",
  profile_name = nil,
  config_dir = nil,
  full_path = true,
  url_open_command = "open",
  url_open_plugin = nil,
  buku_include_tags = false,
  debug = false,
}

-- Set the configuration value.
---@generic T
---@param opt_name string
---@param value T
---@param default T
local function set_config(opt_name, value, default)
  if value == nil then
    config.values[opt_name] = default
  else
    config.values[opt_name] = value
  end
end

-- Setup the configuration for the plugin.
---@param opts? BrowserBookmarksConfig
function config.setup(opts)
  opts = opts or {}
  for key, default in pairs(defaults) do
    set_config(key, opts[key], default)
  end
end

return config
