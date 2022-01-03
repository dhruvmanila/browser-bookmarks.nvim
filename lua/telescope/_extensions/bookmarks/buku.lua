local ok, sqlite = pcall(require, "sqlite")
if not ok then
  error "Buku depends on sqlite.lua (https://github.com/tami5/sqlite.lua)"
end

local buku = {}

local utils = require "telescope._extensions.bookmarks.utils"

---Determine the directory path where the dbfile is stored.
---@see https://github.com/jarun/buku/blob/master/buku#L409
---@param state ConfigState
---@return string
local function get_default_dbdir(state)
  local data_home = os.getenv "XDG_DATA_HOME"
  if not data_home then
    if state.os_name == "Windows_NT" then
      data_home = os.getenv "APPDATA"
      if not data_home then
        return vim.loop.cwd()
      end
    else
      data_home = utils.join_path(state.os_homedir, ".local", "share")
    end
  end
  return utils.join_path(data_home, "buku")
end

---Collect all the bookmarks for Buku.
---@see https://github.com/jarun/buku
---@param state ConfigState
---@return Bookmark[]|nil
function buku.collect_bookmarks(state)
  local dbdir = get_default_dbdir(state)

  local db = sqlite.new(utils.join_path(dbdir, "bookmarks.db")):open()
  local rows = db:select("bookmarks", {
    keys = { "URL", "metadata" },
  })

  local bookmarks = {}
  for _, row in ipairs(rows) do
    table.insert(bookmarks, {
      name = row.metadata,
      path = row.metadata,
      url = row.URL,
    })
  end

  db:close()
  return bookmarks
end

return buku
