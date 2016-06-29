{ stdenv, lib, writeText, writeScript
, bash

, storePath ? "/etc/home"
, dirs ? {}
}:

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

    # Cleanup old links
    for d in ${ bashList (builtins.attrNames dirs) }; do
      echo "$d"
    done

    for f in $(find "$HOME/.nix-profile/${storePath}" 2>/dev/null); do
      echo "$f"
    done
  '';
  bashList = list: lib.concatMapStringsSep " " lib.escapeShellArg list;
in nixHome
