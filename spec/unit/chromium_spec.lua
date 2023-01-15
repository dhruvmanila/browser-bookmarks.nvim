local chromium = require "telescope._extensions.bookmarks.chromium"

describe("chrome_beta", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local xdg_config_home = vim.env.XDG_CONFIG_HOME
      vim.env.XDG_CONFIG_HOME = nil

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

      vim.env.XDG_CONFIG_HOME = xdg_config_home
    end)
  end)
end)
