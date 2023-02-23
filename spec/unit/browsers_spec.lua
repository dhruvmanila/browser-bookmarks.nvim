describe("browsers", function()
  insulate("", function()
    local browsers = require "browser_bookmarks.browsers"

    it("should error for unsupported browser", function()
      assert.error_matches(function()
        _ = browsers["random"]
      end, "Unsupported browser: random")
    end)
  end)

  insulate("", function()
    local browsers = require "browser_bookmarks.browsers"

    it("should return the browser interface", function()
      local browser = browsers["brave"]
      assert.is_not_nil(browser.collect_bookmarks)
    end)
  end)

  insulate("", function()
    local browsers = require "browser_bookmarks.browsers"

    it("should store module in self", function()
      assert.is_true(vim.tbl_isempty(browsers))
      _ = browsers["brave"]
      assert.is_false(vim.tbl_isempty(browsers))
      assert.is_not_nil(rawget(browsers, "brave"))
    end)
  end)
end)
