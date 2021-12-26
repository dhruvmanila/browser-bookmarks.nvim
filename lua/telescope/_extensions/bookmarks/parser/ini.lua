local ini = {}

-- Deserialize the INI data from path into a lua table.
--
-- NOTE: This is a very basic parser which parses only sections and key-value
-- pairs.
---@param path string
---@return table
function ini.load(path)
  local result = {}
  local current_section

  for line in io.lines(path) do
    -- Ignore comments.
    if not vim.startswith(line, ";") then
      -- Section headers
      local section = line:match "^%[([^%]]+)%]$"
      if section then
        current_section = section
        result[section] = result[section] or {}
      else
        -- Key=Value pairs
        local key, value = line:match "^([%w_]+)%s-=%s-(.+)$"
        local number_value = tonumber(value)
        if number_value ~= nil then
          value = number_value
        elseif value == "true" then
          value = true
        elseif value == "false" then
          value = false
        end
        if key and value ~= nil then
          result[current_section][key] = value
        end
      end
    end
  end

  return result
end

return ini
