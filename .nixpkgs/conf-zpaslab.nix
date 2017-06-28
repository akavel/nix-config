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
        theXim = vimRebuilt;
        # Vim in Nix uses some ancient customization methods, which result in super ugly
        # customization usage.
        # See also: https://beyermatthias.de/blog/2015/11/25/how-to-setup-neovim-on-nixos/
        vimRebuilt = lib.overrideDerivation vimConfigured (o: {
          luaSupport = true;
        });
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
            sha256 = "0vdfjyprnn59brkf0vnyq9ksh03labwyq4vyvsihs4zhing2jbwy"; }
        ];
      in theXim;

  };
}
