local safari = require "telescope._extensions.bookmarks.safari"
local utils = require "telescope._extensions.bookmarks.utils"

local helpers = require "spec.helpers"

describe("safari", function()
  describe("collect_bookmarks", function()
    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
    end)

    it("should return nil if get_config_dir fails", function()
      -- Unsupported OS
      local bookmarks = safari.collect_bookmarks(
        { os_name = "Linux" },
        { selected_browser = "safari" }
      )

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
    end)

    it("should warn if bookmarks file not found", function()
      local bookmarks = safari.collect_bookmarks(
        { os_name = "Darwin" },
        { selected_browser = "safari", config_dir = "spec/fixtures" }
      )

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Expected bookmarks file for Safari at")
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
