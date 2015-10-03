function! vimik#u#chomp_slash(str) "{{{
	return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}

function! vimik#u#path_norm(path) "{{{
	" /-slashes
	let path = substitute(a:path, '\', '/', 'g')
	" treat multiple consecutive slashes as one path separator
	let path = substitute(path, '/\+', '/', 'g')
	" ensure that we are not fooled by a symbolic link
	return resolve(path)
endfunction "}}}

function! vimik#u#path_common_pfx(path1, path2) "{{{
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
