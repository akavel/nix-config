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
]
