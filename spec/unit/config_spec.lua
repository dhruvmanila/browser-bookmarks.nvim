local config = require "browser_bookmarks.config"

insulate("config", function()
  it("should initialize with defaults", function()
    assert.are.same(config.values, config._defaults)
  end)

  it("should prefer user config over defaults", function()
    local test_config = {
      selected_browser = "firefox",
      profile_name = "default",
      config_dir = "/home/user",
      full_path = false,
      url_open_command = "xdg-open",
      url_open_plugin = "vim_external",
      buku_include_tags = true,
      debug = true,
    }
    assert.are.same(config.values, config._defaults)
    config.setup(test_config)
    assert.are.same(config.values, test_config)
  end)
end)
