if exists("g:loaded_vimik") || &cp
	finish
endif
let g:loaded_vimik = 1

let s:old_cpo = &cpo
set cpo&vim
let &cpo = s:old_cpo

let g:vimik_conf= {}
let g:vimik_conf.path = 0           " # of calls to VimikGet with path or path_html
let g:vimik_conf.path_html = 0      " # of calls to path_html()
let g:vimik_conf.normalize_path = 0 " # of calls to normalize_path()
let g:vimik_conf.subdir = 0         " # of calls to vimik#base#subdir()
let g:vimik_conf.timing = []        " various timing measurements
let g:vimik_conf.html = []          " html conversion timing

function! VimikGet(option) "{{{
	if has_key(g:vimik_conf, a:option)
		return g:vimik_conf[a:option]
	endif
	return -1
endfunction "}}}

function! VimikSet(option, value) "{{{
	let g:vimik_conf[a:option] = a:value
endfunction "}}}

function! s:find_wiki(path) "{{{
	let path = vimik#u#path_norm(vimik#u#chomp_slash(a:path))
	let basepath = VimikGet('path')
	if basepath == -1
		return -1
	endif
	let basepath = expand(basepath)
	let basepath = vimik#u#path_norm(vimik#u#chomp_slash(basepath))
	if vimik#u#path_common_pfx(basepath, path) == basepath
		return 1
	endif
	return -1
endfunction "}}}

function! s:setup_filetype() "{{{
	let path = expand('%:p:h')
	" if the file is in vimik, return 1
	" else return -1.
	let idx = s:find_wiki(path)

	" initialize and cache global vars of current state
	call vimik#base#setup_buffer_state(idx)

	set filetype=vimik
endfunction "}}}

autocmd BufNewFile,BufRead *.vmk call s:setup_filetype()
