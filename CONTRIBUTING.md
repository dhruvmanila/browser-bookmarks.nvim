# Contributing to browser-bookmarks.nvim

Thank you for investing your time in contributing to this project! 🎉

## Project structure

```sh
.
├── lua
│   ├── browser_bookmarks
│   │   ├── browsers
│   │   │   ├── ...
│   │   │   └── init.lua  # [2]
│   │   ├── parser
│   │   │   └── ...
│   │   ├── ...
│   │   └── init.lua  # [1]
│   └── telescope
│       └── _extensions
│           └── bookmarks.lua  # [3]
└── spec
    ├── fixtures
    │   └── ...
    ├── unit
    │   └── ...
    ├── conftest.lua  # [4]
    └── helpers.lua
```

1. Entrypoint for the plugin. This is where the public API resides along with
   the `setup` function.
2. Entrypoint for the browsers module. This module contains implementation of
   the `BrowserInterface` for all the supported browsers. Other checks such as
   dependency, browser support are done here.
3. Entrypoint for the telescope extension. For information on telescope.nvim
   extension folder structure, please refer to the
   [wiki](https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions#extension-folder-structure).
4. Test configuration. This is automatically read by `busted`.

### Module: `browsers`

Browsers module is the entrypoint in accessing the browser specific
implementation. This is done by directly indexing the module:

```lua
require("browser_bookmarks.browsers")[config.selected_browser]
```

Chromium based browsers uses the same implementation which is present in
`chromium.lua` file. The entrypoint makes sure to route such browsers to
reuse existing implementation.

Dependency check for specific browsers is performed in this module. For example,
buku, Firefox and Waterfox depends on `sqlite.lua`, so if the selected browser
is one of them, the check is performed.

### Browser module interface

Every browser module satisfies an interface by exporting a single function with
a fixed signature. It returns a list of Bookmarks or `nil` if failed to extract
the bookmarks. Please refer to the
[`types.lua`](./lua/browser_bookmarks/types.lua) module for more information on
the custom types.

```lua
local browser = {}

---@param config BrowserBookmarksState
---@return Bookmark[]|nil
function browser.collect_bookmarks(config)
  return nil
end
```

## Getting started

You can look at the currently open
[issues](https://github.com/dhruvmanila/browser-bookmarks.nvim/issues) to see
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
