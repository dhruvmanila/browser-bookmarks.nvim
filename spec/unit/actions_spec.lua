local custom_actions = require "browser_bookmarks.actions"
local utils = require "browser_bookmarks.utils"

describe("actions", function()
  insulate("smart_url_opener", function()
    local config = require "browser_bookmarks.config"

    after_each(function()
      -- Reset the config table.
      config.setup()
    end)

    it("should warn for unsupported plugin", function()
      stub(utils, "warn")
      ---@diagnostic disable-next-line: assign-type-mismatch
      config.setup { url_open_plugin = "random" }
      custom_actions.open_urls { "https://example.com" }

      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Unsupported plugin opener")

      utils.warn:revert()
    end)

    it("should warn when command execution fails", function()
      stub(utils, "warn")
      -- Return non-zero value to simulate the command failure.
      stub(os, "execute", 1)
      config.setup { url_open_command = "open" }
      custom_actions.open_urls { "https://example.com" }

      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Failed to open the url")

      utils.warn:revert()
      os.execute:revert()
    end)

    it("should call the correct plugin function for open_browser", function()
      stub(vim.fn, "openbrowser#open")
      config.setup { url_open_plugin = "open_browser" }
      custom_actions.open_urls { "https://example.com" }

      assert.stub(vim.fn["openbrowser#open"]).was_called(1)
      assert
        .stub(vim.fn["openbrowser#open"])
        .was_called_with "https://example.com"

      vim.fn["openbrowser#open"]:revert()
    end)

    it("should call the correct plugin function for vim_external", function()
      stub(vim.fn, "external#browser")
      config.setup { url_open_plugin = "vim_external" }
      custom_actions.open_urls { "https://example.com" }

      assert.stub(vim.fn["external#browser"]).was_called(1)
      assert
        .stub(vim.fn["external#browser"])
        .was_called_with "https://example.com"

      vim.fn["external#browser"]:revert()
    end)

    it("should execute the open command", function()
      stub(os, "execute", 0)
      custom_actions.open_urls { "https://example.com" }

      assert.stub(os.execute).was_called(1)
      assert.stub(os.execute).was_called_with 'open "https://example.com"'

      os.execute:revert()
    end)

    it("should call plugin function with multiple urls", function()
      stub(vim.fn, "external#browser")
      config.setup { url_open_plugin = "vim_external" }
      custom_actions.open_urls { "https://example.com", "https://foobar.com" }

      assert.stub(vim.fn["external#browser"]).was_called(2)
      assert
        .stub(vim.fn["external#browser"])
        .was_called_with "https://example.com"
      assert
        .stub(vim.fn["external#browser"])
        .was_called_with "https://foobar.com"

      vim.fn["external#browser"]:revert()
    end)

    it("should execute the open command with multiple urls", function()
      stub(os, "execute", 0)
      custom_actions.open_urls { "https://example.com", "https://foobar.com" }

      assert.stub(os.execute).was_called(1)
      assert
        .stub(os.execute)
        .was_called_with 'open "https://example.com" "https://foobar.com"'

      os.execute:revert()
    end)
  end)
end)
