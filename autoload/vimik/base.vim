
function! s:normalize_path(path) "{{{
  return resolve(expand(substitute(a:path, '[/\\]\+$', '', ''))).'/'
endfunction "}}}

function! vimik#base#subdir(path, filename) "{{{
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

function! vimik#base#setup_buffer_state(idx) " {{{ Init page-specific variables
  " Only call this function *after* opening a wiki page.
  if a:idx < 0
    return
  endif

  " The following state depends on the current active wiki page
  let subdir = vimik#base#subdir(VimikGet('path'), expand('%:p'))
  call VimikSet('subdir', subdir)
  call VimikSet('url', vimik#html#get_wikifile_url(expand('%:p')))
endfunction " }}}

