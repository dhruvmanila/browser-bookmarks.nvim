local utils = require('telescope.utils')

local rootdir = string.match(debug.getinfo(1).source, "@(.-telescope%-bookmarks%.nvim)")
local program_path = rootdir .. "/bin/lz4jsoncat"

local profiles_path = {
  Darwin = {"Library", "Application Support", "Firefox", "Profiles"},
  Linux = {".mozilla", "firefox"},
  Windows_NT = {"AppData", "Roaming", "Mozilla", "Firefox", "Profiles"},
}

local firefox = {}

local exclude_names = {"menu", "toolbar"}

local function warn(msg)
  vim.api.nvim_echo({{msg, 'WarningMsg'}}, true, {})
end

local function get_os_command_output(command)
  local output, code, err = utils.get_os_command_output(command)
  if code > 0 then
    error(table.concat(err, "\n"))
  end
  return output
end

local function firefox_profile_name(state, profile_path)
  if state.firefox_profile_name then
    return state.firefox_profile_name
  end

  local dirs
  if state.os_name == "Windows_NT" then
    -- Only provide the directory/file name
    dirs = get_os_command_output({"dir", "/b", profile_path})
  else
    dirs = get_os_command_output({"ls", profile_path})
  end

  -- Default profile name
  -- For release edition, the name changed from 'default' to 'default-release'
  -- https://blog.nightly.mozilla.org/2019/01/14/moving-to-a-profile-per-install-architecture/
  -- NOTE: Order matters (first match is chosen)
  local suffix_pattern = {"%.default%-release", "%.default"}
  if state.selected_browser == "firefox_dev" then
    suffix_pattern = {"%.dev%-edition%-default"}
  end

  local match = {}
  for _, dir in ipairs(dirs) do
    for _, pat in ipairs(suffix_pattern) do
      local matched = string.match(dir, ".*" .. pat .. "$")
      if matched and matched ~= "" then
        table.insert(match, matched)
      end
    end
  end
  return match[1]
end

local function get_latest_bookmark_file(state, bookmark_dir)
  local files
  if state.os_name == "Windows_NT" then
    -- https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir
    files = get_os_command_output({"dir", "/b", "/o-d", bookmark_dir})
  else
    files = get_os_command_output({"ls", "-t", bookmark_dir})
  end
  return files[1]
end

local function parse_bookmarks_data(data)
  local items = {}

  local function insert_items(parent, bookmark)
    local name = ""
    if not vim.tbl_contains(exclude_names, bookmark.title) then
      name = parent ~= "" and parent .. "/" .. bookmark.title or bookmark.title
    end
    if bookmark.type == "text/x-moz-place-container" then
      local children = bookmark.children or {}
      for _, child in ipairs(children) do
        insert_items(name, child)
      end
    else
      table.insert(items, {name = name, url = bookmark.uri})
    end
  end

  insert_items("", data)
  return items
end

function firefox.collect_bookmarks(state)
  local sep = state.path_sep
  local components = profiles_path[state.os_name]
  local profile_path = state.os_home .. sep .. table.concat(components, sep)
  local profile_name = firefox_profile_name(state, profile_path)

  if not profile_name then
    warn("[Telescope] No Firefox profile found at: " .. profile_path)
    return nil
  end

  local bookmark_dir = profile_path .. sep .. profile_name .. sep .. "bookmarkbackups"
  local bookmark_file = get_latest_bookmark_file(state, bookmark_dir)

  if not bookmark_file then
    warn('[Telescope] No Firefox bookmark file found at: ' .. bookmark_dir)
    return nil
  end

  bookmark_file = bookmark_dir .. state.path_sep .. bookmark_file
  local output = get_os_command_output({program_path, bookmark_file})
  local json_output = vim.fn.json_decode(output)
  return parse_bookmarks_data(json_output)
end

return firefox
