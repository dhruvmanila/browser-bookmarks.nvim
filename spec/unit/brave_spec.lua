local brave = require "telescope._extensions.bookmarks.brave"

describe("brave", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local bookmarks = brave.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "brave" }
      )

      assert.are.same(bookmarks, {
        {
          name = "Brave",
          path = "Brave",
          url = "https://brave.com/",
        },
      })
    end)
  end)
end)
