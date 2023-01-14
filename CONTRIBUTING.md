# Contributing to telescope-bookmarks.nvim

Thank you for investing your time in contributing to this project! 🎉

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
