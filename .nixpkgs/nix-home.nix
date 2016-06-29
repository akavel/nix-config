{ stdenv, writeText, writeScript
, bash }:

let
  nixHome = stdenv.mkDerivation rec {
    name = "nix-home-${version}";
    version = "0.0.1-2016.06.29";
    builder = writeText "builder.sh" ''
      source $stdenv/setup
      install ${nixHomeScript} -D $out/bin/nix-home
    '';
  };
  nixHomeScript = writeScript "nix-home" ''
    #! ${bash}/bin/bash
    echo `which nix-env` "$@"
    # TODO(akavel): pass source path via 'nix-home.nix' derivation args
    for f in $(find ~/.nix-profile/etc/home 2>/dev/null); do
      echo "$f"
    done
  '';
in nixHome
