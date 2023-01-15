local brave = require "telescope._extensions.bookmarks.brave"

describe("brave", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local xdg_config_home = vim.env.XDG_CONFIG_HOME
      vim.env.XDG_CONFIG_HOME = nil

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

      vim.env.XDG_CONFIG_HOME = xdg_config_home
    end)
  end)
end)
