[
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
    # note(akavel): let's help nix syntax plugin for vim find peace: ''$
  # Ack is a better featured alternative to grep.
  { fromVam="ack-vim"; }
  # TODO(akavel): Attempt at multiple cursors like in SublimeText.
  #               'terryma/vim-multiple-cursors' is fairly limited, try some alternative.
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
  { fromVam="supertab";
    config = ''
      " TODO(akavel): below was in Windows _vimrc; do we want this?
      " use omni-completion by default
      let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
    ''; }
  { fromGitHub="tpope/vim-unimpaired";
    rev = "3548479cc154154cbdbb6737ca08a47937cc7113";
    sha256 = "0p2siip5xf20mg4z1z3m4mp90m026ww3cnkk1n9rc02xhp5xvpsg"; }
  { fromVam="surround"; }
  { fromVam="commentary"; }
  # Choose window (split) by number
  { fromGitHub="t9md/vim-choosewin";
    rev = "3e3ab81364ab1f772538c0250c0965f35f986e20";
    sha256 = "00qakw7701lxmc7nvqf9c7inp7nld21491bvcm4s93z7f5l048vx"; 
    config = ''
      nmap - <Plug>(choosewin)
      " let g:choosewin_overlay_enable = 1  " TODO(akavel): enable on Windows
      let g:choosewin_overlay_enable = 0
    ''; }
  # Auto-reloading of edited plugin files (for plugins development) + 1
  # dependency (vim-misc)
  { fromGitHub="xolox/vim-misc";
    rev = "9b38b8f86aa6a31e189e2a9020b5f0f926495a6b";
    sha256 = "0rnxvdcq3fawwc72j2cirv2svfw2mg25payhaf122cb4firh6ag0"; }
  { fromGitHub="xolox/vim-reload";
    rev = "0a601a668727f5b675cb1ddc19f6861f3f7ab9e1";
    sha256 = "0vb832l9yxj919f5hfg6qj6bn9ni57gnjd3bj7zpq7d4iv2s4wdh"; }
  # Other .vimrc settings, not plugin-related
  # Some of them copied from some basic .vimrc (?)
  { config = ''
      " Use Vim settings, rather than Vi settings (much better!).
      " This must be first, because it changes other options as a side effect.
      set nocompatible

      " allow backspacing over everything in insert mode
      set backspace=indent,eol,start

      set history=50          " keep 50 lines of command line history

      " searching: highlight, incremental
      set hlsearch
      set incsearch

      " display more info on status line
      set ruler               " show cursor position in status bar
      set showcmd             " show typed command in status bar

      " some undo/backup settings
      if has("vms")
        set nobackup    " do not keep a backup file, use versions instead
      else
        set backup      " keep a backup file (restore to previous version)
        set undofile    " keep an undo file (undo changes after closing)
        " don't litter current dir with backups, but still try to put them
        " somewhere; double slash // at the end stores filenames with path
        set backupdir-=.
        set backupdir^=~/tmp//,/tmp//
        set undodir-=.
        set undodir^=~/tmp//,/tmp//
      endif

      " Don't use Ex mode, use Q for formatting
      map Q gq

      " CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
      " so that you can undo CTRL-U after inserting a line break.
      inoremap <C-U> <C-G>u<C-U>

      " This trigger takes advantage of the fact that the quickfix window can be
      " easily distinguished by its file-type, qf. The wincmd J command is
      " equivalent to the Ctrl+W, Shift+J shortcut telling Vim to move a window to
      " the very bottom (see :help :wincmd and :help ^WJ).
      autocmd FileType qf wincmd J

    ''; }
  # Some more settings, those I'm pretty sure are mine, or at least I tweaked them
  { config = ''
      set encoding=utf-8
      set fileencoding=utf-8

      " bash-like (or, readline-like) tab completion of paths, case insensitive
      set wildmode=longest,list,full
      set wildmenu
      if exists("&wildignorecase")
        set wildignorecase
      endif

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

      " Set 'git grep' as default command for :grep
      " This is much faster and more featureful when available. And I'm using it
      " mostly only when it's indeed available. If I were to use normal grep, I'd
      " anyway by default go for :cex system('grep ...')
      set grepprg=git\ grep\ -n

      " Use single space ' ' instead of double '  ' after end of sentence
      " in gq and J commands. See: https://stackoverflow.com/a/4760477/98528
      set nojoinspaces
    ''; }
]
