{ stdenv, lib, writeText, writeScript
, bash

# TODO(akavel): use mkOption etc.? how?
, storePath ? "/etc/nix-home"
, files ? {}
}:

let
  nixHome = stdenv.mkDerivation rec {
    name = "nix-home-${version}";
    version = "0.0.1-2016.06.29";
    builder = writeText "builder.sh" ''
      source $stdenv/setup
      ${mkStoreFiles}
    '';
  };
  mkStoreFiles = writeScript "mkStoreFiles.sh" ''
    #! ${bash}/bin/bash
    mkdir -p "$out/${storePath}"
    ${ lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs linkStoreFile fileDrvs)) }
  '';
  linkStoreFile = relPath: contentsDrv: ''
    mkdir -p "$(dirname "$out/${storePath}/${relPath}")"
    ln -s "${contentsDrv}" "$out/${storePath}/${relPath}"
  '';
  fileDrvs = lib.mapAttrs writeText files;
in nixHome

/*
    builder = writeText "builder.sh" ''
      source $stdenv/setup
      install /dev/stdin -D $out/bin/nix-home <<"EOF"
      #! ${bash}/bin/bash
      ${nixHomeScript} ${dirsDerivation} ${ bashList (builtins.attrNames dirs) }
      EOF
    '';
    bashList = list: lib.concatMapStringsSep " " lib.escapeShellArg list;
*/
