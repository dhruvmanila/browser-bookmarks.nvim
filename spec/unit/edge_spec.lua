local edge = require "telescope._extensions.bookmarks.edge"

describe("edge", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local bookmarks = edge.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "edge" }
      )

      assert.are.same(bookmarks, {
        {
          name = "Microsoft Edge",
          path = "Microsoft Edge",
          url = "https://www.microsoft.com/en-us/edge",
        },
      })
    end)
  end)
end)
