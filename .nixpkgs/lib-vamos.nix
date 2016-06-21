# TODO(akavel): try to remove ..., unless it's ok and not impacting performance/materializations
{ vimUtils, vimPlugins, fetchFromGitHub, ... }:
let
  /* vamos is a helper/wrapper for vim plugin manager named "vam".
     It allows to specify plugins like below:
     TODO(akavel): add example usage & explain
  */
  vamos = list: {
    vam = {
      pluginDictionaries = map toVamPD (onlyGitHub list);
      knownPlugins = {
        "vim-addon-manager" = vimPlugins."vim-addon-manager";
      } // (builtins.listToAttrs (map toVamKP (onlyGitHub list)));
    };
    customRC = builtins.foldl' (x: y: x+"\n"+y) "" (
      map (plugin: plugin.config or "") list
    );
  };

  onlyGitHub = list: builtins.filter (p: p ? fromGitHub) list;
  # FIXME(akavel): slash ('/') in names is not allowed for vimUtils
  #toVamName = { fromGitHub, ... }: fromGitHub;
  toVamName = { fromGitHub, ... }: baseNameOf fromGitHub;
  toVamPD = plugin: { name = toVamName plugin; };
  toVamKP = plugin: 
    let
      name = toVamName plugin;
      len = builtins.stringLength;
      repo = baseNameOf plugin.fromGitHub;
      owner = builtins.substring 0 (len plugin.fromGitHub - len repo - 1) plugin.fromGitHub;
    in {
      inherit name;
      value = vimUtils.buildVimPluginFrom2Nix {
        inherit name;
        src = fetchFromGitHub {
          # owner, repo, rev, sha256
          inherit (plugin) rev sha256;
          inherit owner repo;
        };
      };
    };
in
  vamos
