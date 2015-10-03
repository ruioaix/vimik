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

function! Vimik_chomp_slash(str) "{{{
	return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}

function! Vimik_path_norm(path) "{{{
	" /-slashes
	let path = substitute(a:path, '\', '/', 'g')
	" treat multiple consecutive slashes as one path separator
	let path = substitute(path, '/\+', '/', 'g')
	" ensure that we are not fooled by a symbolic link
	return resolve(path)
endfunction "}}}

function! Vimik_path_common_pfx(path1, path2) "{{{
  let p1 = split(a:path1, '[/\\]', 1)
  let p2 = split(a:path2, '[/\\]', 1)

  let idx = 0
  let minlen = min([len(p1), len(p2)])
  while (idx < minlen) && (p1[idx] ==? p2[idx])
    let idx = idx + 1
  endwhile
  if idx == 0
    return ''
  else
    return join(p1[: idx-1], '/')
  endif
endfunction "}}}

function! s:find_wiki(path) "{{{
	let path = Vimik_path_norm(Vimik_chomp_slash(a:path))
	let basepath = VimikGet('path')
	if basepath == -1
		return -1
	endif
	let basepath = expand(basepath)
	let basepath = Vimik_path_norm(Vimik_chomp_slash(basepath))
	if Vimik_path_common_pfx(basepath, path) == basepath
		return 1
	endif
	return -1
endfunction "}}}

function! Vimik_subdir(path, filename) "{{{
  let path = a:path
  " ensure that we are not fooled by a symbolic link
  "FIXME if we are not "fooled", we end up in a completely different wiki?
  let filename = resolve(a:filename)

  let idx = 0
  "FIXME this can terminate in the middle of a path component!
  while path[idx] ==? filename[idx]
    let idx = idx + 1
  endwhile

  let p = split(strpart(filename, idx), '[/\\]')
  let res = join(p[:-2], '/')
  if len(res) > 0
    let res = res.'/'
  endif
  return res
endfunction "}}}

function! Vimik_get_wikifile_url(wikifile) "{{{
  return VimikGet('path_html').
    \ Vimik_subdir(VimikGet('path'), a:wikifile).
    \ fnamemodify(a:wikifile, ":t:r").'.html'
endfunction "}}}

function! Vimik_setup_buffer_state(idx) " {{{ Init page-specific variables
  " Only call this function *after* opening a wiki page.
  if a:idx < 0
    return
  endif

  " The following state depends on the current active wiki page
  let subdir = Vimik_subdir(VimikGet('path'), expand('%:p'))
  call VimikSet('subdir', subdir)
  call VimikSet('url', Vimik_get_wikifile_url(expand('%:p')))
endfunction " }}}

function! s:setup_filetype() "{{{
	let path = expand('%:p:h')
	" if the file is in vimik, return 1
	" else return -1.
	let idx = s:find_wiki(path)

	" initialize and cache global vars of current state
	call Vimik_setup_buffer_state(idx)

	set filetype=vimik
endfunction "}}}

autocmd BufNewFile,BufRead *.vmk call s:setup_filetype()
