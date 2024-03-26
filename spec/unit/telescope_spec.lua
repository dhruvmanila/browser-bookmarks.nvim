local utils = require "browser_bookmarks.utils"

describe("telescope bookmarks", function()
  insulate("config", function()
    local bookmarks = require "telescope._extensions.bookmarks"
    local config = require "browser_bookmarks.config"

    before_each(function()
      stub(utils, "warn")
    end)

    after_each(function()
      utils.warn:revert()
      -- Reset the config
      config.setup()
    end)

    it("should warn if configuring via telescope extension", function()
      local test_config = {
        selected_browser = "random",
      }
      local default_browser = config._defaults.selected_browser
      bookmarks.setup(test_config)
      assert.stub(utils.warn).was_called(1)
      assert.are.same(config.values.selected_browser, default_browser)
    end)
  end)
end)
