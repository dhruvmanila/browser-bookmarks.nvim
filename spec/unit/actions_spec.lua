local custom_actions = require "telescope._extensions.bookmarks.actions"

describe("actions", function()
  insulate("smart_url_opener", function()
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    actions.close = function() end

    function action_state.get_selected_entry()
      return { value = "https://github.com" }
    end

    it("should error for unsupported plugin", function()
      assert.error_matches(function()
        custom_actions.smart_url_opener { url_open_plugin = "random" }()
      end, "Unsupported plugin opener")
    end)

    it("should call the correct plugin function for open_browser", function()
      stub(vim.fn, "openbrowser#open")
      custom_actions.smart_url_opener { url_open_plugin = "open_browser" }()
      assert.stub(vim.fn["openbrowser#open"]).was_called()
      assert.stub(vim.fn["openbrowser#open"]).was_called_with "https://github.com"
    end)

    it("should call the correct plugin function for vim_external", function()
      stub(vim.fn, "external#browser")
      custom_actions.smart_url_opener { url_open_plugin = "vim_external" }()
      assert.stub(vim.fn["external#browser"]).was_called()
      assert.stub(vim.fn["external#browser"]).was_called_with "https://github.com"
    end)

    it("should execute the open command", function()
      stub(os, "execute")
      custom_actions.smart_url_opener { url_open_command = "open" }()
      assert.stub(os.execute).was_called()
      assert.stub(os.execute).was_called_with 'open "https://github.com"'
    end)
  end)
end)
