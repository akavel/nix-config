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
        theXim = vimUtils.vimWithRC {
          name = "xim";
          vimExecutable = "${defaultPkgs.vim}/bin/vim";
          vimrcFile = vimUtils.vimrcFile myVimrc;
        };
        vamos = callPackage ./lib-vamos.nix {};
        myVimrc = vamos [
          # Go language support for vim
          { fromVam="vim-go"; }
          # Smart and quick file opening with Ctrl-P, by fuzzy path match, like in SublimeText
          { fromVam="ctrlp"; config=''
              let g:ctrlp_extensions = ['mixed', 'line', 'buffertag', 'tag']
              let g:ctrlp_custom_ignore = '\v\.pyc''$'
            ''; }
        ];
      in theXim;

  };
}
