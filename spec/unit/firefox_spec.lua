local utils = require "telescope._extensions.bookmarks.utils"

local test_profiles = {
  -- There was some parse error, so an empty table was returned.
  parse_failure = {},

  -- Default test profile config.
  default_profile = {
    Profile0 = {
      Name = "default-release",
      IsRelative = 1,
      Path = "Profiles/default-release",
      Default = 1,
    },
    Profile1 = {
      Name = "dev-edition-default",
      -- This profile contains absolute path to the profile directory.
      IsRelative = 0,
      Path = "Profiles/dev-edition-default",
    },
  },

  -- There's only one profile available so use that.
  one_profile = {
    Profile0 = {
      Name = "one-profile",
      IsRelative = 1,
      Path = "Profiles/one-profile",
    },
  },

  -- Multiple profiles with no default one.
  no_default_profile = {
    Profile0 = {
      Name = "profile0",
      IsRelative = 1,
      Path = "Profiles/profile0",
    },
    Profile1 = {
      Name = "profile1",
      IsRelative = 1,
      Path = "Profiles/profile1",
    },
  },
}

describe("firefox", function()
  before_each(function()
    stub(utils, "warn")
  end)

  after_each(function()
    utils.warn:revert()
  end)

  -- Insulate this block to avoid `ini.load` being overridden in other blocks.
  insulate("helpers", function()
    local match = require "luassert.match"
    local ini = require "telescope._extensions.bookmarks.parser.ini"
    local firefox = require "telescope._extensions.bookmarks.firefox"

    -- Override the original function to load the data directly from the
    -- "profiles" table defined above. The first part of the path is used as
    -- the key which is the `os_homedir` in the state table.
    ini.load = function(path)
      local key = vim.split(path, "/")[1]
      return test_profiles[key]
    end

    describe("collect_profiles", function()
      it("should return nil if failed to parse profiles.ini", function()
        local profiles = firefox._collect_profiles "parse_failure"
        assert.is_nil(profiles)
      end)

      it("should return a mapping of profile name to info", function()
        local profiles = firefox._collect_profiles "default_profile"
        assert.is_not_nil(profiles)
        assert.are.same(profiles, {
          ["default-release"] = {
            Name = "default-release",
            IsRelative = 1,
            Path = "Profiles/default-release",
            Default = 1,
          },
          ["dev-edition-default"] = {
            Name = "dev-edition-default",
            IsRelative = 0,
            Path = "Profiles/dev-edition-default",
          },
        })
      end)
    end)

    describe("get_profile_dir", function()
      it("should warn if OS not supported", function()
        local profile_dir = firefox._get_profile_dir(
          { os_name = "random" },
          { selected_browser = "firefox" }
        )

        assert.is_nil(profile_dir)
        assert.stub(utils.warn).was_called()
        assert
          .stub(utils.warn)
          .was_called_with(match.matches "Unsupported OS for firefox browser")
      end)

      it("should warn if failed to parse profiles.ini", function()
        local profile_dir = firefox._get_profile_dir({
          os_name = "Darwin",
          os_homedir = "parse_failure",
        }, { selected_browser = "firefox" })

        assert.is_nil(profile_dir)
        assert.stub(utils.warn).was_called()
        assert
          .stub(utils.warn)
          .was_called_with(match.matches "Unable to parse firefox profiles config file")
      end)

      it("should pick the only profile available", function()
        local profile_dir = firefox._get_profile_dir({
          os_name = "Darwin",
          os_homedir = "one_profile",
        }, { selected_browser = "firefox" })

        assert.is_not_nil(profile_dir)
        assert.is_true(vim.endswith(profile_dir, "Profiles/one-profile"))
      end)

      it("should return default profile directory", function()
        local profile_dir = firefox._get_profile_dir({
          os_name = "Darwin",
          os_homedir = "default_profile",
        }, { selected_browser = "firefox" })

        assert.is_not_nil(profile_dir)
        assert.is_true(vim.endswith(profile_dir, "Profiles/default-release"))
      end)

      it("should return user given profile directory", function()
        local profile_dir = firefox._get_profile_dir(
          { os_name = "Darwin", os_homedir = "default_profile" },
          {
            selected_browser = "firefox",
            firefox_profile_name = "dev-edition-default",
          }
        )

        assert.is_not_nil(profile_dir)
        -- Also testing if the `IsRelative` key is being considered or not.
        assert.are_equal(profile_dir, "Profiles/dev-edition-default")
      end)

      it("should warn if user given profile does not exist", function()
        local profile_dir = firefox._get_profile_dir(
          { os_name = "Darwin", os_homedir = "default_profile" },
          { selected_browser = "firefox", firefox_profile_name = "random" }
        )

        assert.is_nil(profile_dir)
        assert.stub(utils.warn).was_called()
        assert
          .stub(utils.warn)
          .was_called_with(match.matches "Given firefox profile does not exist")
      end)

      it("should warn if unable to deduce default profile", function()
        local profile_dir = firefox._get_profile_dir({
          os_name = "Darwin",
          os_homedir = "no_default_profile",
        }, { selected_browser = "firefox" })

        assert.is_nil(profile_dir)
        assert.stub(utils.warn).was_called()
        assert
          .stub(utils.warn)
          .was_called_with(match.matches "Unable to deduce the default firefox profile name")
      end)
    end)
  end)

  describe("collect_bookmarks", function()
    local match = require "luassert.match"
    local firefox = require "telescope._extensions.bookmarks.firefox"

    it("should return nil if unable to get profile directory", function()
      local bookmarks = firefox.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        { selected_browser = "firefox", firefox_profile_name = "random" }
      )

      assert.is_nil(bookmarks)
      assert.stub(utils.warn).was_called()
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Given firefox profile does not exist")
    end)

    it("should parse bookmarks data", function()
      local bookmarks = firefox.collect_bookmarks({
        os_name = "Darwin",
        os_homedir = "spec/fixtures",
      }, { selected_browser = "firefox" })

      assert.are.same(bookmarks, {
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
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
      })
    end)

    it("should parse bookmarks data for given firefox profile", function()
      local bookmarks = firefox.collect_bookmarks(
        { os_name = "Darwin", os_homedir = "spec/fixtures" },
        {
          selected_browser = "firefox",
          firefox_profile_name = "dev-edition-default",
        }
      )

      assert.are.same(bookmarks, {
        {
          name = "GitHub",
          path = "GitHub",
          url = "https://github.com/",
        },
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
      })
    end)
  end)
end)
