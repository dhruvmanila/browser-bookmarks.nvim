local buku = {}

local sqlite = require "sqlite"

local state = require "browser_bookmarks.state"
local utils = require "browser_bookmarks.utils"

-- Determine the directory path where the dbfile is stored.
--
-- The logic of this function is same as that of the original implementation.
--
-- See: https://github.com/jarun/buku/blob/master/buku BukuDb.get_default_dbdir
---@return string
local function get_default_dbdir()
  local data_home = os.getenv "XDG_DATA_HOME"
  if not data_home then
    if state.os_name == "Windows_NT" then
      data_home = os.getenv "APPDATA"
      if not data_home then
        return state.cwd
      end
    else
      data_home = utils.join_path(state.os_homedir, ".local", "share")
    end
  end
  return utils.join_path(data_home, "buku")
end

-- Collect all the bookmarks for Buku.
--
-- See: https://github.com/jarun/buku
---@param config BrowserBookmarksConfig
---@return Bookmark[]?
function buku.collect_bookmarks(config)
  local dbdir = get_default_dbdir()

  local db = sqlite.new(utils.join_path(dbdir, "bookmarks.db")):open()
  local keys = { "url", "metadata" }
  if config.buku_include_tags then
    table.insert(keys, "tags")
  end
  local rows = db:select("bookmarks", { keys = keys })

  local bookmarks = {}
  for _, row in ipairs(rows) do
    local bookmark = {
      name = row.metadata,
      path = row.metadata,
      url = row.URL,
    }
    if config.buku_include_tags then
      -- exclude leading and trailing comma
      bookmark.tags = row.tags:sub(2, -2)
    end
    table.insert(bookmarks, bookmark)
  end

  db:close()
  return bookmarks
end

if _TEST then
  buku._get_default_dbdir = get_default_dbdir
end

return buku
