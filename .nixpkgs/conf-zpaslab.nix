{pkgs, ...}:
{
  packageOverrides = defaultPkgs: with defaultPkgs; {
    # Declarative user profile/config. Install/update with `nix-env -i home`.
    home = with pkgs; buildEnv {
      name = "home";
      paths = [
        nix-home
      ];
    };

    nix-home = callPackage ./nix-home {
      files = {
        # bash: case-insensitive TAB-completion
        ".inputrc" = "set completion-ignore-case On";
        "sample-home-test" = "sample-test";
        # ack: nice navigation if many results; keep colors enabled
        ".ackrc" = "--pager=less -R";
      };
    };
  };
}
