let s:save_cpo = &cpo
set cpo&vim

let s:outputter = {
\	"name" : "replace_region",
\	"kind" : "outputter",
\	"config" : {
\		"first" : "0",
\		"last"  : "0",
\		"back_cursor" : "0"
\	}
\}


function! s:pos(lnum, col, ...)
	let bufnr = get(a:, 1, 0)
	let off   = get(a:, 2, '.')
	return [bufnr, a:lnum, a:col, off]
endfunction


function! s:delete(first, last)
	let pos = getpos(".")
	call setpos('.', a:first)
	normal! v
	call setpos('.', a:last)
	normal! d
	call setpos(".", pos)
endfunction


function! s:outputter.output(data, session)
	let region = a:session.config.region
	let first = self.config.first == 0 ? [0] + region.first : s:pos(self.config.first, 0)
	let last  = self.config.last  == 0 ? [0] + region.last  : s:pos(self.config.last,  0)

	if first[1] > last[1]
		return
	endif
	try
		let tmp = @*
		call s:delete(first, last)
		let data = substitute(a:data, "\r\n", "\n", "g")
		let @* = join(split(data, "\n"), "\n")
		if empty(@*)
			return
		endif
		normal! "*P

		if self.config.back_cursor
			call setpos('.', first)
		endif
	catch /.*/
		echoerr v:exception
	finally
		let @* = tmp
	endtry
endfunction


function! quickrun#outputter#replace_region#new()
	return deepcopy(s:outputter)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
