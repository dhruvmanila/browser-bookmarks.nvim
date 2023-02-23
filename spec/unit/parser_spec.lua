local ini = require "browser_bookmarks.parser.ini"
local plist = require "browser_bookmarks.parser.plist"

local helpers = require "spec.helpers"

describe("ini parser", function()
  it("should ignore comments", function()
    assert.are.same(ini.load "spec/fixtures/ini/comments.ini", {})
  end)

  it("should parse numbers", function()
    assert.are.same(ini.load "spec/fixtures/ini/numbers.ini", {
      section = {
        one = 1,
        two = 2,
      },
    })
  end)

  it("should parse booleans", function()
    assert.are.same(ini.load "spec/fixtures/ini/booleans.ini", {
      section = {
        good = true,
        bad = false,
      },
    })
  end)

  it("should parse multiple sections and empty values", function()
    assert.are.same(ini.load "spec/fixtures/ini/all.ini", {
      section1 = {
        one = 1,
        nothing = "",
      },
      section2 = {
        right = true,
      },
      section3 = {
        nope = "",
      },
    })
  end)
end)

describe("plist parser", function()
  it("should parse empty", function()
    assert.are.same(
      plist.parse(helpers.readfile "spec/fixtures/plist/empty.xml"),
      {}
    )
  end)

  it("should parse array elements", function()
    assert.are.same(
      plist.parse(helpers.readfile "spec/fixtures/plist/array.xml"),
      { "foo", 1, 1.5, true }
    )
  end)

  it("should parse dictionary elements", function()
    assert.are.same(
      plist.parse(helpers.readfile "spec/fixtures/plist/dictionary.xml"),
      {
        string = "foo",
        integer = 1,
        boolean = false,
        array = {},
      }
    )
  end)

  it("should parse nested array/dictionary elements", function()
    assert.are.same(
      plist.parse(helpers.readfile "spec/fixtures/plist/nested.xml"),
      {
        dictionary = {
          { nested = true },
        },
      }
    )
  end)
end)
