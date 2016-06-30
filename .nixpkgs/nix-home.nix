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
  linksTree = name: entries: runCommand name {} ("mkdir -p $out; cd $out;\n" +
    (lib.concatMapStrings (x: "mkdir -p `dirname ./${esc x.name}`; ln -s ${esc x.path} ./${esc x.name};\n") entries));
  esc = s: lib.escapeShellArg (toString s);
  mkStoreEntry = relPath: contents: {
    name = "${storePath}/${relPath}";
    path = writeTextFile {
      name = baseNameOf relPath;
      text = contents;
    };
  };
in nixHome
