local utils = require "telescope._extensions.bookmarks.utils"

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
