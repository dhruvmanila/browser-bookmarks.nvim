local chrome = require "telescope._extensions.bookmarks.chrome"
local utils = require "telescope._extensions.bookmarks.utils"

describe("chrome", function()
  describe("collect_bookmarks", function()
    local match = require "luassert.match"

    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
    end)

    it("should warn if OS not supported", function()
      local bookmarks = chrome.collect_bookmarks {
        os_name = "random",
        selected_browser = "chrome",
      }

      assert.stub(utils.warn).was_called_with(
        match.matches "Unsupported OS for chrome"
      )
      assert.is_nil(bookmarks)
    end)

    it("should warn if file is absent", function()
      local bookmarks = chrome.collect_bookmarks {
        os_name = "Darwin",
        selected_browser = "chrome",
        os_homedir = ".",
      }

      assert.stub(utils.warn).was_called_with(
        match.matches "No chrome bookmarks file found at"
      )
      assert.is_nil(bookmarks)
    end)
  end)

  describe("parse_bookmarks_data", function()
    it("should parse bookmarks file", function()
      local bookmarks = chrome.collect_bookmarks {
        os_name = "Darwin",
        selected_browser = "chrome",
        os_homedir = "spec/fixtures",
      }

      assert.are.same(bookmarks, {
        {
          name = "Google",
          path = "search/Google",
          url = "https://google.com/",
        },
        {
          name = "DuckDuckGo",
          path = "search/nested/DuckDuckGo",
          url = "https://duckduckgo.com/",
        },
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
      })
    end)
  end)
end)
