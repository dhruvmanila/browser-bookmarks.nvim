.DEFAULT_GOAL := test

.deps/sqlite.lua:
	git clone --depth=1 https://github.com/tami5/sqlite.lua $@

.deps/telescope.nvim:
	git clone --depth=1 https://github.com/nvim-telescope/telescope.nvim $@

.deps/plenary.nvim:
	git clone --depth=1 https://github.com/nvim-lua/plenary.nvim $@

.PHONY: fmt
fmt:
	stylua --config-path .stylua.toml lua spec

.PHONY: test
test: .deps/sqlite.lua .deps/telescope.nvim .deps/plenary.nvim
	vusted

.PHONY: clean
clean:
	-rm luacov.*
	-rm -rf .deps
