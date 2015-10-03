if exists("g:loaded_vimik") || &cp
	finish
endif
let g:loaded_vimik = 1

let s:old_cpo = &cpo
set cpo&vim

function! VimikGet(option) "{{{
	if has_key(g:vimik_conf, a:option)
		return g:vimik_conf[a:option]
	endif
	return -1
endfunction "}}}

function! VimikSet(option, value) "{{{
	let g:vimik_conf[a:option] = a:value
endfunction "}}}

command! VimikIndex call base#goto_index()
command! VimikTabIndex call base#goto_index(1)

if !hasmapto('<Plug>VimikIndex')
  nmap <silent><unique> <Leader>ww <Plug>VimikIndex
endif
nnoremap <unique><script> <Plug>VimikIndex :VimikIndex<CR>

if !hasmapto('<Plug>VimikTabIndex')
  nmap <silent><unique> <Leader>wt <Plug>VimikTabIndex
endif
nnoremap <unique><script> <Plug>VimikTabIndex :VimikTabIndex<CR>

let &cpo = s:old_cpo
