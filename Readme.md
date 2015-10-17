# A vim plugin which is used to write markdown wiki.

Basically, this project is inspired by [vimwiki](https://github.com/vimwiki/vimwiki) and I reused plenty of codes from vimwiki.

## Installation
1. use [vundle](https://github.com/VundleVim/Vundle.vim) to install [vimik](https://github.com/xrfind/vimik)
2. cd **hoedown** directory, type `make`
3. done

## Configuration
In your vimrc, adding following three line:

1. `let g:vimik_conf= {}`
2. `let g:vimik_conf.path = '~/BLOG/'`
3. `let g:vimik_conf.path_html = '~/Sites/blog/'`
4. `let g:vimik_conf.hoedown = '--fenced-code --strikethrough --underline --highlight --superscript'`
	There are dozens of extensions which hoedown supports, you can add the options here to enable them.
5. `let g:vimik_conf.html_header = 'someplace/header.html'`
6. `let g:vimik_conf.html_footer = 'someplace/footer.html'`

## Key bindings

### open wiki
* `<Leader>ww` -- Open default wiki index file.
* `<Leader>k` -- Open default wiki index file in a new tab.

### move in wiki
* `<Tab>` -- Find next wiki link
* `<Shift-Tab>` -- Find last wiki link
* `<Enter>` -- Folow/Create wiki link
* `<Backspace>` -- Go back to parent(previous) wiki link
* `<Ctrl-l>` -- Split and folow/create wiki link
* `<Ctrl-v>` -- Vertical split and folow/create wiki link

### convert html
* `<Leader>wh` -- convert current file to html
* `<Leader>whh` -- convert current file to html and open the html in brower.

### push to yourname.github.io
* `<Leader>wp` -- git commit and push current wiki file and generated html file.
* `<Leader>wa` -- git commit and push all wiki and all generated html file.

### TODO
* TODO:`<Leader>wd` -- Delete wiki file you are in.
* TODO:`<Leader>wr` -- Rename wiki file you are in.

## Commands
* `:Vimwiki2HTML` -- Convert current wiki link to HTML
* `:VimwikiAll2HTML` -- Convert all your wiki links to HTML

## Syntax
Vimik use hoedown to analysis markdown document, and output html file.
By default, I only enable following extensions:

1. --fenced-code 
2. --strikethrough
3. --underline
4. --highlight
5. --superscript
6. --toc-level 1

But If you want the standard markdown, you can just write 

```vim
let g:vimik_conf.hoedown = ''
```
to your vimrc.	

Vimik use an additional syntax `[[wikilink]]` to implement the wiki link functionality.

## html template
The `%title%` is used to find the right place to insert the right title of the page.  
The text of the first header, I mean `<h1> <h2> ...`, will be used to set the title.  
For example, if the first header of the page is `<h1>hello world</h1>`, then the title of page 
is **hello world**.

The `%level%` is used to fix the right href attribute in `<a>` html tag. It should be put before 
each url.

I use bootstrap as the bacis html template, check the **html** directory.
