# A vim plugin which is used to write markdown wiki.

Basically, this project is inspired by [vimwiki](https://github.com/vimwiki/vimwiki) and I reused plenty of codes from vimwiki.

## Installation
1. use [vundle](https://github.com/VundleVim/Vundle.vim) to install [vimik](https://github.com/xrfind/vimik)
2. cd **hoedown** directory, type `make`
3. done

## Configuration
In your vimrc, adding following three line:
1. let g:vimik_conf= {}
2. let g:vimik_conf.path = '~/BLOG/'
3. let g:vimik_conf.path_html = '~/Sites/blog/'

## Key bindings
normal mode:
* `<Leader>ww` -- Open default wiki index file.
* `<Leader>wt` -- Open default wiki index file in a new tab.
* `<Enter>` -- Folow/Create wiki link
* `<Backspace>` -- Go back to parent(previous) wiki link
* `<Leader>wh` -- convert current file to html
* TODO:`<Leader>wd` -- Delete wiki file you are in.
* TODO:`<Leader>wr` -- Rename wiki file you are in.
* TODO:`<Shift-Enter>` -- Split and folow/create wiki link
* TODO:`<Ctrl-Enter>` -- Vertical split and folow/create wiki link
* TODO:`<Tab>` -- Find next wiki link
* TODO:`<Shift-Tab>` -- Find previous wiki link

## Commands
* Vimwiki2HTML -- Convert current wiki link to HTML
* VimwikiAll2HTML -- Convert all your wiki links to HTML

## Syntax
Vimik use hoedown to anlysis markdown document, and output html file.
By default, I only enable the standard syntax of markdown.
But If you want, you can set options in your vimrc.

Vimik use an additional syntax `[[wikilink]]` to implement the wiki link functionality.
