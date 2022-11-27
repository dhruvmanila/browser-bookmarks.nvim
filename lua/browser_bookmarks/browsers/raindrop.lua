local raindrop = {}

local utils = require "browser_bookmarks.utils"

-- Store the raindrop token for the current Neovim session.
---@type string?
local token

-- Store the raindrop bookmarks for the current Neovim session.
---@type Bookmark[]
local bookmarks = {}

-- A flag to indicate that a job is ongoing for collecting the bookmarks.
local collecting_bookmarks = false

-- Absolute path to the file where the plugin will store the user provided
-- access token.
local token_filepath = utils.join_path(vim.fn.stdpath "data", ".raindrop-token")

-- Token initialization flow:
--
--   1. If the token is already available, exit.
--   2. If the token file is already present, read it. If the token exists
--      in the file and is not empty, exit.
--   3. Otherwise, ask the user for the token and store it in the token file.
local function init_token()
  if token and token ~= "" then
    return
  end

  if utils.path_exists(token_filepath) then
    local file = assert(io.open(token_filepath, "r"))
    token = file:read "*a"
    file:close()
    if token and token ~= "" then
      return
    end
  end

  -- We can't use `vim.ui.input` as the actual implementation could be
  -- asynchronous.
  local input = vim.fn.input {
    prompt = "Please provide the raindrop access token: ",
    cancelreturn = vim.NIL,
  }
  if input ~= vim.NIL then
    local file = assert(io.open(token_filepath, "w"))
    file:write(input)
    file:close()
    token = input
    utils.info("Raindrop access token stored at: " .. token_filepath)
  end
end

-- Return the `curl` command for an API request for the given page number.
---@param page number
---@return string
local function construct_curl_command(page)
  return "curl --silent --show-error --location --compressed "
    .. "--request GET "
    .. ('--header "Authorization: Bearer %s"'):format(token)
    -- Maximum 50 raindrops can be fetched per page.
    -- See: https://developer.raindrop.io/v1/raindrops/multiple#common-parameters
    .. (' "https://api.raindrop.io/rest/v1/raindrops/0?page=%d&perpage=50"'):format(
      page
    )
end

-- Collect the Raindrop bookmarks in the background.
---@param page number?
local function collect_bookmarks(page)
  page = page or 0
  collecting_bookmarks = true
  utils.run_os_command(construct_curl_command(page), function(result)
    if result.exitcode > 0 then
      collecting_bookmarks = false
      error(result.stderr)
    end
    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok then
      collecting_bookmarks = false
      error("Unexpected response body: " .. result.stdout)
    end
    ---@cast data table # `vim.json.decode` cannot return `nil`
    if data.errorMessage ~= nil then
      collecting_bookmarks = false
      error(data.errorMessage)
    end
    if not vim.tbl_isempty(data.items) then
      for _, item in ipairs(data.items) do
        if item.type == "link" or item.type == "article" then
          table.insert(bookmarks, {
            name = item.title,
            path = item.title,
            url = item.link,
          })
        end
      end
      return collect_bookmarks(page + 1)
    end
    collecting_bookmarks = false
  end)
end

-- Collect all the bookmarks from the raindrop.io API.
---@param _ BrowserBookmarksConfig
---@return Bookmark[]|nil
function raindrop.collect_bookmarks(_)
  if collecting_bookmarks then
    utils.info(
      "Job is in progress to collect Raindrop bookmarks. "
        .. "Please try again later."
    )
    return nil
  end

  if not vim.tbl_isempty(bookmarks) then
    return bookmarks
  end

  init_token()
  if not token or token == "" then
    utils.warn(
      "Raindrop access token not provided. Refer to the project README "
        .. "for instructions on how to get the token."
    )
    return nil
  end

  utils.info "Starting a background job to collect Raindrop bookmarks"
  collect_bookmarks()
end

-- Update the Raindrop token stored by the plugin.
---@param new_token string
function raindrop.update_token(new_token)
  vim.validate { token = { new_token, "string" } }
  local file = assert(io.open(token_filepath, "w"))
  file:write(new_token)
  file:close()
  token = new_token
end

-- Clear the cached bookmarks.
--
-- The function is a no-op if a job is ongoing for collecting the bookmarks.
function raindrop.clear_cache()
  if collecting_bookmarks then
    return
  end
  bookmarks = {}
end

return raindrop
