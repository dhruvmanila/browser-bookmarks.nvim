local telescope_utils = require('telescope.utils')

local utils = {}

---Emit a warning message.
---@param msg string
function utils.warn(msg)
  vim.api.nvim_echo({{"[telescope-bookmarks] " .. msg, "WarningMsg"}}, true, {})
end

---Wrapper around telescope utility function `get_os_command_output` to raise
---an error if there are any, otherwise return the output as it is.
---@param command table
---@return table
function utils.get_os_command_output(command)
  local output, code, err = telescope_utils.get_os_command_output(command)
  if code > 0 then
    error(table.concat(err, "\n"))
  end
  return output
end

return utils
