local edge = require "telescope._extensions.bookmarks.edge"

describe("edge", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local xdg_config_home = vim.env.XDG_CONFIG_HOME
      vim.env.XDG_CONFIG_HOME = nil

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

      vim.env.XDG_CONFIG_HOME = xdg_config_home
    end)
  end)
end)
