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
          vimrcConfig = myVimrc;
        };
        # Vamos is my custom helper for managing Vim plugins & .vimrc
        vamos = callPackage ./vim/lib-vamos.nix {};
        # Note: see <nixpkgs>/pkgs/misc/vim-plugins/default.nix for names to use with fromVam
        myVimrc = vamos [
          { fromGitHub="garyburd/go-explorer";
            rev = "c22eec647bca26f61578d27a152141374cbe2854";
            sha256 = "1rpj8y0jdpa8qpkk4hvxjfk16lk6j2b89y6bh4fdkmw3kbd1gz40"; }
          # Go language support for vim
          { fromVam="vim-go";
            config = ''
              " - use goimports on save
              let g:go_fmt_command = "goimports"
              " - highlight identifier under cursor
              "let g:go_auto_sameids = 1     " doesn't seem to work; also disabled trying to speed-up editing lag
              "let g:go_auto_type_info = 1   " not tested yet
              let g:go_highlight_build_constraints = 1
              let go_guru_scope = [
                          \ "zpaslab.com/lockerbox/agent/agent",
                          \ "zpaslab.com/lockerbox/overmind/overmind",
                          \ "zpaslab.com/lockerbox/testing/load_test/load_test_client",
                          \ "zpaslab.com/lockerbox/lockerbox/api_key_generator",
                          \ ]
            '';}
          # Smart and quick file opening with Ctrl-P, by fuzzy path match, like in SublimeText
          { fromVam="ctrlp";
            config=''
              let g:ctrlp_extensions = ['mixed', 'line', 'buffertag', 'tag']
              let g:ctrlp_custom_ignore = '\v\.pyc''$'
            ''; }
          # Ack is a better featured alternative to grep.
          { fromVam="ack-vim"; }
          # TODO(akavel): Attempt at multiple cursors like in SublimeText.
          #               'terryma/vim-multiple-cursors' is fairly limited, try some alternative.
          # Code snippets for vim.
          { fromVam="snipmate"; }
          # TODO(akavel): try using fromVam="neocomplete";
          { fromGitHub="Shougo/neocomplete";
            rev = "7b2b1cf5ba60cf17f8d8c3535c21a51b32c1a52b";
            sha256 = "1f1qzk9wicxdpz1w4dlc99zlbq2slkva94ajajsb49m7vnyhh0wd";
            config = ''
              let g:neocomplete#data_directory = "/tmp/neocomplete-swap"
              " Use neocomplete.
              let g:neocomplete#enable_at_startup = 1
              " Enable heavy omni completion.
              if !exists('g:neocomplete#sources#omni#input_patterns')
                  let g:neocomplete#sources#omni#input_patterns = {}
              endif
              " golang fix
              let g:neocomplete#sources#omni#input_patterns.go = '[^.[:digit:] *\t]\.\w*'
              let g:neocomplete#enable_ignore_case = 1
              let g:neocomplete#enable_smart_case = 1
              let g:neocomplete#enable_auto_select = 1
            ''; }
          { fromGitHub="Shougo/echodoc.vim";
            rev = "ef0a0cbe6c4cdb60eb2a1cbcee5bde11ce2c6dce";
            sha256 = "0vdfjyprnn59brkf0vnyq9ksh03labwyq4vyvsihs4zhing2jbwy"; 
            config = ''
              let g:echodoc_enable_at_startup = 1
              set cmdheight=2
            ''; }
          # TODO(akavel): find out which snippets plugin I'm actually using
          # FIXME(akavel): fix the snippets directory to be configured via Nix
          { fromVam="neosnippet";
            config = ''
              let g:neosnippet#disable_runtime_snippets = {'_': 1}
              let g:neosnippet#enable_snipmate_compatibility = 1
              let g:neosnippet#snippets_directory = '~/.vim/snippets'
              imap <C-k>     <Plug>(neosnippet_expand_or_jump)
              smap <C-k>     <Plug>(neosnippet_expand_or_jump)
              xmap <C-k>     <Plug>(neosnippet_expand_target)
            ''; }
          # Git
          { fromVam="fugitive"; }
          { fromGitHub="tpope/vim-unimpaired";
            rev = "3548479cc154154cbdbb6737ca08a47937cc7113";
            sha256 = "0p2siip5xf20mg4z1z3m4mp90m026ww3cnkk1n9rc02xhp5xvpsg"; }
          { fromVam="surround"; }
          { fromVam="commentary"; }
          { fromVam="supertab"; }
          { fromVam="vim-repeat"; }
          # Increase/decrease selection with +/_
          { fromVam="vim-expand-region"; }
          # Choose window (split) by number
          { fromGitHub="t9md/vim-choosewin";
            rev = "3e3ab81364ab1f772538c0250c0965f35f986e20";
            sha256 = "00qakw7701lxmc7nvqf9c7inp7nld21491bvcm4s93z7f5l048vx"; 
            config = ''
              nmap - <Plug>(choosewin)
              " let g:choosewin_overlay_enable = 1
              let g:choosewin_overlay_enable = 0
            ''; }
          { fromGitHub="AndrewRadev/splitjoin.vim";
            rev = "20868936ea2af5f8a929b0924db65f8a27035a89";
            sha256 = "0fxsksv25waxaszl81za6qkfiakr4zm63lib5ryvks5d3xvf3697"; }
          # Auto-reloading of edited plugin files (for plugins development) + 1
          # dependency (vim-misc)
          { fromGitHub="xolox/vim-misc";
            rev = "9b38b8f86aa6a31e189e2a9020b5f0f926495a6b";
            sha256 = "0rnxvdcq3fawwc72j2cirv2svfw2mg25payhaf122cb4firh6ag0"; }
          { fromGitHub="xolox/vim-reload";
            rev = "0a601a668727f5b675cb1ddc19f6861f3f7ab9e1";
            sha256 = "0vb832l9yxj919f5hfg6qj6bn9ni57gnjd3bj7zpq7d4iv2s4wdh"; }
          # Highlighting of ANSI escape-coded colours
          { fromGitHub="powerman/vim-plugin-AnsiEsc";
            rev = "1ffd1371ba19e5e287ce9e1a689ca974dc02f2b5";
            sha256 = "1i1fcan27109iq9p9jmhzx6i68dj524f688d7zv3g7yk94ygabj2"; }
          # DrawIt (ASCII-Art plugin)
          { fromGitHub="vim-scripts/DrawIt";
            rev = "4e824fc939cec81dc2a8f4d91aaeb6151d1cc140";
            sha256 = "0yn985pj8dn0bzalwfc8ssx62m01307ic1ypymil311m4gzlfy60";
            config = ''
              " Custom key mappings.
              " dia - "DIAgrams"
              nmap dia <Plug>DrawItStart
              " dio - "DIagrams Off"
              nmap dio <Plug>DrawItStop
            ''; }
          # Show changed lines on gutter ("signs") with :EC (disable with :DC) + navigate with ]h [h
          { fromGitHub="chrisbra/changesPlugin";
            rev = "bfdc9c2e66313ae3dda019f0a8e6cc2e680e3fd6";
            sha256 = "1hhhkdy18bnkrsi4rnwzcv88mcz63k4jbxxr3j8p9z9jzqdadrx9";
            config = ''
              "  :EC enables, :DC disables
              "  ]h [h next/previous hunk
              " Allow fetching info from git etc.:
              let g:changes_vcs_check=1
            ''; }
          # Move through words in CamelCase and snake_case words (keys configured below)
          { fromGitHub="bkad/CamelCaseMotion";
            rev = "3ae9bf93cce28ddc1f2776999ad516e153769ea4";
            sha256 = "086q1n0d8xaa0nxvwxlhpwi1hbdz86iaskbl639z788z0ysh4dxw";
            config = ''
              " - use Alt+<motion> to move within word - <A-w> right, <A-b> left
              " - plus additional: <Alt-f> = <Alt-w>, similar as in bash
              map <silent> <Esc>w <Plug>CamelCaseMotion_w
              "map <silent> <Esc>f <Plug>CamelCaseMotion_f   " this doesn't seem to work; don't know why
              map <silent> <Esc>b <Plug>CamelCaseMotion_b
              map <silent> <Esc>e <Plug>CamelCaseMotion_e
              "TODO: map <silent> <Alt-g>e <Plug>CamelCaseMotion_ge
              omap <silent> <Esc>iw <Plug>CamelCaseMotion_iw
              xmap <silent> <Esc>iw <Plug>CamelCaseMotion_iw
              omap <silent> <Esc>if <Plug>CamelCaseMotion_iw
              xmap <silent> <Esc>if <Plug>CamelCaseMotion_iw
              omap <silent> <Esc>ib <Plug>CamelCaseMotion_ib
              xmap <silent> <Esc>ib <Plug>CamelCaseMotion_ib
              omap <silent> <Esc>ie <Plug>CamelCaseMotion_ie
              xmap <silent> <Esc>ie <Plug>CamelCaseMotion_ie
            ''; }
          # Coerce word to:
          #  crc - camelCase
          #  crm - MixedCase
          #  crs - snake_case
          #  cru - UPPER_CASE
          # Also, replace all case variations of word in file, e.g.:
          #  :%Subvert/facilit{y,ies}/building{,s}/g
          # will replace Facility, FACILITIES, etc, with Building, BUILDINGS, etc.
          { fromGitHub="tpope/vim-abolish";
            rev = "05c7d31f6b3066582017edf5198502a94f6a7cb5";
            sha256 = "1p7kcd3f5rbkqrj8ya7z0fimiyk5h5ybkn26qq10xxfrvlv9x69h"; }
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
