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
      # FIXME(akavel): verify that all files listed in 'dirs' can be created in $HOME/$d/... - i.e. they're missing or are appropriate links
      install ${nixHomeScript} -D $out/bin/nix-home
    '';
  };
  # FIXME(akavel): create actual files listed in 'dirs'
  nixHomeScript = writeScript "nix-home" ''
    #! ${bash}/bin/bash
    echo `which nix-env` "$@"

    # Cleanup old links
    for d in ${ bashList (builtins.attrNames dirs) }; do
      echo "$d"
      # FIXME(akavel): delete all links in $HOME/$d dir which point to corresponding path in $HOME/.nix-profile/${storePath}
    done

    # TODO(akavel): try to put the files in /nix/store/.../, not in ~/.nix-profile/...
    for f in $(find "$HOME/.nix-profile/${storePath}" 2>/dev/null); do
      echo "$f"
    done
  '';
  bashList = list: lib.concatMapStringsSep " " lib.escapeShellArg list;
in nixHome
