local helpers = {}

-- Read the content from the given filename.
---@param filename string
---@return string
function helpers.readfile(filename)
  local file = io.open(filename, "r")
  if not file then
    error("Unable to open the file: " .. filename)
  end
  local content = file:read "*a"
  if not content then
    error("Unable to read the file: " .. filename)
  end
  file:close()
  return content
end

return helpers
