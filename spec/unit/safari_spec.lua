---@diagnostic disable: duplicate-set-field
local config = require "browser_bookmarks.config"
local safari = require "browser_bookmarks.browsers.safari"
local utils = require "browser_bookmarks.utils"

local helpers = require "spec.helpers"

describe("safari", function()
  describe("collect_bookmarks", function()
    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
      -- Reset the config
      config.setup()
    end)

    it("should return nil if get_config_dir fails", function()
      -- Unsupported OS
      helpers.set_state { os_name = "Linux" }
      local bookmarks = safari.collect_bookmarks { selected_browser = "safari" }

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
    end)

    it("should warn if bookmarks file not found", function()
      helpers.set_state { os_name = "Darwin" }
      config.setup { config_dir = "spec/fixtures" }
      local bookmarks = safari.collect_bookmarks { selected_browser = "safari" }

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Expected bookmarks file for Safari at")
    end)
  end)

  insulate("parse_bookmarks_data", function()
    -- Overriding the function to avoid running the `plutil` command.
    ---@param cmd string
    ---@return string
    utils.run_os_command = function(cmd)
      assert(vim.startswith(cmd, "plutil"), "invalid command: " .. cmd)
      local parts = vim.split(cmd, " ", { plain = true, trimempty = true })
      local filepath = parts[#parts]
      return helpers.readfile(filepath:gsub("plist$", "xml"))
    end

    utils.path_exists = function()
      return true
    end

    it("should parse bookmarks file", function()
      helpers.set_state { os_name = "Darwin", os_homedir = "spec/fixtures" }
      local bookmarks = safari.collect_bookmarks { selected_browser = "safari" }

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
