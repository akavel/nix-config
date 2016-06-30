{ stdenv, lib, writeTextFile, runCommand
, bash

# TODO(akavel): use mkOption etc.? how?
, storePath ? "/etc/nix-home"
, files ? {}
}:

# TODO(akavel): could we just return a list of writeTextFile derivations?
let
  nixHome = linksTree "homedir" (lib.attrValues (lib.mapAttrs mkStoreEntry files));
  # linksTree is similar to linkFarm, but can create nested links
  # TODO(akavel): better doc
  # TODO(akavel): protect against ' and ` in x.name and x.path
  linksTree = name: entries: runCommand name {} ("mkdir -p $out; cd $out;\n" +
    (lib.concatMapStrings (x: "mkdir -p `dirname './${x.name}'`; ln -s '${x.path}' './${x.name}';\n") entries));
  mkStoreEntry = relPath: contents: {
    name = "${storePath}/${relPath}";
    path = writeTextFile {
      name = baseNameOf relPath;
      text = contents;
    };
  };
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
