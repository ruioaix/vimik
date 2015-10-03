function! base#chomp_slash(str) "{{{
  return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}

function! base#mkdir(path, ...) "{{{
  let path = expand(a:path)
  if !isdirectory(path) && exists("*mkdir")
    let path = base#chomp_slash(path)
    if a:0 && a:1 && tolower(input("Vimik: Make new directory: ".path."\n [Y]es/[n]o? ")) !~ "y"
      return 0
    endif
    call mkdir(path, "p")
  endif
  return 1
endfunction " }}}

function! base#edit_file(command, filename, ...) "{{{
  " XXX: Should we allow * in filenames!?
  " Maxim: It is allowed, escaping here is for vim to be able to open files
  " which have that symbols.
  " Try to remove * from escaping and open&save :
  " [[testBLAfile]]...
  " then
  " [[test*file]]...
  " you'll have E77: Too many file names
  let fname = escape(a:filename, '% *|#')
  let dir = fnamemodify(a:filename, ":p:h")
  if base#mkdir(dir, 1)
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

function! base#subdir(path, filename) "{{{
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

function! base#get_wikifile_url(wikifile) "{{{
  return VimikGet('path_html') . base#subdir(VimikGet('path'), a:wikifile) . fnamemodify(a:wikifile, ":t:r") . '.html'
endfunction "}}}

function! base#update_conf() " {{{ Init page-specific variables
  let subdir = base#subdir(VimikGet('path'), expand('%:p'))
  call VimikSet('subdir', subdir)
  call VimikSet('url', base#get_wikifile_url(expand('%:p')))
endfunction " }}}

function! base#goto_index(...) "{{{
  if a:0
    let cmd = 'tabedit'
  else
    let cmd = 'edit'
  endif

  call base#edit_file(cmd, VimikGet('path') . VimikGet('index') . VimikGet('ext'))
  call base#update_conf()
endfunction "}}}
