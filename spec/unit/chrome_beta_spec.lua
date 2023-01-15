local chrome_beta = require "telescope._extensions.bookmarks.chrome_beta"

describe("chrome_beta", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local xdg_config_home = vim.env.XDG_CONFIG_HOME
      vim.env.XDG_CONFIG_HOME = nil

      local bookmarks = chrome_beta.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chrome_beta" }
      )

      assert.are.same(bookmarks, {
        {
          name = "Chrome Beta",
          path = "Chrome Beta",
          url = "https://www.google.com/chrome/beta/",
        },
      })

      vim.env.XDG_CONFIG_HOME = xdg_config_home
    end)
  end)
end)
