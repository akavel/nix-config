{pkgs, ...}:
{
  packageOverrides = defaultPkgs: with defaultPkgs; {
    # Declarative user profile/config. Install/update with `nix-env -i home`.
    home = with pkgs; buildEnv {
      name = "home";
      paths = [
        nix-home
        vim_
      ];
    };

    nix-home = callPackage ./nix-home {
      files = {
        # bash: case-insensitive TAB-completion
        ".inputrc" = "set completion-ignore-case On";
        #"sample-home-test" = "sample-test";
        # ack: nice navigation if many results; keep colors enabled
        ".ackrc" = "--pager=less -R";
        ".gitconfig" = ''
          # This is Git's per-user configuration file.
          [user]
            name = "Mateusz Czapliński"
            email = czapkofan@gmail.com
          [push]
            default = simple
        '';
      };
    };

    # TODO(akavel): disable python in vim, maybe
    # TODO(akavel): use neovim instead of vim
    # IMPORTANT: bash will by default use cached /usr/bin/vim; to clear
    # cache, run `hash -r` or `hash -d vim` - see:
    # https://unix.stackexchange.com/a/5610/11352
    vim_ =
      let
        theVim = vimConfigured;
        # Vim in Nix uses some ancient customization methods, which result in
        # super ugly customization usage. I can't figure out e.g. how to
        # disable support for Python, but keep Lua enabled.
        vimConfigured = defaultPkgs.vim_configurable.customize {
          name = "vim";
          vimrcConfig = vamos (commonVimrc ++ myVimrc);
        };
        # Vamos is my custom helper for managing Vim plugins & .vimrc
        vamos = callPackage ./vim/lib-vamos.nix {};
        commonVimrc = import ./vim/vimrc-common.nix;
        # Note: see <nixpkgs>/pkgs/misc/vim-plugins/default.nix for names to use with fromVam
        myVimrc = [
          # Settings specific to WSL
          { config = ''
              colo elflord
            ''; }
        ];
      in theVim;
  };
}

