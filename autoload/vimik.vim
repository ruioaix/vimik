function! vimik#delete_tail_slash(str) "{{{
	return substitute(a:str, '[/]\+$', '', '')
endfunction "}}}

function! vimik#mkdir(path, ...) "{{{
	let path = expand(a:path)
	if !isdirectory(path) && exists("*mkdir")
		let path = vimik#delete_tail_slash(path)
		if a:0 && a:1 && tolower(input("Vimik: Make new directory: ".path."\n [Y]es/[n]o? ")) !~ "y"
			return 0
		endif
		call mkdir(path, "p")
	endif
	return 1
endfunction " }}}

function! vimik#edit_file(command, filename, ...) "{{{
	let fname = escape(a:filename, '% *|#')
	let dir = fnamemodify(a:filename, ":p:h")
	if vimik#mkdir(dir, 1)
		execute a:command.' '.fname
		" save previous link
		" a:1 -- previous vimik link to save
		" a:2 -- should we update previous link
		if a:0 && len(a:1) > 0
			let b:vimik_prev_link = a:1
		endif
	else
		echom ' '
		echom 'Vimik: Unable to edit file in non-existent directory: '.dir
	endif
endfunction " }}}

function! vimik#subdir(path, filename) "{{{
	let path = fnamemodify(a:path, ":p")
	let filename = a:filename
	let idx = 0
	while path[idx] ==? filename[idx]
		let idx = idx + 1
	endwhile

	let p = split(strpart(filename, idx), '/')
	let res = join(p[:-2], '/')
	if len(res) > 0
		let res = res.'/'
	endif
	return res
endfunction "}}}

function! vimik#save_subdir_and_htmlurl() " {{{ Init page-specific variables
	let subdir = vimik#subdir(VimikGet('path'), expand('%:p'))
	call VimikSet('subdir', subdir)
	let html_url = VimikGet('path_html') . subdir . expand('%:t:r') . '.html'
	call VimikSet('url', html_url)
endfunction " }}}

function! vimik#goto_index(...) "{{{
	if a:0
		let cmd = 'tabedit'
	else
		let cmd = 'edit'
	endif

	let indexfile = VimikGet('path') . VimikGet('index') . VimikGet('ext')
	call vimik#edit_file(cmd, indexfile)
	call vimik#save_subdir_and_htmlurl()
endfunction "}}}

function! vimik#matchstr_at_cursor(wikiRX) "{{{
	let col = col('.') - 1
	let line = getline('.')
	let ebeg = -1
	let cont = match(line, a:wikiRX, 0)
	while (ebeg >= 0 || (0 <= cont) && (cont <= col))
		let contn = matchend(line, a:wikiRX, cont)
		if (cont <= col) && (col < contn)
			let ebeg = match(line, a:wikiRX, cont)
			let elen = contn - ebeg
			break
		else
			let cont = match(line, a:wikiRX, contn)
		endif
	endwh
	if ebeg >= 0
		return strpart(line, ebeg, elen)
	else
		return ""
	endif
endf "}}}

function! vimik#open_link(cmd, link, ...) "{{{
	let path = VimikGet('path')
	let subdir = VimikGet('subdir')
	let lnk = a:link
	if lnk =~ '.\+[/\\]$'
		let ext = ""
	else
		let ext = VimikGet('ext')
	endif
	let url = path.subdir.lnk.ext

	let vimik_prev_link = []
	if &ft == 'vimik'
		let vimik_prev_link = [expand('%:p'), getpos('.')]
	endif

	call vimik#edit_file(a:cmd, url, vimik_prev_link)
endfunction " }}}

function! vimik#follow_link(split, ...) "{{{ Parse link at cursor and pass 
	if a:split == "split"
		let cmd = ":split "
	elseif a:split == "vsplit"
		let cmd = ":vsplit "
	elseif a:split == "tabnew"
		let cmd = ":tabnew "
	else
		let cmd = ":e "
	endif

	" try WikiLink
	let lnk = matchstr(vimik#matchstr_at_cursor(g:vimik_Link), g:vimik_LinkMatchUrl)

	if lnk != ""
		execute 'silent w'
		call vimik#open_link(cmd, lnk)
	endif
endfunction " }}}

function! vimik#go_back_link() "{{{
	exe 'silent :w'
	call vimik#go_back_link_c()
endfunction

function! vimik#go_back_link_c() "{{{
	if exists("b:vimik_prev_link")
		" go back to saved wiki link
		let prev_word = b:vimik_prev_link
		execute ":e ".substitute(prev_word[0], '\s', '\\\0', 'g')
		call setpos('.', prev_word[1])
	endif
endfunction " }}}

" vimik#base#system_open_link
function! vimik#system_open_link(url) "{{{
	" handlers
	function! s:macunix_handler(url)
		execute 'silent !open ' . shellescape(a:url, 1)
		redraw!
	endfunction
	function! s:linux_handler(url)
		call system('xdg-open ' . shellescape(a:url, 1).' &')
	endfunction
	let success = 0
	try 
		if has("macunix")
			call s:macunix_handler(a:url)
			return
		else
			call s:linux_handler(a:url)
			return
		endif
	endtry
	echomsg 'Default Vimik link handler was unable to open the HTML file!'
endfunction "}}}

function! vimik#vmk2html(file)
	let file = a:file
	let fname = fnamemodify(file, ":t:r")
	let subdir = vimik#subdir(VimikGet('path'), file)
	let level = len(split(subdir, '/'))
	let dir = VimikGet('path_html') . subdir
	let opfile = VimikGet('path_html') . subdir . fname . '.html'
	let opfile2 = substitute(opfile, ' ', '\\ ', 'g')
	let file = substitute(file, ' ', '\\ ', 'g')
	let cmd = VimikGet('cmd_vmk2html') . level . ' ' . file . ' > ' . opfile2
	"echomsg cmd
	call vimik#mkdir(dir)
	exe 'silent :w'
	let s = system(cmd)
	if v:shell_error
		echomsg 'File: "' . file . '" convert to html ==FAILED==' 
		echomsg s
	else
		echomsg 'File: "' . file . '" convert to html [SUCCESS]'
	endif
	return opfile
endfunction

function! vimik#vmkALL2html() 
	let wikifiles = split(glob(VimikGet('path').'**/*'.VimikGet('ext')), '\n')
	for wikifile in wikifiles
		call vimik#vmk2html(wikifile)
	endfor
endfunction

function! vimik#gitpush_core(...)
	let htmldir = VimikGet('path_html')
	if a:0 >= 2
		let file = a:1
		let opfile = a:2
		let message = '"'.file.' '.opfile.' modify"'
		let cmd = 'cd ' . htmldir . ' && git add ' . file . ' ' . opfile
	else
		let message = '"all push"'
		let cmd = 'cd ' . htmldir . ' && git add .'
	endif

	let s = system(cmd)
	if v:shell_error
		echomsg 'GitAdd: '.message.' '.s.' ==FAILED==' 
	else
		let cmd = 'cd ' . htmldir . ' && git commit -a -m '.message
		let s = system(cmd)
		if v:shell_error
			echomsg 'GitCommit: '.message.' '.s.' ==FAILED==' 
		else
			echomsg 'GitCommit: '.s.' [SUCCESS]'
			let cmd = 'cd ' . htmldir . ' && git push'
			echomsg 'GitPush: begin...'
			let s = system(cmd)
			if v:shell_error
				echomsg 'GitPush: '.message.' '.s.' ==FAILED=='
			else
				echomsg 'GitPush: '.message.' '.s.' [SUCCESS]'
			endif
			echomsg 'Git Push [DONE]'
		endif
	endif
endfunction

function! vimik#gitpush(file)
	let file = a:file
	let opfile = vimik#vmk2html(file)
	let opfile2 = substitute(opfile, ' ', '\\ ', 'g')
	call vimik#gitpush_core(file, opfile2)
endfunction

function! vimik#gitpushall()
	let wikifiles = split(glob(VimikGet('path').'**/*'.VimikGet('ext')), '\n')
	for wikifile in wikifiles
		call vimik#vmk2html(wikifile)
	endfor
	call vimik#gitpush_core()
endfunction

function! vimik#search_word(wikiRx, cmd) "{{{
	let match_line = search(a:wikiRx, 's'.a:cmd)
	if match_line == 0
		echomsg 'vimik: Wiki link not found.'
	endif
endfunction " }}}

function! vimik#nextlink() 
	call vimik#search_word(g:vimik_Link, '')
endfunction

function! vimik#lastlink() 
	call vimik#search_word(g:vimik_Link, 'b')
endfunction

function! vimik#delete_link() "{{{
	" file system funcs Delete wiki link you are in from filesystem
	let val = input('Delete ['.expand('%').'] (y/n)? ', "")
	if val != 'y'
		return
	endif
	let fname = expand('%:p')
	"echomsg fname
	exe 'silent :w'
	try
		let a = delete(fname)
	catch /.*/
		echomsg 'vimik: Cannot delete "'.expand('%:t:r').'"!'
		return
	endtry

	call vimik#go_back_link_c()
	execute "bdelete! ".escape(fname, " ")

	" reread buffer => deleted
	" wiki link should appear as
	" non-existent
	if expand('%:p') != ""
		execute "e"
	endif
endfunction "}}}

