.ONESHELL:

PROFILE ?= release

.PHONY: default
default: install-lua

.PHONY: install
install: install-lua

.PHONY: all
all: install-all

.PHONY: install-all
install-all: install-lua install-python

.PHONY: all-rust
all-rust: lib-lua lib-python

RUST_SOURCES = Cargo.lock src/lib.rs
CARGO_FLAGS = $(and $(PROFILE:debug=),--$(PROFILE))

.PHONY: lib-lua
lib-lua: target-lua/$(PROFILE)/libvim_commonmark.so

target-lua/$(PROFILE)/libvim_commonmark.so: $(RUST_SOURCES) src/lua.rs
	export LUA_INC=/usr/include/luajit-2.0/
	export LUA_LIB=/usr/lib LUA_LIB_NAME=luajit-5.1
	export LUA_LINK=dynamic
	cargo build --no-default-features --features lua --target-dir target-lua $(CARGO_FLAGS)

.PHONY: lib-python
lib-python: target-python/$(PROFILE)/libvim_commonmark.so

target-python/$(PROFILE)/libvim_commonmark.so: $(RUST_SOURCES) src/python.rs
	cargo build --no-default-features --features python --target-dir target-python $(CARGO_FLAGS)

.PHONY: install-lua
install-lua: lua/libvim_commonmark.so

lua/libvim_commonmark.so: target-lua/$(PROFILE)/libvim_commonmark.so
	mkdir -p $(@D)
	ln -sf ../$< $@

.PHONY: install-python
install-python: python3/libvim_commonmark.so

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
