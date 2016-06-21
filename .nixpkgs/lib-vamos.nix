# TODO(akavel): try to remove ..., unless it's ok and not impacting performance/materializations
{ vimUtils, vimPlugins, fetchFromGitHub, ... }:
let
  /* vamos is a helper/wrapper for vim plugin manager named "vam".
     It allows to specify plugins like below:
     TODO(akavel): add example usage & explain
  */
  vamos = pluginsList: {
    vam = {
      pluginDictionaries = map toVamPD (builtins.filter needsVam pluginsList);
      knownPlugins = vimPlugins // {
        "vim-addon-manager" = vimPlugins."vim-addon-manager";
      } // (builtins.listToAttrs (map toVamKP (onlyGitHub pluginsList)));
    };
    customRC = builtins.foldl' (x: y: x+"\n"+y) "" (
      map (plugin: plugin.config or "") pluginsList
    );
  };

  needsVam = plugin: plugin ? fromGitHub || plugin ? fromVam;

  onlyGitHub = list: builtins.filter (p: p ? fromGitHub) list;
  # TODO(akavel): slash ('/') in names is not allowed for vimUtils - but I'd like to have it ?
  toVamName = plugin:
    if plugin ? fromGitHub then
      baseNameOf plugin.fromGitHub
    else if plugin ? fromVam then
      plugin.fromVam
    else throw "vamos can't handle plugin $(toString plugin)";
  toVamPD = plugin: { name = toVamName plugin; };
  toVamKP = plugin:
    if plugin ? fromGitHub then
      knownFromGitHub plugin
    else if plugin ? fromVam then
      { name=plugin.fromVam; value=builtins.getAttr plugin.fromVam vimPlugins; }
    else throw "vamos can't handle plugin $(toString plugin)";
  knownFromGitHub = plugin:
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