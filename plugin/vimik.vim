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
	call Vimik_setup_buffer_state(s:find_wiki(path))
	set filetype=vimik
endfunction "}}}

autocmd BufNewFile,BufRead *.vmk call s:setup_filetype()

function! Vimik_mkdir(path, ...) "{{{
  let path = expand(a:path)
  if !isdirectory(path) && exists("*mkdir")
    let path = Vimik_chomp_slash(path)
    if a:0 && a:1 && tolower(input("Vimik: Make new directory: ".path."\n [Y]es/[n]o? ")) !~ "y"
      return 0
    endif
    call mkdir(path, "p")
  endif
  return 1
endfunction " }}}

function! Vimik_edit_file(command, filename, ...) "{{{
  let fname = escape(a:filename, '% *|#')
  let dir = fnamemodify(a:filename, ":p:h")
  if Vimik_mkdir(dir, 1)
    execute a:command.' '.fname
  else
    echom ' '
    echom 'Vimik: Unable to edit file in non-existent directory: '.dir
  endif

  " save previous link
  " a:1 -- previous vimik link to save
  " a:2 -- should we update previous link
  if a:0 && a:2 && len(a:1) > 0
    let b:vimik_prev_link = a:1
  endif
endfunction " }}}

function! Vimik_goto_index() "{{{
	let cmd = 'tabedit'
	call Vimik_edit_file(cmd, VimikGet('path') . VimikGet('index'). VimikGet('ext'))
	call Vimik_setup_buffer_state(1)
endfunction "}}}

command! VimikIndex  call Vimik_goto_index()

if !hasmapto('<Plug>VimikIndex')
  nmap <silent><unique> <Leader>ww <Plug>VimikIndex
endif
nnoremap <unique><script> <Plug>VimikIndex :VimikIndex<CR>

let &cpo = s:old_cpo
