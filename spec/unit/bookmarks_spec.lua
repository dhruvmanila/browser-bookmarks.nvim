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
        profile_name = nil,
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
        profile_name = "default",
        buku_include_tags = true,
      }
      assert.are.same(bookmarks._config, {})
      bookmarks.setup(test_config)
      assert.are.same(bookmarks._config, test_config)
    end)
  end)

  insulate("entrypoint", function()
    local bookmarks = require "telescope._extensions.bookmarks"
    local utils = require "telescope._extensions.bookmarks.utils"

    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
    end)

    it("should error if browser not supported", function()
      assert.error_matches(function()
        bookmarks.setup { selected_browser = "random" }
        bookmarks.exports.bookmarks()
      end, "Unsupported browser")
    end)

    it(
      "should warn if browser not supported to specify profile name",
      function()
        bookmarks.setup { selected_browser = "safari", profile_name = "default" }
        local bookmarks = bookmarks.exports.bookmarks()

        assert.is_nil(bookmarks)
        assert.stub(utils.warn).was_called(1)
        assert
          .stub(utils.warn)
          .was_called_with(match.matches "Unsupported browser for 'profile_name'")
      end
    )
  end)
end)
