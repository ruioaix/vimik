if exists("g:loaded_vimik") || &cp
	finish
endif
let g:loaded_vimik = 1

let s:old_cpo = &cpo
set cpo&vim

if !exists("g:vimik_conf") || !exists("g:vimik_conf.path") || !exists("g:vimik_conf.path_html")
	let g:vimik_conf= {}
	let g:vimik_conf.path = '~/VIMIK/sourcex/'
	let g:vimik_conf.path_html = '~/VIMIK/html/'
	let g:vimik_conf.index = 'index'
	let g:vimik_conf.ext = '.vmk'
endif

let g:vimik_conf.cmd_vmk2html = substitute(expand('<sfile>:p:h'), '/plugin$', '/hoedown/hoedown --vimiklink --vimikdirlevel ', '')

function! VimikGet(option) "{{{
	if has_key(g:vimik_conf, a:option)
		return g:vimik_conf[a:option]
	endif
	return -1
endfunction "}}}

function! VimikSet(option, value) "{{{
	let g:vimik_conf[a:option] = a:value
endfunction "}}}

call VimikSet('path', expand(VimikGet('path')))
call VimikSet('path_html', expand(VimikGet('path_html')))

command! VimikIndex call vimik#goto_index()
command! VimikTabIndex call vimik#goto_index(1)

if !hasmapto('<Plug>VimikIndex')
	nmap <silent><unique> <Leader>ww <Plug>VimikIndex
endif
nnoremap <unique><script> <Plug>VimikIndex :VimikIndex<CR>

if !hasmapto('<Plug>VimikTabIndex')
	nmap <silent><unique> <Leader>k <Plug>VimikTabIndex
endif
nnoremap <unique><script> <Plug>VimikTabIndex :VimikTabIndex<CR>

let &cpo = s:old_cpo

let magic_chars = '.*[]\^$'
let valid_chars = '[^\\\]]'
let g:vimik_LinkPrefix = '[['
let g:vimik_LinkPrefix = escape(g:vimik_LinkPrefix, magic_chars)
let g:vimik_LinkSuffix = ']]'
let g:vimik_LinkSuffix = escape(g:vimik_LinkSuffix, magic_chars)
let g:vimik_LinkSeparator = '|'
let g:vimik_LinkSeparator = escape(g:vimik_LinkSeparator, magic_chars)
let g:vimik_LinkUrl = valid_chars.'\{-}'
let g:vimik_LinkDescr = valid_chars.'\{-}'
" [[URL]], or [[URL|DESCRIPTION]]
" a) match [[URL|DESCRIPTION]]
let g:vimik_Link = g:vimik_LinkPrefix . g:vimik_LinkUrl . '\%(' . g:vimik_LinkSeparator . g:vimik_LinkDescr . '\)\?' . g:vimik_LinkSuffix
" b) match URL within [[URL|DESCRIPTION]]
let g:vimik_LinkMatchUrl = g:vimik_LinkPrefix.
      \ '\zs'. g:vimik_LinkUrl.'\ze\%('. g:vimik_LinkSeparator.
      \ g:vimik_LinkDescr.'\)\?'.g:vimik_LinkSuffix
" c) match DESCRIPTION within [[URL|DESCRIPTION]]
let g:vimik_LinkMatchDescr = g:vimik_LinkPrefix.
      \ g:vimik_LinkUrl.g:vimik_LinkSeparator.'\%('.
      \ '\zs'. g:vimik_LinkDescr. '\ze\)\?'. g:vimik_LinkSuffix
