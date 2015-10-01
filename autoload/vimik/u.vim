function! vimik#u#chomp_slash(str) "{{{
	return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}
