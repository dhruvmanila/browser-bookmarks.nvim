<div align="center">

# telescope-bookmarks.nvim

[![test](https://github.com/dhruvmanila/telescope-bookmarks.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/dhruvmanila/telescope-bookmarks.nvim/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/dhruvmanila/telescope-bookmarks.nvim/branch/main/graph/badge.svg)](https://codecov.io/gh/dhruvmanila/telescope-bookmarks.nvim)
[![GitHub release](https://img.shields.io/github/v/release/dhruvmanila/telescope-bookmarks.nvim)](https://github.com/dhruvmanila/telescope-bookmarks.nvim/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-brightgreen)](/LICENSE)

A _Neovim Telescope extension_ to open your browser bookmarks right from the editor!

![telescope-bookmarks.nvim](https://user-images.githubusercontent.com/67177269/115862442-c89d7280-a451-11eb-94c5-501095f88ed7.png)

</div>

<details>
<summary><em>Screenshot configuration</em></summary>

```lua
require('telescope').extensions.bookmarks.bookmarks(
  require('telescope.themes').get_dropdown {
    layout_config = {
      width = 0.8,
      height = 0.8,
    },
    previewer = false,
  }
)
```

</details>


### Supported browsers

| Browser            | MacOS   | Linux   | Windows   |
| ------------------ | :-----: | :-----: | :-------: |
| Brave              | ☑️       | ☑️       | ☑️         |
| Brave Beta         | ☑️       | ☑️       | ☑️         |
| Google Chrome      | ☑️       | ☑️       | ☑️         |
| Google Chrome Beta | ☑️       | ☑️       | ☑️         |
| Microsoft Edge     | ☑️       | ☑️       | ☑️         |
| Firefox            | ☑️       | ☑️       | ☑️         |
| qutebrowser        | ☑️       | ☑️       | ☑️         |
| Safari [^1]        | ☑️       | -       | -         |
| Vivaldi            | ☑️       | ☑️       | ☑️         |
| Waterfox           | ☑️       | ☑️       | ☑️         |

[^1]: The application which is used to run neovim should be allowed full disk access
as the bookmarks file (`~/Library/Safari/Bookmarks.plist`) is in a restricted
directory. This can be done in ***System Preferences > Security & Privacy > Full
Disk Access*** and then click on the checkbox next to your preferred
application.

### Supported tools

- [buku](https://github.com/jarun/buku) - bookmark manager

## Requirements

[![Requires Neovim](https://img.shields.io/badge/requires-neovim%200.7%2B-green?logo=neovim)](https://github.com/neovim/neovim)

* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* [sqlite.lua](https://github.com/kkharji/sqlite.lua) (only for Firefox,
  Waterfox browser and buku)

Neovim version requirement is the same as that of
[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim#getting-started).

## Installation

The project follows semantic versioning, so it's recommended to specify the
tag when installing. The latest released version can be found
[here](https://github.com/dhruvmanila/telescope-bookmarks.nvim/releases/latest).

The plugin managers mentioned below supports wildcard (`*`) in the tag key which
points to the latest git tag. You can specify a specific version if you'd prefer
to inspect the changes before updating.

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'dhruvmanila/telescope-bookmarks.nvim',
  tag = '*',
  -- Uncomment if the selected browser is Firefox, Waterfox or buku
  -- requires = {
  --   'kkharji/sqlite.lua',
  -- }
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'dhruvmanila/telescope-bookmarks.nvim', { 'tag': '*' }
" Uncomment if the selected browser is Firefox, Waterfox or buku
" Plug 'kkharji/sqlite.lua'
```

## Usage

To get started, simply load the extension:

```lua
require('telescope').load_extension('bookmarks')
```

You can open the picker either from the command-line or calling the lua
function:

```vim
" From the command-line
Telescope bookmarks

" Using lua function
lua require('telescope').extensions.bookmarks.bookmarks(opts)
```

Telescope can lazily load the extension when needed, but that can only be
called using the lua function. The command-line argument will not work as the
extension is not yet loaded.

When you press <kbd>Enter</kbd> on a selected bookmark, it will open the URL
using either the `url_open_plugin` or `url_open_command` option in your default
browser. Multiple bookmarks can be opened at the same time using multi
selections feature in Telescope.

## Configuration

Extension options:

> **Note**
>
> These are the default values for all the available options. You don't need to
> set them in your config. Just pick the ones whose value you would want to
> change and add it to your config.

```lua
require('telescope').setup {
  extensions = {
    bookmarks = {
      -- Available:
      --  * 'brave'
      --  * 'brave_beta'
      --  * 'buku'
      --  * 'chrome'
      --  * 'chrome_beta'
      --  * 'edge'
      --  * 'firefox'
      --  * 'qutebrowser'
      --  * 'safari'
      --  * 'vivaldi'
      --  * 'waterfox'
      selected_browser = 'brave',

      -- Either provide a shell command to open the URL
      url_open_command = 'open',

      -- Or provide the plugin name which is already installed
      -- Available: 'vim_external', 'open_browser'
      url_open_plugin = nil,

      -- Show the full path to the bookmark instead of just the bookmark name
      full_path = true,

      -- Provide a custom profile name for the selected browser
      -- Supported browsers:
      --  * 'brave'
      --  * 'brave_beta'
      --  * 'chrome'
      --  * 'chrome_beta'
      --  * 'edge'
      --  * 'firefox'
      --  * 'vivaldi'
      --  * 'waterfox'
      profile_name = nil,

      -- Add a column which contains the tags for each bookmark for buku
      buku_include_tags = false,

      -- Provide debug messages
      debug = false,
    },
  }
}
```

For browsers which supports specifying profiles, the default profile will be
used if `profile_name` is not provided.

If the user has provided `url_open_plugin` then it will be used, otherwise
default to using `url_open_command`. Supported plugins for `url_open_plugin` and
the respective plugin function used to open the URL:

* [open-browser.vim](https://github.com/tyru/open-browser.vim) - `openbrowser#open`
* [vim-external](https://github.com/itchyny/vim-external) - `external#browser`

## References

* [Browsing Chrome bookmarks with fzf](https://junegunn.kr/2015/04/browsing-chrome-bookmarks-with-fzf/)
* [Code: plist parser](https://codea.io/talk/discussion/1269/code-plist-parser)
