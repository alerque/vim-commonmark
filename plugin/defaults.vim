if exists('g:commonmark#loaded') && g:commonmark#loaded
	finish
endif
let g:commonmark#loaded = 1

if !exists('g:commonmark#extensions#all')
	let g:commonmark#extensions#all = 0
endif

if !exists('g:commonmark#extensions')
	if g:commonmark#extensions#all
		let g:commonmark#extensions =
					\ ['tables', 'footnotes', 'strikethrough', 'tasklists']
	else
		let g:commonmark#extensions = []
	endif
endif
