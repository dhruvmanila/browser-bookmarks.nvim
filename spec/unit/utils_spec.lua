local utils = require "telescope._extensions.bookmarks.utils"

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
  end)

  it("warns if given config_dir does not exists", function()
    local config_dir = utils.get_config_dir(
      {},
      { config_dir = "foo/bar", selected_browser = "brave" }
    )

    assert.is_nil(config_dir)
    assert.stub(utils.warn).was_called(1)
    assert
      .stub(utils.warn)
      .was_called_with(match.matches "No such directory for brave browser: foo/bar")
  end)

  it("returns the config_dir if exists", function()
    local config_dir = utils.get_config_dir(
      {},
      { config_dir = "spec/fixtures" }
    )

    assert.is_not_nil(config_dir)
    assert.is_same(config_dir, "spec/fixtures")
  end)

  it("warns if OS not supported", function()
    local profile_dir = utils.get_config_dir(
      { os_name = "random" },
      { selected_browser = "brave" }
    )

    assert.is_nil(profile_dir)
    assert.stub(utils.warn).was_called(1)
    assert
      .stub(utils.warn)
      .was_called_with(match.matches "Unsupported OS for brave browser: random")
  end)

  it("returns the default config dir", function()
    local config_dir = utils.get_config_dir(
      { os_name = "Linux", os_homedir = "spec/fixtures" },
      { selected_browser = "chromium" }
    )

    assert.is_not_nil(config_dir)
    assert.is_same(config_dir, "spec/fixtures/.config/chromium")
  end)
end)

describe("get_os_command_output", function()
  it("returns output on success", function()
    assert.are.same(
      utils.get_os_command_output { "echo", "busted" },
      { "busted" }
    )
  end)

  it("errors on failure", function()
    assert.error_matches(function()
      utils.get_os_command_output { "false" }
    end, "")
  end)
end)

describe("join_path", function()
  local sep = require("plenary.path").path.sep

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
