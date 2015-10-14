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

command! -buffer VimikFollowLink call vimik#follow_link('nosplit')
command! -buffer VimikSplitLink  call vimik#follow_link('split')
command! -buffer VimikVSplitLink call vimik#follow_link('vsplit')
command! -buffer VimikTabnewLink call vimik#follow_link('tabnew')
command! -buffer VimikGoBackLink call vimik#go_back_link()

if !hasmapto('<Plug>VimikFollowLink')
	nmap <silent><buffer> <CR> <Plug>VimikFollowLink
endif
nnoremap <silent><script><buffer> <Plug>VimikFollowLink :VimikFollowLink<CR>

if !hasmapto('<Plug>VimikSplitLink')
	nmap <silent><buffer> <S-CR> <Plug>VimikSplitLink
endif
nnoremap <silent><script><buffer> <Plug>VimikSplitLink :VimikSplitLink<CR>

if !hasmapto('<Plug>VimikVSplitLink')
	nmap <silent><buffer> <C-CR> <Plug>VimikVSplitLink
endif
nnoremap <silent><script><buffer> <Plug>VimikVSplitLink :VimikVSplitLink<CR>

if !hasmapto('<Plug>VimikTabnewLink')
	nmap <silent><buffer> <D-CR> <Plug>VimikTabnewLink
	nmap <silent><buffer> <C-S-CR> <Plug>VimikTabnewLink
endif
nnoremap <silent><script><buffer> <Plug>VimikTabnewLink :VimikTabnewLink<CR>

if !hasmapto('<Plug>VimikGoBackLink')
	nmap <silent><buffer> <BS> <Plug>VimikGoBackLink
endif
nnoremap <silent><script><buffer> <Plug>VimikGoBackLink :VimikGoBackLink<CR>

command! -buffer Vimik2HTML call vimik#vmk2html(expand('%:p'))
command! -buffer Vimik2HTMLBrowse call vimik#system_open_link(vimik#vmk2html(expand('%:p')))
command! -buffer VimikAll2HTML call vimik#vmkALL2html()

if !hasmapto('<Plug>Vimik2HTML')
  nmap <buffer> <Leader>wh <Plug>Vimik2HTML
endif
nnoremap <script><buffer> <Plug>Vimik2HTML :Vimik2HTML<CR>

if !hasmapto('<Plug>Vimik2HTMLBrowse')
  nmap <buffer> <Leader>whh <Plug>Vimik2HTMLBrowse
endif
nnoremap <script><buffer> <Plug>Vimik2HTMLBrowse :Vimik2HTMLBrowse<CR>
