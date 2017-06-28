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
        vamos = callPackage ./lib-vamos.nix {};
        # Note: see <nixpkgs>/pkgs/misc/vim-plugins/default.nix for names to use with fromVam
        myVimrc = vamos [
          { fromGitHub="garyburd/go-explorer";
            rev = "c22eec647bca26f61578d27a152141374cbe2854";
            sha256 = "1rpj8y0jdpa8qpkk4hvxjfk16lk6j2b89y6bh4fdkmw3kbd1gz40"; }
          # Go language support for vim
          { fromVam="vim-go"; }
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
            sha256 = "1hhhkdy18bnkrsi4rnwzcv88mcz63k4jbxxr3j8p9z9jzqdadrx9"; }
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
        ];
      in theXim;

  };
}
