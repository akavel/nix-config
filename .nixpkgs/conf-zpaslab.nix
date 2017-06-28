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
          { config = ''
              " For *.plant files, use filetype "conf"
              au BufNewFile,BufFilePre,BufRead *.plant set filetype=conf
            ''; }
        ];
      in theXim;

  };
}
