local chrome = require "telescope._extensions.bookmarks.chrome"
local utils = require "telescope._extensions.bookmarks.utils"

describe("chrome", function()
  before_each(function()
    stub(utils, "warn")
  end)

  after_each(function()
    utils.warn:revert()
  end)

  describe("get_profile_dir", function()
    it("should warn if OS not supported", function()
      local profile_dir = chrome._get_profile_dir(
        { os_name = "random" },
        { selected_browser = "chrome" }
      )

      assert.is_nil(profile_dir)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Unsupported OS for chrome")
    end)

    it("should warn if state file not found", function()
      local profile_dir = chrome._get_profile_dir(
        { os_name = "Darwin", os_homedir = "random" },
        { selected_browser = "chrome", profile_name = "random" }
      )

      assert.is_nil(profile_dir)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "No state file found for chrome at")
    end)

    it("should warn if given profile does not exist", function()
      local profile_dir = chrome._get_profile_dir(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chrome", profile_name = "random" }
      )

      assert.is_nil(profile_dir)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Given chrome profile does not exist")
    end)

    it("should return the default profile if not provided", function()
      local profile_dir = chrome._get_profile_dir(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chrome" }
      )

      assert.is_not_nil(profile_dir)
      assert.is_true(vim.endswith(profile_dir, "Default"))
    end)

    it("should return the given profile", function()
      local profile_dir = chrome._get_profile_dir(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chrome", profile_name = "Astronaut" }
      )

      assert.is_not_nil(profile_dir)
      assert.is_true(vim.endswith(profile_dir, "Profile1"))
    end)
  end)

  describe("collect_bookmarks", function()
    local match = require "luassert.match"

    it("should return nil if unable to get profile directory", function()
      local bookmarks = chrome.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chrome", profile_name = "random" }
      )

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Given chrome profile does not exist")
    end)

    it("should warn if file is absent", function()
      local bookmarks = chrome.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "." },
        { selected_browser = "chrome" }
      )

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "No chrome bookmarks file found at")
    end)
  end)

  describe("parse_bookmarks_data", function()
    it("should parse bookmarks file", function()
      local bookmarks = chrome.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "chrome" }
      )

      assert.are.same(bookmarks, {
        {
          name = "Google",
          path = "search/Google",
          url = "https://google.com/",
        },
        {
          name = "DuckDuckGo",
          path = "search/nested/DuckDuckGo",
          url = "https://duckduckgo.com/",
        },
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
      })
    end)
  end)
end)
