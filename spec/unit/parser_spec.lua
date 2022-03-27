local ini = require "telescope._extensions.bookmarks.parser.ini"

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
