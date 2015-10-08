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
	let lnk = matchstr(vimik#matchstr_at_cursor(g:vimwiki_rxWikiLink), g:vimwiki_rxWikiLinkMatchUrl)

	" try WikiIncl
	if lnk == ""
		let lnk = matchstr(vimik#matchstr_at_cursor(g:vimwiki_rxWikiIncl),
					\ g:vimwiki_rxWikiInclMatchUrl)
	endif

	" try Weblink
	if lnk == ""
		let lnk = matchstr(vimik#matchstr_at_cursor(g:vimwiki_rxWeblink),
					\ g:vimwiki_rxWeblinkMatchUrl)
	endif

	if lnk != ""
		if !VimwikiLinkHandler(lnk)
			call vimwiki#vimik#open_link(cmd, lnk)
		endif
		return
	endif

	if a:0 > 0
		execute "normal! ".a:1
	else		
		call vimwiki#vimik#normalize_link(0)
	endif

endfunction " }}}
