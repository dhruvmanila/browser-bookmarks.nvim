local chromium = require "telescope._extensions.bookmarks.chromium"

describe("chrome_beta", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local bookmarks = chromium.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chromium" }
      )

      assert.are.same(bookmarks, {
        {
          name = "Chromium",
          path = "Chromium",
          url = "https://www.chromium.org/Home/",
        },
      })
    end)
  end)
end)
