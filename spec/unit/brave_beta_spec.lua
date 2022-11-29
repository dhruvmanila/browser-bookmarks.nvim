local brave_beta = require "telescope._extensions.bookmarks.brave_beta"

describe("brave beta", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local bookmarks = brave_beta.collect_bookmarks(
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
