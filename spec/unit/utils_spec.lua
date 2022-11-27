local Browser = require("browser_bookmarks.enum").Browser
local config = require "browser_bookmarks.config"
local utils = require "browser_bookmarks.utils"

local helpers = require "spec.helpers"

describe("path_exists", function()
  it("returns true if exists", function()
    assert.is_true(utils.path_exists "spec/fixtures")
  end)

  it("returns false if not exists", function()
    assert.is_false(utils.path_exists "foo/bar")
  end)
end)

describe("get_config_dir", function()
  before_each(function()
    stub(utils, "warn")
  end)

  after_each(function()
    utils.warn:revert()
    -- Reset the config table.
    config.setup()
  end)

  it("warns if given config_dir does not exists", function()
    config.setup { config_dir = "foo/bar" }
    local config_dir = utils.get_config_dir "brave"

    assert.is_nil(config_dir)
    assert.stub(utils.warn).was_called(1)
    assert
      .stub(utils.warn)
      .was_called_with(match.matches "No such directory for brave browser: foo/bar")
  end)

  it("returns the config_dir if exists", function()
    config.setup { config_dir = "spec/fixtures" }
    -- Passing any browser works as we've provided the config directory path.
    local config_dir = utils.get_config_dir(Browser.BRAVE)

    assert.is_not_nil(config_dir)
    assert.is_same(config_dir, "spec/fixtures")
  end)

  it("warns if OS not supported", function()
    helpers.set_state { os_name = "random" }
    local profile_dir = utils.get_config_dir(Browser.BRAVE)

    assert.is_nil(profile_dir)
    assert.stub(utils.warn).was_called(1)
    assert
      .stub(utils.warn)
      .was_called_with(match.matches "Unsupported OS for brave browser: random")
  end)

  it("returns the default config dir", function()
    helpers.set_state { os_name = "Linux", os_homedir = "spec/fixtures" }
    local config_dir = utils.get_config_dir(Browser.CHROMIUM)

    assert.is_not_nil(config_dir)
    assert.is_same(config_dir, "spec/fixtures/.config/chromium")
  end)
end)

describe("get_os_command_output", function()
  it("returns output on success", function()
    assert.are.same(utils.run_os_command "echo busted", "busted")
  end)

  it("errors on failure", function()
    assert.error_matches(function()
      utils.run_os_command "echo 'hi stderr' 1>&2 && exit 1"
    end, "^hi stderr$")
  end)
end)

describe("join_path", function()
  local sep = package.config:sub(1, 1)

  it("can handle nil", function()
    assert.are.equal(utils.join_path(), "")
  end)

  it("can handle one part", function()
    assert.are.equal(utils.join_path "foo", "foo")
  end)

  it("can handle multiple parts", function()
    local parts = { "path", "to", "foo" }
    assert.are.equal(utils.join_path(parts), table.concat(parts, sep))
  end)

  it("can handle multiple nested parts", function()
    assert.are.equal(
      utils.join_path { "path", "to", { "nested", "foo" } },
      table.concat({ "path", "to", "nested", "foo" }, sep)
    )
  end)
end)

describe("construct_prompt", function()
  it("should use the provided browser", function()
    assert.are.same(utils.construct_prompt "chrome", "Search Chrome Bookmarks")
  end)

  it("should use the config browser", function()
    assert.are.same(utils.construct_prompt(), "Search Brave Bookmarks")
  end)
end)

describe("debug", function()
  before_each(function()
    stub(vim.api, "nvim_out_write")
  end)

  after_each(function()
    vim.api.nvim_out_write:revert()
    config.setup()
  end)

  it("should not print if false", function()
    config.setup { debug = false }
    utils.debug "hello world"
    assert.stub(vim.api.nvim_out_write).was_called(0)
  end)

  it("should format the message correctly", function()
    config.setup { debug = true }
    utils.debug(nil, "string", { foo = "bar" })
    vim.schedule(function()
      assert.stub(vim.api.nvim_out_write).was_called(1)
      assert.stub(vim.api.nvim_out_write).was_called_with(
        match.matches '%[browser%-bookmarks%] %[[^%]]+%] %[DEBUG%]: nil string {\n  foo = "bar"\n}\n'
      )
    end)
  end)
end)
