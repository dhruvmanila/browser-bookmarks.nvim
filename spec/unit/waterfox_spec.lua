local waterfox = require "browser_bookmarks.browsers.waterfox"

local helpers = require "spec.helpers"

describe("waterfox", function()
  describe("collect_bookmarks", function()
    helpers.set_state { os_name = "Darwin", os_homedir = "spec/fixtures" }

    it("should parse bookmarks data", function()
      local bookmarks =
        waterfox.collect_bookmarks { selected_browser = "waterfox" }

      assert.are.same(bookmarks, {
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
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
      })
    end)
  end)
end)
