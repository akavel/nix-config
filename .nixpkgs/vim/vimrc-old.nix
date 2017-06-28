/*
" Simple TODO lists; flaky folding, unfortunately
" TODO: improve workflowish
Plugin 'lukaszkorecki/workflowish'
" Python code completion, docs & related
Plugin 'davidhalter/jedi-vim'
" List buffers on top as if they were "tabs"
"Plugin 'fholgado/minibufexpl.vim'
Plugin 'godlygeek/tabular'
Plugin 'Lokaltog/vim-easymotion'
" Visualize the undo tree
Plugin 'sjl/gundo.vim'
" Filesystem explorer
" Plugin 'scrooloose/nerdtree'
" Auto-reloading of edited plugin files (for plugins development) + 1
" dependency (vim-misc)
 Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-reload'
"Plugin 'suan/vim-instant-markdown'
" Personal test plugin
Plugin '~/.vim/bundle/notepoints/.git'
" TODO: Plugin 'tpope/vim-sleuth' ?
" TODO: or: Plugin 'ciaranm/detectindent' ?
" TODO: Plugin 'scrooloose/syntastic' ?
" TODO: Plugin 'bling/vim-airline' ?
" TODO: Plugin 'tpope/vim-obsession' ?
" TODO: Plugin 'tpope/vim-jdaddy' ?
" TODO: http://spf13.com/project/spf13-vim/
" TODO: https://github.com/mbrochh/vim-as-a-python-ide/blob/master/.vimrc
" TODO: http://vimcasts.org/blog/2014/02/follow-my-leader/
" TODO: https://github.com/tpope/vim-sensible
" TODO: http://items.sjbach.com/319/configuring-vim-right
" TODO: https://github.com/sheerun/dotfiles
" TODO: https://github.com/fatih/dotfiles/blob/master/vimrc
" alt.to above: "tabbar.vim" http://www.vim.org/scripts/script.php?script_id=1338
*/
[

  # Csearch is a fast alternative to grep, but requires pre-indexing.
  # TODO(akavel): Plugin 'brandonbloom/csearch.vim'

  # Show an outline of current source file in a split.
  # TODO(akavel): tagbar requires 'exuberant ctags'
  # TODO(akavel): Plugin 'majutsushi/tagbar'
  # " tagbar
  # nmap <F8> :TagbarToggle<CR>
  # let g:tagbar_sort = 0
  # let g:tagbar_compact = 1
  # let g:tagbar_show_linenumbers = 1
  # " auto-open TagBar. (See :help tagbar for alternatives.)
  # "autocmd VimEnter * nested :TagbarOpen

  # Other .vimrc settings, not plugin-related
  { config = ''
" indentation settings
set expandtab           " replace TABs with spaces
set autoindent

" display more info on status line
set showmode            " show mode in status bar (insert/replace/...)
set titlestring=%{hostname()}::\ \ %t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ \-\ VIM
let &titleold=hostname()
set title               " show file in titlebar

" Show tabs and trailing whitespace visually
set list
set listchars=
set listchars+=tab:¸·
set listchars+=trail:×
" helpful options for :set nowrap
set listchars+=precedes:«
set listchars+=extends:»
set sidescroll=5

" In command-line, use similar navigation keys like in bash/readline
" http://stackoverflow.com/a/6923282/98528
" Note: <C-f> switches to "full editing" of commandline, <C-c> back
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>

" Enable code folding in Go (and others)
" http://0value.com/my-Go-centric-Vim-setup
" Note:
" zM - close all
" zR - open all
" zc - close current fold
" zo - open current fold
set foldmethod=syntax
"set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=10

" Neosnippet
let g:neosnippet#disable_runtime_snippets = {'_': 1}
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory = '~/.vim/snippets'
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" modeline: allows settings tweaking per edited file, by special magic comment
" starting with 'vim:'
set modeline

" Extending the % ("go to pair") key
runtime macros/matchit.vim

" when splitting window (with C-W,v or C-W,s), open to right/bottom
set splitright
set splitbelow

" This trigger takes advantage of the fact that the quickfix window can be
" easily distinguished by its file-type, qf. The wincmd J command is
" equivalent to the Ctrl+W, Shift+J shortcut telling Vim to move a window to
" the very bottom (see :help :wincmd and :help ^WJ).
autocmd FileType qf wincmd J

" Replace the current buffer with the given new file. That means a new file
" will be open in a buffer while the old one will be deleted
com! -nargs=1 -complete=file Breplace edit <args>| bdelete #

" *.md is for Markdown, not Modula (sorry!)
" http://stackoverflow.com/a/14779012/98528 etc.
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

" Deoplete (auto-completion)
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#enable_auto_select = 1

set grepprg=git\ grep\ -n
 ''; }
]

/* TODO: vim plugins & config:
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2014 Feb 05
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
" if has('mouse')
"   set mouse=a
" endif
" Nope, I don't want clicking the mouse to enter visual mode:
set mouse-=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" autoindent etc
set cindent
set smartindent
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4

if &diff
  " options for vimdiff
  " with syntax highlighting, colors are often unreadable in vimdiff
  syntax off
  " ignore whitespace
  set diffopt+=iwhite
else
  " options for regular vim, non-vimdiff
  syntax on
endif

"" <Space> will allow to insert single character
"function! RepeatChar(char, count)
"  return repeat(a:char, a:count)
"endfunction
"nnoremap <Space> :<C-U>exec "normal i".RepeatChar(nr2char(getchar()), v:count1)<CR>

"" ctags
"set tag=tags,./tags,../tags,../../tags,../../../tags,../../../../tags,../../../../../tags,../../../../../../tags,../../../../../../../tags,../../../../../../../../tags,../../../../../../../../../tags,../../../../../../../../../../tags,../../../../../../../../../../../tags,../../../../../../../../../../../../tags,../../../../../../../../../../../../../tags,../../../../../../../../../../../../../../tags,../../../../../../../../../../../../../../../tags,../../../../../../../../../../../../../../../../tags,../../../../../../../../../../../../../../../../../tags,../../../../../../../../../../../../../../../../../../tags
"" FIXME: below conflicts with helpfiles "follow link"
"nmap <C-]> :tj <C-r><C-w><CR>

"" extended colours
""if &term =~ "xterm"
""  "256 color --
""  let &t_Co=256
""  " restore screen after quitting
""  set t_ti=ESC7ESC[rESC[?47h t_te=ESC[?47lESC8
""  if has("terminfo")
""    let &t_Sf="\ESC[3%p1%dm"
""    let &t_Sb="\ESC[4%p1%dm"
""  else
""    let &t_Sf="\ESC[3%dm"
""    let &t_Sb="\ESC[4%dm"
""  endif
""endif
"let &t_Co=256

" bash-like (or, readline-like) tab completion of paths, case insensitive
set wildmode=longest,list,full
set wildmenu
if exists("&wildignorecase")
  set wildignorecase
endif

" disable ZZ (like :wq) to avoid it when doing zz with caps-lock on
nnoremap ZZ <Nop>

" paste mode toggle (needed when using autoindent/smartindent)
map <F10> :set paste<CR>
map <F11> :set nopaste<CR>
imap <F10> <C-O>:set paste<CR>
imap <F11> <nop>
set pastetoggle=<F11>

" folding: create foldpoints, but unfold by default
set foldlevel=99
augroup vimrc
  " from: http://vim.wikia.com/wiki/Folding
  " create folds based on indent...
  au BufReadPre * setlocal foldmethod=indent
  " ...but allow manual folds too
  au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
augroup END

"" a.vim: alternate between .h and .C with ':A'
"source ~/.vim/autoload/a.vim
"let g:alternateExtensions_C = "h"
"let g:alternateExtensions_h = "C"

" double backspace -> wrap all windows
"nmap <BS>     :set wrap!<CR>
nmap <BS><BS> :windo set wrap!<CR>

"execute pathogen#infect()

" Auto-completion for Go import paths
function! SystemFirstLine(cmd)
    " Take only the first line from a command's output
    return split(system(a:cmd), "\n")[0]
endfunction
function! AkavelListGoImports()
    " Note: http://stackoverflow.com/a/6146663/98528
    "   and :help feature-list
    if has('win32') || has('win64') || has('win16') || has('win32unix')
        let pathsep = ';'
    else
        let pathsep = ':'
    endif
    let gopath = SystemFirstLine('go env GOPATH')
    let goroot = SystemFirstLine('go env GOROOT')
    let goos = SystemFirstLine('go env GOOS')
    let goarch = SystemFirstLine('go env GOARCH')
    let goosarch = goos . '_' . goarch

    let paths = split(gopath, pathsep) + [goroot]
    let allpkgs = []
    for path in paths
        let pkgs = split(globpath(path, 'pkg/' . goosarch . '/**/*.a'), "\n")
        " FIXME(akavel): make sure path doesn't end with / or \
        let prefixlen = len(path . '/pkg/' . goosarch . '/')
        " TODO(akavel): filter out any *_test.go pkgs (if present?) maybe via 'wildignore'?
        " Drop path prefix (e.g. 'c:/go/pkg/windows_amd64/') and '.a' suffix
        let pkgs = map(pkgs, 'v:val[' . prefixlen . ':-3]')
        " Windows uses \ in paths, but Go needs /
        let pkgs = map(pkgs, 'substitute(v:val, "\\", "/", "g")')
        let allpkgs = allpkgs + pkgs
    endfor
    return allpkgs
endfunction
function! AkavelGoImportsComplete(findstart, base)
    if a:findstart == 1  " can we do some completion?
        let g:go_complete_imports = 0
        let column = col('.')
        let line = getline('.')[:column]
        let quote_pos = match(line, '\v"[a-zA-Z._/-]*$')
        if quote_pos != -1
            let g:go_complete_imports = 1
            return quote_pos + 1
        endif
    else " build list of possible completions
        if g:go_complete_imports
            let allpkgs = AkavelListGoImports()
            let pkgs = []
            let n = len(a:base)-1
            for path in allpkgs
                if path[:n] ==? a:base
                    call add(pkgs, path)
                endif
            endfor
            return pkgs
        endif
    endif
    return go#complete#Complete(a:findstart, a:base)
endfunction
augroup akavel_go
    autocmd!
    autocmd FileType go setlocal omnifunc=AkavelGoImportsComplete
    " Remove some unexplicable ignore patterns originating from otherwise
    " awesome vim-go plugin:
    " - ignoring comment-like lines - regexp: '# .*'
    autocmd FileType go setlocal errorformat-=%-G#\ %.%#
    " - ignoring panics (why the hell? :/)
    autocmd FileType go setlocal errorformat-=%-G%.%#panic:\ %m
    " - ignoring empty lines
    autocmd FileType go setlocal errorformat-=%-G%.%#
    " TODO(akavel): wtf is the pattern below?
    autocmd FileType go setlocal errorformat-=%C%*\\\s%m

    " Add patterns for various Go output formats. (Esp. stacktraces in panics
    " and data race reports.)
    " autocmd FileType go setlocal errorformat+=%A%>%m:,%Z\\\ \\\ \\\ \\\ \\\ %f:%l\\\ +%.%#,%+C\\\ \\\ %m,%A\\\ \\\ %m
    " MATCH:      /path/to/some/file.go:32 +0x23c2
    autocmd FileType go setlocal errorformat+=%Z\\\ \\\ %#%f:%l\\\ +%.%#
    " autocmd FileType go setlocal errorformat+=%A%>%m:
    autocmd FileType go setlocal errorformat+=%+A%>panic:\\\ %.%#
    " autocmd FileType go setlocal errorformat+=%Z\\\ \\\ \\\ \\\ \\\ %f:%l\\\ +%.%#
    " autocmd FileType go setlocal errorformat+=%+C\\\ \\\ %m
    " autocmd FileType go setlocal errorformat+=%A\\\ \\\ %m
    " MATCH: goroutine 123 [some status]:
    " autocmd FileType go setlocal errorformat+=%+A%>goroutine\\\ %[0-9]%[0-9]%#\\\ [%.%#]:
    autocmd FileType go setlocal errorformat+=%+Agoroutine\\\ %.%#
    " MATCH: created by gopackage.goFuncName
    autocmd FileType go setlocal errorformat+=%+Acreated\\\ by\\\ %[a-z]%.%#.%.%#
    " MATCH: path/to/go/package.funcName(0xf00, 0xba4)
    " MATCH: path/to/go/package.(*object).funcName(0xf00, 0xba4, ...)
    autocmd FileType go setlocal errorformat+=%+A\\\ %#%[a-z]%.%#.%.%#(%[0-9a-fx\\\,\\\ %.]%#)

    "autocmd FileType go let &colorcolumn="80,".join(range(120,299),",")
    autocmd FileType go let &colorcolumn="80,120"
    autocmd FileType go highlight ColorColumn ctermbg=darkgray guibg=#f8f8f8
augroup END

" " save fold levels of a file between sessions
" " Source 1: http://stackoverflow.com/a/9885721/98528
" " TODO: http://vim.wikia.com/wiki/Make_views_automatic
" " TODO: mkview only if non-default folds in a file
" if !isdirectory(expand(&viewdir))
"     call mkdir(expand(&viewdir), "p", 451)
" endif
" autocmd BufWrite * mkview
" autocmd BufNewFile,BufRead * silent loadview

" Jedi-vim tweaks
let g:jedi#use_tabs_not_buffers = 0
" maybe; maybe = "winwidth" ?
let g:jedi#use_splits_not_buffers = "right"
" Setup for jedi compatibility with neocomplete
autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.python =
\ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
" alternative pattern: '\h\w*\|[^. \t]\.\w*'

" Gundo (visualize the undo tree)
nnoremap <F5> :GundoToggle<CR>

" NERDTree
map <C-n> :NERDTreeToggle<CR>

" Use <Space> as the special "leader" key (extended commands)
let mapleader = "\<Space>"
" or? let mapleader = " "
" is below needed?
nnoremap <Space> <nop>

" vim-choosewin
nmap - <Plug>(choosewin)
" let g:choosewin_overlay_enable = 1
let g:choosewin_overlay_enable = 0

" Helper for loading Go language panics and data race reports into quickfix window
" set errorformat+=%A%>%m:,%Z\\\ \\\ \\\ \\\ \\\ %f:%l\\\ +%.%#,%+C\\\ \\\ %m,%A\\\ \\\ %m

*/
