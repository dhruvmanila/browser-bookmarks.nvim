local qutebrowser = require "telescope._extensions.bookmarks.qutebrowser"
local utils = require "telescope._extensions.bookmarks.utils"

describe("qutebrowser", function()
  describe("collect_bookmarks", function()
    local match = require "luassert.match"

    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
    end)

    it("should warn if OS not supported", function()
      local bookmarks = qutebrowser.collect_bookmarks { os_name = "random" }

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Unsupported OS for qutebrowser")
    end)

    it("should warn if file is absent", function()
      local bookmarks = qutebrowser.collect_bookmarks {
        os_name = "Darwin",
        os_homedir = ".",
      }

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "No qutebrowser bookmarks file found at")
    end)

    it("should parse bookmarks file", function()
      local bookmarks = qutebrowser.collect_bookmarks {
        os_name = "Darwin",
        os_homedir = "spec/fixtures",
      }

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
