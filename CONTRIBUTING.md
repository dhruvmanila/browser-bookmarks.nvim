# Contributing to telescope-bookmarks.nvim

Thank you for investing your time in contributing to this project! 🎉

## Project structure

```sh
.
├── lua
│   └── telescope
│       └── _extensions
│           ├── bookmarks
│           │   ├── parser
│           │   │   └── ...
│           │   └── ...
│           └── bookmarks.lua
└── spec
    ├── fixtures
    │   └── ...
    ├── unit
    │   └── ...
    ├── conftest.lua
    └── helpers.lua
```

For information on telescope.nvim extension folder structure, please refer to the
[wiki](https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions#extension-folder-structure).

### Browser module interface

The `bookmarks.lua` file is the entrypoint for the extension. For every browser,
there's a file with the same name as that of the config value which is imported
when the extension is invoked. This is done so that dependencies specific to the
browser is only required if the user selected that browser.

Taking Google Chrome as an example, there's a `chrome.lua` file and the same
name (removing the extension) is used for the `selected_browser` config option.
This makes it easier to import the browser module:

```lua
require("telescope._extensions.bookmarks." .. config.selected_browser)
```

Every browser module satisfies an interface by exporting a single function with
a fixed signature. It returns a list of Bookmarks or `nil` if failed to extract
the bookmarks. Please refer to the
[`types.lua`](./lua/telescope/_extensions/bookmarks/types.lua) module for more
information on the custom types.

```lua
local browser = {}

---@param state TelescopeBookmarksState
---@param config TelescopeBookmarksConfig
---@return Bookmark[]|nil
function browser.collect_bookmarks(state, config)
  return nil
end
```

For all the chromium based browser, the respective browser module still needs to
be defined but, it should directly use the `chrome.lua` module internally. Take
a look at `brave.lua` module as an example.

## Getting started

You can look at the currently open
[issues](https://github.com/dhruvmanila/telescope-bookmarks.nvim/issues) to see
if there's a feature which you would like to work on or a reported bug to fix.

### Development

Development of this project happens on GitHub using issues and pull requests.
Please open an issue first for feature requests and bug reports. A pull request
can be opened directly if the changes are small enough.

### Formatting

The project uses [stylua](https://github.com/JohnnyMorganz/StyLua) for code
formatting. It can be run using `make fmt`.

### Testing

The project uses [vusted](https://github.com/notomo/vusted) for testing. Please
refer to the project README for installation instructions. The tests can be run
using `make` with the following command:

```
make test
```

This will install the dependencies such as `telescope.nvim`, etc. in a `.deps`
directory and invoke the `vusted` command. To use the latest version of the
dependencies for testing, remove them using `make clean` and then invoke the
test target again.

#### Code coverage

The project uses [luacov](https://github.com/lunarmodules/luacov) for coverage
reports. Please refer to the project README for installation instructions. The
coverage report is generated automatically when running `vusted`.

## Release process

The project follows [Semantic Versioning](https://semver.org/). The release
process is done manually using GitHub Releases.
