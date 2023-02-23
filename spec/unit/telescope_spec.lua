describe("telescope bookmarks", function()
  insulate("config", function()
    local bookmarks = require "telescope._extensions.bookmarks"
    local config = require "browser_bookmarks.config"

    it("should prefer user config over defaults", function()
      local test_config = {
        selected_browser = "firefox",
        profile_name = "default",
        config_dir = "/home/user",
        full_path = false,
        url_open_command = "xdg-open",
        url_open_plugin = "vim_external",
        buku_include_tags = true,
        debug = true,
      }
      assert.are.same(config.values, config._defaults)
      bookmarks.setup(test_config)
      assert.are.same(config.values, test_config)
    end)
  end)

  insulate("entrypoint", function()
    local bookmarks = require "telescope._extensions.bookmarks"

    it("should error if browser not supported", function()
      assert.error_matches(function()
        bookmarks.setup { selected_browser = "random" }
        bookmarks.exports.bookmarks()
      end, "Unsupported browser")
    end)
  end)
end)
