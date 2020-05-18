.ONESHELL:

PROFILE ?= release

.PHONY: all
all: all-rust links

.PHONY: all-rust
all-rust: lua_lib python_lib

CARGO_FLAGS = $(and $(PROFILE:debug=),--$(PROFILE))

.PHONY: lua_lib
lua_lib: target-lua/$(PROFILE)/libvim_commonmark.so

target-lua/$(PROFILE)/libvim_commonmark.so:
	export LUA_INC=/usr/include/luajit-2.0/
	export LUA_LIB=/usr/lib LUA_LIB_NAME=luajit-5.1
	export LUA_LINK=dynamic
	cargo build --no-default-features --features lua --target-dir target-lua $(CARGO_FLAGS)

.PHONY: python_lib
python_lib: target-python/$(PROFILE)/libvim_commonmark.so

target-python/$(PROFILE)/libvim_commonmark.so:
	cargo build --no-default-features --features python --target-dir target-python $(CARGO_FLAGS)

.PHONY: links
links: lua/libvim_commonmark.so python3/libvim_commonmark.so

lua/libvim_commonmark.so: target-lua/$(PROFILE)/libvim_commonmark.so
	mkdir -p $(@D)
	ln -sf ../$< $@

python3/libvim_commonmark.so: target-python/$(PROFILE)/libvim_commonmark.so
	mkdir -p $(@D)
	ln -sf ../$< $@

.PHONY: test
test: test-rust

.PHONY: test-rust
test-rust:
	export LUA_INC=/usr/include/luajit-2.0/
	export LUA_LIB=/usr/lib LUA_LIB_NAME=luajit-5.1
	export LUA_LINK=dynamic
	cargo test --no-default-features --features lua --target-dir target-lua $(CARGO_FLAGS)

