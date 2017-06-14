with builtins;
let
  config = import (toPath "${HOME}/.nixpkgs/conf-${profile}.nix");
  HOME = getEnv "HOME";
  profile = readFileOr "default" ./conf;
  readFileOr = default: path:
    if pathExists path then
      readFile path
    else default;
in
  config
