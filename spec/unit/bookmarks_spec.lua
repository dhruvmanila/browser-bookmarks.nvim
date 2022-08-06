describe("bookmarks", function()
  insulate("config", function()
    local bookmarks = require "telescope._extensions.bookmarks"

    it("should populate the config table with defaults", function()
      assert.are.same(bookmarks._config, {})
      bookmarks.setup {}
      assert.are.same(bookmarks._config, {
        full_path = true,
        selected_browser = "brave",
        url_open_command = "open",
        url_open_plugin = nil,
        firefox_profile_name = nil,
        waterfox_profile_name = nil,
        buku_include_tags = false,
      })
    end)
  end)

  insulate("config", function()
    local bookmarks = require "telescope._extensions.bookmarks"

    it("should prefer user config over defaults", function()
      local test_config = {
        full_path = false,
        selected_browser = "firefox",
        url_open_command = "xdg-open",
        url_open_plugin = "vim_external",
        firefox_profile_name = "default-release",
        waterfox_profile_name = "default",
        buku_include_tags = true,
      }
      assert.are.same(bookmarks._config, {})
      bookmarks.setup(test_config)
      assert.are.same(bookmarks._config, test_config)
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
