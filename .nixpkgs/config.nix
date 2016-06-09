# TODO(akavel): why doesn't this file require args specification in this line?
#  ANSWER: because it's just a nix set, not a func. [correct?]
{
  # TODO(akavel): can I specify the 'pkgs' below in {} curly brackets, or not?
  #  ANSWER: I think not, because e.g. {x} would be "pattern-matching", i.e. would expect pkgs to be a set containing 'x'.
  packageOverrides = pkgs_: with pkgs_; {

    # "Declarative user profile/config". Installed/updated with `nix-env -i all`.
    # NOTE(akavel): It's apparently faster to use `nix-env -iA nixos.all` instead.
    all = with pkgs; buildEnv {
      # Make it easy to install with `nix-env -i all` [I believe]
      # TODO(akavel): verify that below line is required [or advised] for `nix-env -i all`
      name = "all";

      paths = [
        firefox
        tree
        nvim
      ];
    };

    nvim = pkgs.neovim.override {
      vimAlias = false;
      #configure = {
      #};
    };
  };
}
