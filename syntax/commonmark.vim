" Vim syntax file
" Language: CommonMark
" Maintainer: Caleb Maclennan <caleb@alerque.com>
" Maintainer: Felipe Morales <hel.sheep@gmail.com>

scriptencoding utf-8

if exists('b:current_syntax')
	finish
endif

syntax clear

" See: https://docs.rs/pulldown-cmark/0.7.1/pulldown_cmark/enum.Tag.html
hi def link cmarkParagraph NONE
hi def link cmarkHeading1 Title
hi def link cmarkHeading2 cmarkHeading1
hi def link cmarkHeading3 cmarkHeading1
hi def link cmarkHeading4 cmarkHeading1
hi def link cmarkHeading5 cmarkHeading1
hi def link cmarkHeading6 cmarkHeading1
hi def link cmarkBlockquote Define
hi def link cmarkCodeBlock Debug
hi def link cmarkList Identifier
hi def link cmarkItem Label
hi def link cmarkFootnoteDefinition Identifier
hi def link cmarkTable SpecialComment
hi def link cmarkTableHead SpecialComment
hi def link cmarkTableRow SpecialComment
hi def link cmarkTableCell SpecialComment
hi def cmarkEmphasis gui=Italic cterm=Italic
hi def cmarkStrong gui=Bold cterm=Bold
hi def link cmarkStrikethrough DiffDelete
hi def link cmarkLink Function
hi def link cmarkImage Exception

" See: https://docs.rs/pulldown-cmark/0.7.1/pulldown_cmark/enum.Event.html
hi def link cmarkText NONE
hi def link cmarkCode String
hi def link cmarkHtml Macro
hi def link cmarkFootnoteReference Identifier
hi def link cmarkHardBreak NonText
hi def link cmarkRule Delimiter
hi def link cmarkTaskListMarker Exception

if exists('g:commonmark_debug')
	hi! link cmarkParagraph Comment
	hi! link cmarkText Debug
endif

lua package.loaded["commonmarker"] = nil -- Force module reload during dev
lua commonmarker = require("commonmarker")
lua commonmarker.attach(vim.api.nvim_get_current_buf())

let b:current_syntax = 'commonmark'
