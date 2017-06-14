{ stdenv, lib, writeTextFile, runCommand, substituteAll
, bash

# TODO(akavel): use mkOption etc.? how?
, files ? {}
}:

# TODO(akavel): could we just return a list of writeTextFile derivations?
let
  STORE_PATH = "/var/nix-home";
  nixHome = linksTree "homedir" (lib.attrValues (lib.mapAttrs mkStoreEntry files) ++ [{
    name = "bin/nix-home";
    path = nixHomeScript;
  }]);
  nixHomeScript = substituteAll {
    # TODO(akavel): make ~/.nix-profile non-hardcoded somehow?
    # TODO(akavel): make sure to disallow '.nix-profile' on the list of files; similar maybe for e.g. .git, .nix-defexpr, .nixpkgs, ...
    src = ./nix-home.sh;
    isExecutable = true;
    contents = "~/.nix-profile/${esc STORE_PATH}";
    links = "~";
  };
  # linksTree is similar to linkFarm, but can create nested links
  # TODO(akavel): better doc
  linksTree = name: entries: runCommand name {} ("mkdir -p $out; cd $out;\n" +
    (lib.concatMapStrings (x: "mkdir -p `dirname ./${esc x.name}`; ln -s ${esc x.path} ./${esc x.name};\n") entries));
  esc = s: lib.escapeShellArg (toString s);
  mkStoreEntry = relPath: contents: {
    name = "${STORE_PATH}/${relPath}";
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
        throw "nix-home file value should be string or derivation, got ${builtins.typeOf contents}";
  };
in nixHome
