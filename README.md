# Vim CommonMark

[![Vint](https://github.com/alerque/vim-commonmark/workflows/Vint/badge.svg)](https://github.com/alerque/vim-commonmark/actions?workflow=Vint)

Vim syntax highlighting and filetype plugin for [CommonMark][commonmark] using the [pulldown-cmark][pulldown-cmark] parser to inform the parsing. Because the syntax is not cobbled together from regular expressions but informed by a reas parser it will only ever highlight 100% valid CommonMark syntax (no false positives!).

Defaults options are for strict CommonMark mode, but some extensions are also available (footnotes, tables, task lists, strikethrough).

## Requirements

* Neovim (Support for VIM8 possible, contributions welcome) with Lua support
* Rust build toolchain (during development, may provide binaries later)
* GNU Make (at least during development, to be replaced by VimL install function later)

## Instructions

After installing plugin as usual, `cd` to the plugin directory and run `make`.

  [commonmark]: https://commonmark.org
  [pulldown-cmark]: https://github.com/raphlinus/pulldown-cmark
