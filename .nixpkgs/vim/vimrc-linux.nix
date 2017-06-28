[
  # TODO(akavel): enable 'deoplete' only for NeoVim; for normal Vim use neocomplete
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
  { fromVam="vim-repeat"; }
  # Increase/decrease selection with +/_
  { fromVam="vim-expand-region"; }
  # Press `gS` on line to split it smart, or `gJ` on first line of block to join it smart.
  { fromGitHub="AndrewRadev/splitjoin.vim";
    rev = "20868936ea2af5f8a929b0924db65f8a27035a89";
    sha256 = "0fxsksv25waxaszl81za6qkfiakr4zm63lib5ryvks5d3xvf3697"; }
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
]
