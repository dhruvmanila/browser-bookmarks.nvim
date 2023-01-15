local vivaldi = require "telescope._extensions.bookmarks.vivaldi"

describe("vivaldi", function()
  describe("collect_bookmarks", function()
    it("should parse bookmarks file", function()
      local xdg_config_home = vim.env.XDG_CONFIG_HOME
      vim.env.XDG_CONFIG_HOME = nil

      local bookmarks = vivaldi.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "vivaldi" }
      )

      assert.are.same(bookmarks, {
        {
          name = "Vivaldi",
          path = "Vivaldi",
          url = "https://vivaldi.com/",
        },
      })

      vim.env.XDG_CONFIG_HOME = xdg_config_home
    end)
  end)
end)
