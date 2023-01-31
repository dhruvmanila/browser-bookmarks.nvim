local safari = require "telescope._extensions.bookmarks.safari"
local utils = require "telescope._extensions.bookmarks.utils"

local helpers = require "spec.helpers"

describe("safari", function()
  describe("collect_bookmarks", function()
    local match = require "luassert.match"

    it("should warn if OS not supported", function()
      stub(utils, "warn")

      local bookmarks = safari.collect_bookmarks(
        { os_name = "Linux" },
        { selected_browser = "safari" }
      )

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Unsupported OS for safari")
    end)
  end)

  insulate("parse_bookmarks_data", function()
    -- Overriding the function to avoid running the `plutil` command.
    utils.get_os_command_output = function(command)
      assert(
        command[1] == "plutil",
        ("invalid command: %s"):format(vim.inspect(command))
      )
      local filepath = command[#command]
      return { helpers.readfile(filepath:gsub("plist$", "xml")) }
    end

    utils.path_exists = function(path)
      return true
    end

    it("should parse bookmarks file", function()
      local bookmarks = safari.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "safari" }
      )

      assert.are.same(bookmarks, {
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
        {
          name = "DuckDuckGo",
          path = "search/nested/DuckDuckGo",
          url = "https://duckduckgo.com/",
        },
        {
          name = "Google",
          path = "search/Google",
          url = "https://www.google.com",
        },
      })
    end)
  end)
end)
