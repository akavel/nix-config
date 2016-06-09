# TODO(akavel): why doesn't this file require args specification in this line?
#  ANSWER: because it's just a nix set, not a func. [correct?]
{
  # TODO(akavel): how come the `with pkgs_` has a `pkgs` inside? is this some
  # fixpoint magic?
  packageOverrides = pkgs_: with pkgs_; {

    # "Declarative user profile/config". Install/update with `nix-env -i all`.
    # NOTE(akavel): Aparently `nix-env -iA nixos.all` is a faster variant.
    all = with pkgs; buildEnv {
      # Make it easy to install with `nix-env -i all` [I believe]
      # TODO(akavel): verify that below line is required [or advised] for
      # `nix-env -i all`
      name = "all";

      paths = [
        firefox
        tree
        nvim      # NeoVim + customized config (see below)
        nix-repl  # REPL for learning Nix
      ];
    };

    nvim = pkgs.neovim.override {
      vimAlias = true;
      #configure = {
      #};
    };
  };
}
