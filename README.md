# Vim CommonMark

[![Cargo Build](https://img.shields.io/github/workflow/status/alerque/vim-commonmark/Rust?label=Cargo+Build)](https://github.com/alerque/vim-commonmark/actions?workflow=Rust)
[![Rust Code Format](https://img.shields.io/github/workflow/status/alerque/vim-commonmark/Rustfmt?label=Rustfmt&logo=Rust)](https://github.com/alerque/vim-commonmark/actions?workflow=Rustfmt)
[![VimL Lint Status](https://github.com/alerque/vim-commonmark/workflows/Vint/badge.svg)](https://github.com/alerque/vim-commonmark/actions?workflow=Vint)
[![Lua Lint Status](https://img.shields.io/github/workflow/status/alerque/vim-commonmark/Luacheck?label=Luacheck&logo=Lua)](https://github.com/alerque/vim-commonmark/actions?workflow=Luacheck)

Vim syntax plugin specifically targetting [CommonMark][commonmark] using the [pulldown-cmark][pulldown-cmark] parser to inform the highlighting. Because the syntax is not cobbled together from regular expressions but informed by a real parser it will only ever highlight 100% valid CommonMark syntax (no false positives!).

Defaults options are for strict CommonMark mode, but some extensions are also available (footnotes, tables, task lists, strikethrough).

## Requirements

* Neovim (Support for VIM8 would be possible, contributions welcome) with Lua support
* Rust build toolchain (during development, binaries may be provided later)
* GNU Make (during development, to be replaced by VimL install function later)

## Instructions

Using `vim-plug`:

```viml
:Plug 'alerque/vim-commonmark', {'do': 'make'}
```

...or manually after installing via your usual method, run `make` from the plugin directory.

  [commonmark]: https://commonmark.org
  [pulldown-cmark]: https://github.com/raphlinus/pulldown-cmark

<!-- vim: ft=commonmark
-->
