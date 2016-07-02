{ stdenv, lib, writeTextFile, writeScript, runCommand
, bash

# TODO(akavel): use mkOption etc.? how?
, storePath ? "/etc/nix-home"
, files ? {}
}:

# TODO(akavel): could we just return a list of writeTextFile derivations?
let
  nixHome = linksTree "homedir" (lib.attrValues (lib.mapAttrs mkStoreEntry files) ++ [{
    # TODO(akavel): make ~/.nix-profile non-hardcoded somehow?
    # TODO(akavel): make sure to disallow '.nix-profile' on the list of files; similar maybe for e.g. .git, .nix-defexpr, .nixpkgs, ...
    name = "bin/nix-home";
    path = writeScript "nix-home-wrapper" ''
      #! ${bash}/bin/bash
      ${./nix-home.sh} nix-home ~/.nix-profile/${esc storePath} ~ "$@"
    '';
  }]);
  # linksTree is similar to linkFarm, but can create nested links
  # TODO(akavel): better doc
  linksTree = name: entries: runCommand name {} ("mkdir -p $out; cd $out;\n" +
    (lib.concatMapStrings (x: "mkdir -p `dirname ./${esc x.name}`; ln -s ${esc x.path} ./${esc x.name};\n") entries));
  esc = s: lib.escapeShellArg (toString s);
  mkStoreEntry = relPath: contents: {
    name = "${storePath}/${relPath}";
    path =
      if builtins.isString contents then
        writeTextFile {
          # Note(akavel): a prefix (e.g. "homefile-") is required, otherwise dotfiles (e.g. .xsession) get disallowed!...
          name = "homefile-${baseNameOf relPath}";
          text = contents;
        }
      else if lib.isDerivation contents then
        contents
      else
        # TODO(akavel): if toString possible on 'contents', add it to the thrown message
        throw "nix-home file value should be string or derivation";
  };
in nixHome
