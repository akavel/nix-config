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

    nix-home = callPackage ./nix-home.nix {
      files = {
        "sample-home-test" = "sample-test";
      };
    };
  };
}
