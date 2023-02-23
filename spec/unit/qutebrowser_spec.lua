local qutebrowser = require "browser_bookmarks.browsers.qutebrowser"
local utils = require "browser_bookmarks.utils"

local helpers = require "spec.helpers"

describe("qutebrowser", function()
  describe("collect_bookmarks", function()
    local match = require "luassert.match"

    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
    end)

    it("should return nil if get_config_dir fails", function()
      -- Unsupported OS
      helpers.set_state { os_name = "random" }
      local bookmarks =
        qutebrowser.collect_bookmarks { selected_browser = "qutebrowser" }

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
    end)

    it("should warn if file is absent", function()
      helpers.set_state { os_name = "Darwin", os_homedir = "." }
      local bookmarks =
        qutebrowser.collect_bookmarks { selected_browser = "qutebrowser" }

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "No qutebrowser bookmarks file found at")
    end)

    it("should parse bookmarks file", function()
      helpers.set_state { os_name = "Darwin", os_homedir = "spec/fixtures" }
      local bookmarks =
        qutebrowser.collect_bookmarks { selected_browser = "qutebrowser" }

      assert.are.same(bookmarks, {
        {
          name = "",
          path = "",
          url = "https://news.ycombinator.com",
        },
        {
          name = "qutebrowser",
          path = "qutebrowser",
          url = "https://qutebrowser.org",
        },
        {
          name = "dhruvmanila/telescope-bookmarks.nvim: A Neovim Telescope extension to open your browser bookmarks right from the editor!",
          path = "dhruvmanila/telescope-bookmarks.nvim: A Neovim Telescope extension to open your browser bookmarks right from the editor!",
          url = "https://github.com/dhruvmanila/telescope-bookmarks.nvim",
        },
      })
    end)
  end)
end)
