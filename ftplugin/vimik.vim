if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1  " Don't load another plugin for this buffer

" UNDO list {{{
" Reset the following options to undo this plugin.
let b:undo_ftplugin = "setlocal ".
      \ "suffixesadd< isfname< comments< ".
      \ "formatoptions< foldtext< ".
      \ "foldmethod< foldexpr< commentstring< "
" UNDO }}}

command! -buffer Vimwiki2HTML
      \ silent w <bar> 
      \ let res = vimwiki#html#Wiki2HTML(expand(VimwikiGet('path_html')),
      \                             expand('%'))
      \<bar>
      \ if res != '' | echo 'Vimwiki: HTML conversion is done.' | endif
