.deps/sqlite.lua:
	git clone --depth=1 https://github.com/tami5/sqlite.lua $@

.deps/telescope.nvim:
	git clone --depth=1 https://github.com/nvim-telescope/telescope.nvim $@

.deps/plenary.nvim:
	git clone --depth=1 https://github.com/nvim-lua/plenary.nvim $@

.PHONY: fmt
fmt:
	stylua --config-path stylua.toml --glob 'lua/**/*.lua' -- lua

.PHONY: test
test: .deps/sqlite.lua .deps/telescope.nvim .deps/plenary.nvim
	VUSTED_ARGS='--headless --clean' vusted \
		--helper=$(CURDIR)/spec/conftest.lua \
		--output=gtest
