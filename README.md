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

The extension options should be provided to override the default values. They're
provided in the bookmarks table like so:

```lua
require('telescope').setup {
  extensions = {
    bookmarks = {
      -- Provide the options here to override the default values.
      -- ...
    },
  },
}
```

### `selected_browser` (string, default: "brave")

The selected browser to collect the bookmarks from. An error is raised if the
provided browser name is unsupported. The list of supported browser along with
the config value is as follows:

| Browser / Tool     | Config value |
| ------------------ | :----------: |
| buku               | `buku`       |
| Brave              | `brave`      |
| Brave Beta         | `brave_beta` |
| Google Chrome      | `chrome`     |
| Google Chrome Beta | `chrome_beta`|
| Chromium           | `chromium`   |
| Microsoft Edge     | `edge`       |
| Firefox            | `firefox`    |
| qutebrowser        | `qutebrowser`|
| Safari             | `safari`     |
| Vivaldi            | `vivaldi`    |
| Waterfox           | `waterfox`   |

### `profile_name` (string, default: nil)

This option is only applicable for the browsers which allow switching between
profiles and the extension supports it. The default profile will be used if the
value is `nil` otherwise the extension will try to collect the bookmarks for the
given profile.

If the given profile does not exist or the extension is unable to get the
profile related information, an appropriate warning message will be provided.

Following browsers are supported for the config option:
* Brave
* Brave Beta
* Google Chrome
* Google Chrome Beta
* Chromium
* Microsoft Edge
* Firefox
* Vivaldi
* Waterfox

For the non-supported browsers, a warning will be provided and the extension
will exit without opening the finder.

### `config_dir` (string, default: nil)

This is the absolute path to the config directory where the selected browser's
data is stored on the respective operating system. If `nil`, the default path
will be used as specified in the table below. It can be used as a reference in
determining the custom path.

| Browser            | MacOS                                                            | Linux                                        | Windows                                                      |
| ------------------ | ---------------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
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
either the bookmarks file or other config files specific to the browser. If the
user provided a custom path, it should match with the default config path. If it
doesn't a warning will be provided.

This option helps in case the browser was installed using a non-default install
method. For example, a browser might be installed using a package manager and
the data is stored in a directory specific to that package manager.

### `full_path` (boolean, default: true)

By default, the entire path to the bookmark is shown starting from the root
folder upto the bookmark name. If this is `false`, then only the bookmark name
will be shown in the finder. For example, if the bookmark path is
`foo/bar/name`, setting the config value to `false` would show only the `name`
part.

### `url_open_command` (string, default: "open")

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

### `url_open_plugin` (string, default: nil)

The extension can use any existing plugin to open the selected bookmarks. This
is useful when the same config is used across machines with different operating
system. If this option is provided, then it takes precedence over
`url_open_command`.

Following plugins are supported along with the config value:
* [open-browser.vim](https://github.com/tyru/open-browser.vim) - `open_browser`
* [vim-external](https://github.com/itchyny/vim-external) - `external_browser`

### `buku_include_tags` (boolean, default: false)

This config option is specific to the buku bookmark manager. If it's `true`,
then an additional column is added which includes the tags for every bookmark.
This column is highlighted using the `Special` highlight group.

### `debug` (boolean, default: false)

If `true`, provide debug messages which includes, but not limited to, the config
options, state values, telescope options, etc.

## Contributing

Contributions are always welcome and highly appreciated. Refer to the
[Contributing Guidelines](./CONTRIBUTING.md).

## References

* [Browsing Chrome bookmarks with fzf](https://junegunn.kr/2015/04/browsing-chrome-bookmarks-with-fzf/)
* [Code: plist parser](https://codea.io/talk/discussion/1269/code-plist-parser)
