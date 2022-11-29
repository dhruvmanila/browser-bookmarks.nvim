local custom_actions = require "telescope._extensions.bookmarks.actions"
local utils = require "telescope._extensions.bookmarks.utils"

describe("actions", function()
  insulate("smart_url_opener", function()
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local action_utils = require "telescope.actions.utils"

    actions.close = function() end

    function action_state.get_selected_entry()
      return { value = "https://github.com" }
    end

    function action_utils.map_selections(prompt_bufnr, f)
      -- `nil` can act as a flag to simulate that there were no multi selections.
      -- Anything other than `nil` will mean that there are multi selections.
      if prompt_bufnr == nil then
        return
      end
      for _, selection in ipairs {
        { value = "https://github.com" },
        { value = "https://google.com" },
      } do
        f(selection)
      end
    end

    it("should warn for unsupported plugin", function()
      stub(utils, "warn")
      custom_actions.smart_url_opener { url_open_plugin = "random" }()
      assert.stub(utils.warn).was_called()
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Unsupported plugin opener")
      utils.warn:revert()
    end)

    it("should warn when command execution fails", function()
      stub(utils, "warn")
      -- Return non-zero value to simulate the command failure.
      stub(os, "execute", 1)
      custom_actions.smart_url_opener { url_open_command = "open" }()
      assert.stub(utils.warn).was_called(1)
      assert
        .stub(utils.warn)
        .was_called_with(match.matches "Failed to open the url")
      utils.warn:revert()
      os.execute:revert()
    end)

    it("should call the correct plugin function for open_browser", function()
      stub(vim.fn, "openbrowser#open")
      custom_actions.smart_url_opener { url_open_plugin = "open_browser" }()
      assert.stub(vim.fn["openbrowser#open"]).was_called()
      assert
        .stub(vim.fn["openbrowser#open"])
        .was_called_with "https://github.com"
      vim.fn["openbrowser#open"]:revert()
    end)

    it("should call the correct plugin function for vim_external", function()
      stub(vim.fn, "external#browser")
      custom_actions.smart_url_opener { url_open_plugin = "vim_external" }()
      assert.stub(vim.fn["external#browser"]).was_called()
      assert
        .stub(vim.fn["external#browser"])
        .was_called_with "https://github.com"
      vim.fn["external#browser"]:revert()
    end)

    it("should execute the open command", function()
      stub(os, "execute", 0)
      custom_actions.smart_url_opener { url_open_command = "open" }()
      assert.stub(os.execute).was_called()
      assert.stub(os.execute).was_called_with 'open "https://github.com"'
      os.execute:revert()
    end)

    it("should call plugin function with multiple urls", function()
      stub(vim.fn, "external#browser")
      custom_actions.smart_url_opener { url_open_plugin = "vim_external" }(0)
      assert.stub(vim.fn["external#browser"]).was_called(2)
      assert
        .stub(vim.fn["external#browser"])
        .was_called_with "https://github.com"
      assert
        .stub(vim.fn["external#browser"])
        .was_called_with "https://google.com"
      vim.fn["external#browser"]:revert()
    end)

    it("should execute the open command with multiple urls", function()
      stub(os, "execute", 0)
      custom_actions.smart_url_opener { url_open_command = "open" }(0)
      assert.stub(os.execute).was_called(1)
      assert
        .stub(os.execute)
        .was_called_with 'open "https://github.com" "https://google.com"'
      os.execute:revert()
    end)
  end)
end)
