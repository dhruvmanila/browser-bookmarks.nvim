<div align="center">

# browser-bookmarks.nvim

[![test](https://github.com/dhruvmanila/browser-bookmarks.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/dhruvmanila/browser-bookmarks.nvim/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/dhruvmanila/browser-bookmarks.nvim/branch/main/graph/badge.svg)](https://codecov.io/gh/dhruvmanila/browser-bookmarks.nvim)
[![GitHub release](https://img.shields.io/github/v/release/dhruvmanila/browser-bookmarks.nvim)](https://github.com/dhruvmanila/browser-bookmarks.nvim/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-brightgreen)](/LICENSE)

A _Neovim plugin_ to open your browser bookmarks right from the editor!

### Using `vim.ui.select` and [`telescope-ui-select.nvim`](https://github.com/nvim-telescope/telescope-ui-select.nvim):

![vim-ui-select](https://user-images.githubusercontent.com/67177269/224382480-a107ca94-ca75-4da1-ae2a-e12d0a4118df.png)

### Using `vim.ui.select` and [`fzf-lua`](https://github.com/ibhagwan/fzf-lua):

![fzf-lua](https://user-images.githubusercontent.com/67177269/224391505-15f4094f-2f71-4c55-98cb-5cedcbdb2c23.png)

### Using telescope integration:

![telescope-integration](https://user-images.githubusercontent.com/67177269/224382374-2afc6307-d311-4cac-8d08-f37769bc6e6e.png)

</div>

### Supported browsers

| Browser            | MacOS   | Linux   | Windows   |
| ------------------ | :-----: | :-----: | :-------: |
| Arc                | ☑️       | -       | -         |
| Brave              | ☑️       | ☑️       | ☑️         |
| Brave Beta         | ☑️       | ☑️       | ☑️         |
| Chromium           | ☑️       | ☑️       | ☑️         |
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
- [Raindrop.io](https://raindrop.io) [^2] - All-in-one bookmark manager

_Refer to the [Raindrop](#raindrop) section for more info._

[^2]: The Raindrop API requires an access token to fetch the bookmarks. To get
    the token, go to [App Management
    Console](https://app.raindrop.io/settings/integrations) and open your
    application settings. Copy the **Test token** and add it when asked for.

## Requirements

* [Neovim](https://github.com/neovim/neovim) >= 0.7
* [sqlite.lua](https://github.com/kkharji/sqlite.lua) (only for Firefox,
  Waterfox browser and buku)
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (only for
  telescope integration)

## Installation

The project follows semantic versioning, so it's recommended to specify the
tag when installing. The latest released version can be found
[here](https://github.com/dhruvmanila/browser-bookmarks.nvim/releases/latest).

The plugin managers mentioned below supports wildcard (`*`) in the tag key which
points to the latest git tag. You can specify a specific version if you'd prefer
to inspect the changes before updating.

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'dhruvmanila/browser-bookmarks.nvim',
  version = '*',
  -- Only required to override the default options
  opts = {
    -- Override default configuration values
    -- selected_browser = 'chrome'
  },
  -- dependencies = {
  --   -- Only if your selected browser is Firefox, Waterfox or buku
  --   'kkharji/sqlite.lua',
  --
  --   -- Only if you're using the Telescope extension
  --   'nvim-telescope/telescope.nvim',
  -- }
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'dhruvmanila/browser-bookmarks.nvim',
  tag = '*',
  -- requires = {
  --   -- Only if your selected browser is Firefox, Waterfox or buku
  --   'kkharji/sqlite.lua',
  --
  --   -- Only if you're using the Telescope extension
  --   'nvim-telescope/telescope.nvim',
  -- }
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'dhruvmanila/browser-bookmarks.nvim', { 'tag': '*' }
" Only if your selected browser is Firefox, Waterfox or buku
" Plug 'kkharji/sqlite.lua'

" Only if you're using the Telescope extension
" Plug 'nvim-telescope/telescope.nvim'
```

## Setup

> **Note**: Setup function is only required to be invoked to override the
> [default configuration values](#configuration). Otherwise, the setup is done
> automatically to use the default configuration values and define the
> `BrowserBookmarks` command.

```lua
require('browser_bookmarks').setup({
  -- override default configuration values
  selected_browser = 'firefox',
})
```

## Usage

The command `BrowserBookmarks` is defined through which the plugin can be
invoked. This uses the `vim.ui.select` interface to select a bookmark and open
it in the default browser.

The command accepts an optional argument which would be the browser name. If not
provided, the plugin will use the default browser or the configured one during
the plugin setup.

```lua
-- No argument, uses the default browser
BrowserBookmarks

-- Uses the Safari browser
BrowserBookmarks safari

-- Autocomplete is available
BrowserBookmarks <TAB>
```

The browser name is the same as the one accepted by the `selected_browser`
config option. Refer to the [config section](#selected_browser).

When you press <kbd>Enter</kbd> on a selected bookmark, it will open the URL
using either the `url_open_plugin` or `url_open_command` option in your default
browser.

The keymap can be defined to invoke the fuzzy finder through the command or
API function like so:

```lua
vim.keymap.set('n', '<leader>fb', require('browser_bookmarks').select, {
  desc = 'Fuzzy search browser bookmarks',
})
```

### Raindrop

For users of [Raindrop.io](https://raindrop.io), as the bookmarks are stored in
the cloud and an [API](https://developer.raindrop.io/v1/raindrops/multiple) is
used to fetch the bookmarks, two workflows were designed to accomodate the
process.

#### Token initialization

The API requires a token for authentication. Now, a token cannot be stored in
the user config as that would risk in making it public through an individual's
dotfiles. So, the plugin will ask for the token when invoked for the first time
and store it locally in a file at the following path:

```lua
vim.fn.stdpath('data') .. '/.raindrop-token'
```

The token value can be updated using the following API:

```lua
require('browser_bookmarks.browsers.raindrop').update_token("new-token")
```

Once the token is initialized, the same will be used for every command
invocation.

#### Background job

Invoking the command post token initialization will trigger a background job
to collect the bookmarks and cache it. Further invocation of the command will
use the cached bookmarks. The cache can be cleared using the following API:

```lua
require('browser_bookmarks.browsers.raindrop').clear_cache()
```

### API

Additionally, the plugin exposes a simple API:

```lua
---@class Bookmark
---@field name string Bookmark name
---@field path string Full path from root to the name separated by '/'
---@field url string Bookmark URL
---@field tags? string Comma separated tags (only for buku)

-- Collect all the bookmarks for either the given browser or the selected
-- browser in the config table.
--
-- An error will be raised if the selected browser is unsupported.
-- A warning notification will be sent using `vim.notify` if there's any
-- kind of problem while collecting the bookmarks.
--
---@param selected_browser? Browser
---@return Bookmark[]?
function M.collect(selected_browser) end

-- Select a bookmark using `vim.ui.select` and open it in the default browser.
--
-- If the `selected_browser` parameter is not given, the value is taken from
-- the config table. The `kind` option value in `vim.ui.select` is
-- "browser-bookmarks".
--
-- Error / warning is given in the same way as the `collect` function.
--
---@param selected_browser? Browser
function M.select(selected_browser) end
```

The command `BrowserBookmarks` uses the `select` API function.

<details>
<summary><b>Example usage for the API:</b></summary>

```lua
local Browser = require("browser_bookmarks.enum").Browser
local browser_bookmarks = require("browser_bookmarks")

browser_bookmarks.collect(Browser.BRAVE)
-- {
--   {
--     name = "GitHub",
--     path = "GitHub",
--     url = "https://github.com/"
--   },
--   {
--     name = "Google",
--     path = "search/Google",
--     url = "https://www.google.com/"
--   },
--   {
--     name = "DuckDuckGo",
--     path = "search/nested/DuckDuckGo",
--     url = "https://duckduckgo.com/"
--   }
-- }
```

</details>

## Telescope Extension

To get started, simply load the extension:

```lua
require('telescope').load_extension('bookmarks')
```

To override the default values, use the [setup](#setup) guide.

You can open the picker either from the command-line or calling the lua
function:

```vim
" From the command-line
Telescope bookmarks

" Using lua function
lua require('telescope').extensions.bookmarks.bookmarks(telescope_opts)
```

Telescope can lazily load the extension when needed, but that can only be
called using the lua function. The command-line argument will not work as the
extension is not yet loaded.

Multiple bookmarks can be opened at the same time using multi selections feature
in Telescope.

## Configuration

### `selected_browser`
> **string, default: "brave"**

The selected browser to collect the bookmarks from. An error is raised if the
provided browser name is unsupported. The list of supported browser along with
the config value is as follows:

| Browser / Tool     | Config value |
| ------------------ | :----------: |
| Arc                | `arc`        |
| buku               | `buku`       |
| Brave              | `brave`      |
| Brave Beta         | `brave_beta` |
| Google Chrome      | `chrome`     |
| Google Chrome Beta | `chrome_beta`|
| Chromium           | `chromium`   |
| Microsoft Edge     | `edge`       |
| Firefox            | `firefox`    |
| qutebrowser        | `qutebrowser`|
| Raindrop.io        | `raindrop`   |
| Safari             | `safari`     |
| Vivaldi            | `vivaldi`    |
| Waterfox           | `waterfox`   |

### `profile_name`
> **string, default: nil**

This option is only applicable for the browsers which allow switching between
profiles and the plugin supports it. The default profile will be used if the
value is `nil` otherwise the plugin will try to collect the bookmarks for the
given profile.

If the given profile does not exist or the plugin is unable to get the profile
related information, an appropriate warning message will be provided.

Following browsers are supported for the config option:
* Arc
* Brave
* Brave Beta
* Google Chrome
* Google Chrome Beta
* Chromium
* Microsoft Edge
* Firefox
* Vivaldi
* Waterfox

The config option is ignored for all the non-supported browsers.

### `config_dir`
> **string, default: nil**

This is the absolute path to the config directory where the selected browser's
data is stored on the respective operating system. If `nil`, the default path
will be used as specified in the table below. It can be used as a reference in
determining the custom path.

| Browser            | MacOS                                                            | Linux                                        | Windows                                                      |
| ------------------ | ---------------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| Arc                | `~/Library/Application Support/Arc/User Data`                    | -                                            | -                                                            |
| Brave              | `~/Library/Application Support/BraveSoftware/Brave-Browser`      | `~/.config/BraveSoftware/Brave-Browser`      | `~/AppData/Local/BraveSoftware/Brave-Browser/User Data`      |
| Brave Beta         | `~/Library/Application Support/BraveSoftware/Brave-Browser-Beta` | `~/.config/BraveSoftware/Brave-Browser-Beta` | `~/AppData/Local/BraveSoftware/Brave-Browser-Beta/User Data` |
| Google Chrome      | `~/Library/Application Support/Google/Chrome`                    | `~/.config/google-chrome`                    | `~/AppData/Local/Google/Chrome/User Data`                    |
| Google Chrome Beta | `~/Library/Application Support/Google/Chrome Beta`               | `~/.config/google-chrome-beta`               | `~/AppData/Local/Google/Chrome Beta/User Data`               |
| Chromium           | `~/Library/Application Support/Chromium`                         | `~/.config/chromium`                         | `~/AppData/Local/Chromium/User Data`                         |
| Microsoft Edge     | `~/Library/Application Support/Microsoft Edge`                   | `~/.config/microsoft-edge`                   | `~/AppData/Local/Microsoft/Edge/User Data`                   |
| Firefox            | `~/Library/Application Support/Firefox`                          | `~/.mozilla/firefox`                         | `~/AppData/Roaming/Mozilla/Firefox`                          |
| qutebrowser        | `~/.qutebrowser`                                                 | `~/.config/qutebrowser`                      | `~/AppData/Roaming/qutebrowser/config`                       |
| Safari             | `~/Library/Safari`                                               | -                                            | -                                                            |
| Vivaldi            | `~/Library/Application Support/Vivaldi`                          | `~/.config/vivaldi`                          | `~/AppData/Local/Vivaldi/User Data`                          |
| Waterfox           | `~/Library/Application Support/Waterfox`                         | `~/.waterfox`                                | `~/AppData/Roaming/Waterfox`                                 |

The structure of the directory is dependent on the browser. This is used to find
either the bookmarks file or other config files specific to the browser. **If
the user provided a custom path, the structure inside that directory should
match with the default config directory.** If there's some kind of mismatch, a
warning will be provided.

This option helps in case the browser was installed using a non-default install
method. For example, a browser might be installed using a package manager and
the data is stored in a directory specific to that package manager.

**Note:** For `buku`, this option doesn't apply as it has a custom logic to
get the bookmarks filepath. This logic is same as that in the official
implementation.

### `full_path`
> **boolean, default: true**

By default, the entire path to the bookmark is shown starting from the root
folder upto the bookmark name. If this is `false`, then only the bookmark name
will be shown in the finder. For example, if the bookmark path is
`foo/bar/name`, setting the config value to `false` would show only the `name`
part.

### `url_open_command`
> **string, default: "open"**

The command name used to open the selected bookmarks in the default browser.
The default value is based on macOS and should be overriden based on the user's
operating system. For example, on Linux one might use `xdg-open`.

The URL(s) for the selected bookmarks are passed as arguments to the command
after quoting them. For multiple selections, each URL is passed as a separate
argument separated by a space.

```
<command> "url1" "url2"
```

A warning is raised if the provided command failed to open the URL(s). This is
determined by its exit code where a non-zero exit code is assumed to be a
failure.

### `url_open_plugin`
> **string, default: nil**

The plugin can use any existing plugin to open the selected bookmarks. This
is useful when the same config is used across machines with different operating
system. If this option is provided, then it takes precedence over
`url_open_command`.

Following plugins are supported along with the config value:
* [open-browser.vim](https://github.com/tyru/open-browser.vim) - `open_browser`
* [vim-external](https://github.com/itchyny/vim-external) - `external_browser`

### `buku_include_tags`
> **boolean, default: false**

This config option is specific to the buku bookmark manager. If it's `true`,
the tags for every bookmark is added.

For telescope integration, an additional column is added which includes the tags
for every bookmark. This column is highlighted using the `Special` highlight
group.

### `debug`
> **boolean, default: false**

If `true`, provide debug messages which includes, but not limited to, the config
options, state values, telescope options, etc.

## Tips

### Using kind option to customize vim.ui.select implementer:

The `kind` value for `vim.ui.select` is **browser-bookmarks** which could be
used to customize the chosen implementation. For example, using
[telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim):

![telescope-ui-select](https://user-images.githubusercontent.com/67177269/224384378-67728250-ce9e-4bca-aed3-798485367494.png)

<details>
<summary>Screenshot configuration</summary>

```lua
require('telescope').setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {
        layout_config = {
          width = 0.8,
          height = 0.8,
        }
      },
      specific_opts = {
        ['browser-bookmarks'] = {
          make_displayer = function()
            return entry_display.create {
              separator = ' ',
              items = {
                { width = 0.5 },
                { remaining = true },
              },
              -- Use this instead if `buku_include_tags` is true:
              -- items = {
              --   { width = 0.3 },
              --   { width = 0.2 },
              --   { remaining = true },
              -- },
            }
          end,
          make_display = function(displayer)
            return function(entry)
              return displayer {
                entry.value.text.name,
                -- Uncomment if `buku_include_tags` is true:
                -- { entry.value.text.tags, 'Special' },
                { entry.value.text.url, 'Comment' },
              }
            end
          end,
        },
      },
    },
  },
}
```

</details>

## Contributing

Contributions are always welcome and highly appreciated. Refer to the
[Contributing Guidelines](./CONTRIBUTING.md).

## Videos

* [5 Terrific Neovim Telescope Extensions for 2022 🔭](https://youtu.be/indguFY7wJ0?t=86)

## References

* [Browsing Chrome bookmarks with fzf](https://junegunn.kr/2015/04/browsing-chrome-bookmarks-with-fzf/)
* [Code: plist parser](https://codea.io/talk/discussion/1269/code-plist-parser)
