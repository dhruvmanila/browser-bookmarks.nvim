local config = {}

-- Config table.
--
-- This is initialized with the default values.
--
-- Do NOT keep a reference to this table in other module as the table
-- is not updated in-place.
--
-- Usage:
--
--    ```lua
--    local config = require("browser_bookmarks.config")
--
--    -- Access the table from the module
--    config.values.selected_browser
--
--    -- And not by keeping a reference around
--    local config = require("browser_bookmarks.config").values
--
--    -- This might not give the actual value of the table
--    config.selected_browser
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

-- Setup the configuration for the plugin.
--
-- This resets the config to the default values, updating the ones provided
-- in the `opts` table.
--
-- To set/reset the config table to the default values, simply call the
-- function without providing any arguments.
---@param opts? BrowserBookmarksConfig
function config.setup(opts)
  config.values = vim.tbl_extend("force", {}, defaults, opts or {})
end

-- Setup with the default values.
config.setup()

if _TEST then
  config._defaults = defaults
end

return config
