
function! vimik#html#get_wikifile_url(wikifile) "{{{
  return VimikGet('path_html').
    \ vimik#base#subdir(VimikGet('path'), a:wikifile).
    \ fnamemodify(a:wikifile, ":t:r").'.html'
endfunction "}}}
