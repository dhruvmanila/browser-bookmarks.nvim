local browser_bookmarks = require "browser_bookmarks"
local config = require "browser_bookmarks.config"
local utils = require "browser_bookmarks.utils"

local helpers = require "spec.helpers"

describe("browser_bookmarks", function()
  insulate("collect", function()
    local browsers = require "browser_bookmarks.browsers"

    it("should use default browser if not passed", function()
      helpers.set_state { os_name = "Darwin", os_homedir = "spec/fixtures" }
      assert.is_nil(rawget(browsers, "brave"))
      local bookmarks = browser_bookmarks.collect()
      assert.is_not_nil(bookmarks)
      assert.is_not_nil(rawget(browsers, "brave"))
    end)

    it("should use browser name if passed", function()
      helpers.set_state { os_name = "Darwin", os_homedir = "spec/fixtures" }
      assert.is_nil(rawget(browsers, "chrome"))
      local bookmarks = browser_bookmarks.collect "chrome"
      assert.is_not_nil(bookmarks)
      assert.is_not_nil(rawget(browsers, "chrome"))
    end)
  end)

  describe("select", function()
    it("should return nil if warning was raised", function()
      stub(utils, "warn")
      helpers.set_state { os_name = "random" }
      local bookmarks = browser_bookmarks.select()
      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      utils.warn:revert()
    end)
  end)

  insulate("vim.ui.select", function()
    local actions = require "browser_bookmarks.actions"

    local args = {}

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function(items, opts, on_choice)
      args = { items = items, opts = opts }
      on_choice(items[1])
    end

    it("should select and open the url", function()
      stub(actions, "open_urls")
      helpers.set_state { os_name = "Darwin", os_homedir = "spec/fixtures" }
      browser_bookmarks.select()

      assert.are.same(args.items, {
        {
          name = "Brave",
          path = "Brave",
          url = "https://brave.com/",
        },
      })
      assert.are.same(args.opts.kind, "browser-bookmarks")
      assert.are.same(args.opts.prompt, "Search Brave Bookmarks")
      assert.stub(actions.open_urls).was_called(1)
      assert.stub(actions.open_urls).was_called_with { "https://brave.com/" }
    end)
  end)
end)
