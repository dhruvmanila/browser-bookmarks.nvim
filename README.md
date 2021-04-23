# telescope-bookmarks.nvim
A Neovim Telescope extension to open your browser bookmarks right from the editor!

![telescope-bookmarks.nvim](https://user-images.githubusercontent.com/67177269/115818782-2367a780-a41b-11eb-9342-da1c06baa237.png)

The following browsers are currently supported:
* Brave
* Google Chrome

## Requirements

* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'dhruvmanila/telescope-bookmarks.nvim'
```

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'dhruvmanila/telescope-bookmarks.nvim'
```

## Telescope Config

Loading the extension:

```lua
require('telescope').load_extension('bookmarks')
```

Extension options:

```lua
require('telescope').setup {
  extensions = 
    bookmarks = {
      selected_browser = 'brave',  -- Available: 'brave', 'google_chrome'
      url_open_command = 'open',
    },
  }
}
```

## Available Commands

```vim
:Telescope bookmarks

" Using lua function
lua require('telescope').extensions.bookmarks.bookmarks(opts)
```

When you press `<CR>` on a selected bookmark, it will open the URL using the `url_open_command` option in your default browser.

## References

* [Chrome bookmarks in JSON format](https://junegunn.kr/2015/04/browsing-chrome-bookmarks-with-fzf/)
