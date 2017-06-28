{pkgs, ...}:
{
  packageOverrides = defaultPkgs: with defaultPkgs; {
    # Declarative user profile/config. Install/update with `nix-env -i home`.
    home = with pkgs; buildEnv {
      name = "home";
      paths = [
        nix-home  # see below
        #neovim    # see below
        xim       # see below
      ];
    };

    # nix-home tool - for managing $HOME via Nix (wrapper for nix-env)
    nix-home = callPackage ./nix-home {
      files = {
        # bash: case-insensitive TAB-completion
        ".inputrc" = "set completion-ignore-case On";
        "sample-home-test" = "sample-test";
        # ack: nice navigation if many results; keep colors enabled
        ".ackrc" = "--pager=less -R";
      };
    };

    # NeoVim editor + customized config
    #neovim = let
      #neovim = vimUtils.vimWithRC {
      #in neovim;

    # Vim with customizations, named "xim" for testing
    # TODO(akavel): disable python in vim, maybe
    xim =
      let
        theXim = vimConfigured;
        # Vim in Nix uses some ancient customization methods, which result in
        # super ugly customization usage. I can't figure out e.g. how to
        # disable support for Python, but keep Lua enabled.
        vimConfigured = defaultPkgs.vim_configurable.customize {
          name = "xim";
          vimrcConfig = vamos (commonVimrc ++ linuxVimrc ++ myVimrc);
        };
        # Vamos is my custom helper for managing Vim plugins & .vimrc
        vamos = callPackage ./vim/lib-vamos.nix {};
        commonVimrc = import ./vim/vimrc-common.nix;
        linuxVimrc = import ./vim/vimrc-linux.nix;
        # Note: see <nixpkgs>/pkgs/misc/vim-plugins/default.nix for names to use with fromVam
        myVimrc = [
          # Other .vimrc settings, not plugin-related
          # Some of them copied from some basic .vimrc (?)
          { config = ''
              " allow backspacing over everything in insert mode
              set backspace=indent,eol,start

              " some undo/backup settings
              if has("vms")
                set nobackup		" do not keep a backup file, use versions instead
              else
                set backup		" keep a backup file (restore to previous version)
                set undofile		" keep an undo file (undo changes after closing)
                " don't litter current dir with backups, but still try to put them
                " somewhere; double slash // at the end stores filenames with path
                set backupdir-=.
                set backupdir^=~/tmp//,/tmp//
                set undodir-=.
                set undodir^=~/tmp//,/tmp//
              endif
              set history=50		" keep 50 lines of command line history
              set ruler		" show the cursor position all the time
              set showcmd		" display incomplete commands
              set incsearch		" do incremental searching

              " Don't use Ex mode, use Q for formatting
              map Q gq

              " CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
              " so that you can undo CTRL-U after inserting a line break.
              inoremap <C-U> <C-G>u<C-U>

              " Switch syntax highlighting on, when the terminal has colors
              " Also switch on highlighting the last used search pattern.
              if &t_Co > 2 || has("gui_running")
                syntax on
                set hlsearch
              endif

              " Only do this part when compiled with support for autocommands.
              if has("autocmd")
                " Enable file type detection.
                " Use the default filetype settings, so that mail gets 'tw' set to 72,
                " 'cindent' is on in C files, etc.
                " Also load indent files, to automatically do language-dependent indenting.
                filetype plugin indent on

                " Put these in an autocmd group, so that we can delete them easily.
                augroup vimrcEx
                au!

                " For all text files set 'textwidth' to 78 characters.
                autocmd FileType text setlocal textwidth=78

                " When editing a file, always jump to the last known cursor position.
                " Don't do it when the position is invalid or when inside an event handler
                " (happens when dropping a file on gvim).
                " Also don't do it when the mark is in the first line, that is the default
                " position when opening a file.
                autocmd BufReadPost *
                  \ if line("'\"") > 1 && line("'\"") <= line("$") |
                  \   exe "normal! g`\"" |
                  \ endif
                augroup END
              else
                set autoindent		" always set autoindenting on
              endif " has("autocmd")

              " Convenient command to see the difference between the current buffer and the
              " file it was loaded from, thus the changes you made.
              " Only define it when not defined already.
              if !exists(":DiffOrig")
                command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                    \ | wincmd p | diffthis
              endif

              " display more info on status line
              set showmode            " show mode in status bar (insert/replace/...)
              set showcmd             " show typed command in status bar
              set ruler               " show cursor position in status bar
              set titlestring=%{hostname()}::\ \ %t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ \-\ VIM
              let &titleold=hostname()
              set title               " show file in titlebar
              if &term == "screen"    " for tmux, http://superuser.com/a/279214/12184
                set t_ts=ESCk
                set t_fs=ESC\
                set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)
              endif
            ''; }
          # Some more settings, those I'm pretty sure are mine, or at least I tweaked them
          { config = ''
              " I don't want clicking the mouse to enter visual mode:
              set mouse-=a

              " autoindent etc
              set cindent
              set smartindent
              set autoindent
              set expandtab
              set tabstop=4
              set shiftwidth=4

              " vimdiff vs. non-vimdiff
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

              " searching: highlight, incremental
              set hlsearch
              set incsearch

              " bash-like (or, readline-like) tab completion of paths, case insensitive
              set wildmode=longest,list,full
              set wildmenu
              if exists("&wildignorecase")
                set wildignorecase
              endif

              " disable ZZ (like :wq) to avoid it when doing zz with caps-lock on
              nnoremap ZZ <Nop>

              " Show tabs and trailing whitespace visually
              set list
              set listchars=
              set listchars+=tab:¸·
              set listchars+=trail:×
              " helpful options for :set nowrap
              set listchars+=precedes:«
              set listchars+=extends:»
              set sidescroll=5

              " folding: create foldpoints, but unfold by default
              set foldlevel=99
              augroup vimrc
                " from: http://vim.wikia.com/wiki/Folding
                " create folds based on indent...
                au BufReadPre * setlocal foldmethod=indent
                " ...but allow manual folds too
                au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
              augroup END

              " double backspace -> wrap all windows
              "nmap <BS>     :set wrap!<CR>
              nmap <BS><BS> :windo set wrap!<CR>

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

              augroup akavel_go
                  autocmd!
                  "autocmd FileType go setlocal omnifunc=AkavelGoImportsComplete
                  autocmd FileType go nmap <buffer> <silent> gD <Plug>(go-def-vertical)
                  " vim-go:
                  " `:A`  -- goes to $(FILE)_test.go and back
                  " `:A!` -- above, even if target doesn't exist
                  " `:AV` etc. -- as :A but in vertical split
                  autocmd FileType go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
                  autocmd FileType go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
                  autocmd FileType go command! -bang AS call go#alternate#Switch(<bang>0, 'split')

                  " Remove some unexplicable ignore patterns originating from otherwise
                  " awesome vim-go plugin:
                  " - ignoring comment-like lines - regexp: '# .*'
                  autocmd FileType go setlocal errorformat-=%-G#\ %.%#
                  " - ignoring panics (why the hell? :/)
                  autocmd FileType go setlocal errorformat-=%-G%.%#panic:\ %m
                  " - ignoring empty lines
                  autocmd FileType go setlocal errorformat-=%-G%.%#
                  " TODO(mateuszc): wtf is the pattern below?
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

                  autocmd FileType go setlocal foldmethod=syntax
                  autocmd FileType go setlocal foldlevelstart=99
                  " NOTE(akavel): alternatively, try 'zR' instead of foldlevelstart above?
              augroup END

              " Use tabs in .proto files
              augroup akavel_proto
                  autocmd!
                  autocmd FileType proto setlocal expandtab
              augroup end

              " Fix reflow of text (gq) when editing git commit messages
              augroup akavel_git
                  autocmd!
                  autocmd FileType gitcommit setlocal nocindent
              augroup end

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

              " *.md is for Markdown, not Modula (sorry!)
              " http://stackoverflow.com/a/14779012/98528 etc.
              au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

              " For *.plant files, use filetype "conf"
              au BufNewFile,BufFilePre,BufRead *.plant set filetype=conf

              " Improved alternatives to :bufdo, :windo, :tabdo (go back to current view
              " after finished).
              " Source: http://vim.wikia.com/wiki/Run_a_command_in_multiple_buffers
              "
              " Like windo but restore the current window.
              " Like windo but restore the current window.
              function! WinDo(command)
                let curwin=winnr()
                let altwin=winnr('#')
                execute 'windo ' . a:command
                execute altwin . 'wincmd w'
                execute curwin . 'wincmd w'
              endfunction
              com! -nargs=+ -complete=command Windo call WinDo(<q-args>)
              " Like bufdo but restore the current buffer.
              function! BufDo(command)
                let curbuf=bufnr("%")
                let altbuf=bufnr("#")
                execute 'bufdo ' . a:command
                execute 'buffer ' . altbuf
                execute 'buffer ' . curbuf
              endfunction
              com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)
              " Like tabdo but restore the current tab.
              function! TabDo(command)
                let currTab=tabpagenr()
                execute 'tabdo ' . a:command
                execute 'tabn ' . currTab
              endfunction
              com! -nargs=+ -complete=command Tabdo call TabDo(<q-args>)

              " Set 'git grep' as default command for :grep
              " This is much faster and more featureful when available. And I'm using it
              " mostly only when it's indeed available. If I were to use normal grep, I'd
              " anyway by default go for :cex system('grep ...')
              set grepprg=git\ grep\ -n
            ''; }
        ];
      in theXim;

  };
}
