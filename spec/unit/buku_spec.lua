local buku = require "browser_bookmarks.browsers.buku"

local helpers = require "spec.helpers"

describe("buku", function()
  local env = {}

  before_each(function()
    env.XDG_DATA_HOME = vim.env.XDG_DATA_HOME
    env.APPDATA = vim.env.APPDATA
  end)

  after_each(function()
    vim.env.XDG_DATA_HOME = env.XDG_DATA_HOME
    vim.env.APPDATA = env.APPDATA
  end)

  describe("get_default_dbdir", function()
    it("when XDG_DATA_HOME is available", function()
      vim.env.XDG_DATA_HOME = "."
      local dbdir = buku._get_default_dbdir()
      assert.are.equal(dbdir, "./buku")
    end)

    it("when XDG_DATA_HOME not available on Linux", function()
      helpers.set_state { os_name = "Linux", os_homedir = "." }
      local dbdir = buku._get_default_dbdir()
      assert.are.equal(dbdir, "./.local/share/buku")
    end)

    it("when APPDATA is available on windows", function()
      helpers.set_state { os_name = "Windows_NT" }
      vim.env.APPDATA = "."
      local dbdir = buku._get_default_dbdir()
      assert.are.equal(dbdir, "./buku")
    end)

    it("when APPDATA is not available on windows", function()
      helpers.set_state { os_name = "Windows_NT", cwd = "/home/user" }
      local dbdir = buku._get_default_dbdir()
      assert.are.equal(dbdir, "/home/user")
    end)
  end)

  describe("collect_bookmarks", function()
    it("should parse bookmarks data", function()
      vim.env.XDG_DATA_HOME = "spec/fixtures"
      assert.are.same(buku.collect_bookmarks { buku_include_tags = true }, {
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
          tags = "coding",
        },
        {
          name = "Google",
          path = "Google",
          url = "https://google.com/",
          tags = "search",
        },
      })
    end)

    it("should not include tags if `buku_include_tags = false`", function()
      vim.env.XDG_DATA_HOME = "spec/fixtures"
      assert.are.same(buku.collect_bookmarks { buku_include_tags = false }, {
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
        {
          name = "Google",
          path = "Google",
          url = "https://google.com/",
        },
      })
    end)
  end)
end)
