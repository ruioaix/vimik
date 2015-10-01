if exists("g:loaded_vimik") || &cp
	finish
endif
let g:loaded_vimik = 1

let s:old_cpo = &cpo
set cpo&vim

function! s:find_wiki(path) "{{{
	" XXX: find_wiki() does not (yet) take into consideration the ext
	let path = vimwiki#u#path_norm(vimwiki#u#chomp_slash(a:path))
	let idx = 0
	while idx < len(g:vimwiki_list)
		let idx_path = expand(VimwikiGet('path', idx))
		let idx_path =
		vimwiki#u#path_norm(vimwiki#u#chomp_slash(idx_path))
		if vimwiki#u#path_common_pfx(idx_path, path) ==
			idx_path
			return idx
		endif
		let idx += 1
	endwhile
	return -1
	" an orphan page has been detected
endfunction "}}}

function! s:setup_filetype() "{{{
	let time0 = reltime()  " start the clock  
	" Find what wiki current buffer belongs to.
	let path = expand('%:p:h')
	" XXX: find_wiki() does not (yet) take into consideration the ext
	let idx = s:find_wiki(path)
	if g:vimwiki_debug ==3
		echom "  Setup_filetype
		g:curr_idx=".g:vimwiki_current_idx."
		find_idx=".idx."
		b:curr_idx=".s:vimwiki_idx().""
	endif

	if idx == -1 && g:vimwiki_global_ext == 0
		return
	endif
	"XXX when idx = -1? (an orphan page has
	"been detected)

	"TODO: refactor (same code in
	setup_buffer_enter)
	" The buffer's file is not in the
	path and user *does* want his wiki
	" extension(s) to be global -- Add
	new wiki.
	if idx == -1
		let ext = '.'.expand('%:e')
		" lookup syntax using
		g:vimwiki_ext2syntax
		if
			has_key(g:vimwiki_ext2syntax,
			ext)
			let syn =
			g:vimwiki_ext2syntax[ext]
		else
			let
			syn =
			s:vimwiki_defaults.syntax
		endif
		call
		add(g:vimwiki_list,
		{'path':
		path,
		'ext':
		ext,
		'syntax':
		syn,
		'temp':
		1})
		let
		idx
		=
		len(g:vimwiki_list)
		-
		1
	endif
	call
	vimwiki#base#validate_wiki_options(idx)
	"
	initialize
	and
	cache
	global
	vars
	of
	current
	state
	call
	vimwiki#base#setup_buffer_state(idx)
	if
		g:vimwiki_debug
		==3
		echom
		"
		Setup_filetype
		g:curr_idx=".g:vimwiki_current_idx."
		(reset_wiki_state)
		b:curr_idx=".s:vimwiki_idx().""
	endif

	unlet! b:vimwiki_fs_rescan
	set filetype=vimwiki
	if g:vimwiki_debug ==3
		echom "  Setup_filetype g:curr_idx=".g:vimwiki_current_idx." (set ft=vimwiki) b:curr_idx=".s:vimwiki_idx().""
	endif
	let time1 = vimwiki#u#time(time0)  "XXX
	call VimwikiLog_extend('timing',['plugin:setup_filetype:time1',time1])
endfunction "}}}

let extensions = ['.vmk']
augroup vimik
	autocmd!
	for ext in extensions
		exe 'autocmd BufEnter *'.ext.' call s:setup_buffer_reenter()'
		exe 'autocmd BufWinEnter *'.ext.' call s:setup_buffer_enter()'
		exe 'autocmd BufLeave,BufHidden *'.ext.' call s:setup_buffer_leave()'
		exe 'autocmd BufNewFile,BufRead, *'.ext.' call s:setup_filetype()'
		exe 'autocmd ColorScheme *'.ext.' call s:setup_cleared_syntax()'
	endfor
augroup END
