# TODO(akavel): try to remove ..., unless it's ok and not impacting performance/materializations
{ vimUtils, vimPlugins, fetchFromGitHub, ... }:
let
  /* vamos is a helper/wrapper for vim plugin manager named "vam".
     It allows to specify plugins like below:
     TODO(akavel): add example usage & explain
  */
  vamos = pluginsList: {
    vam = {
      pluginDictionaries = pluginsAttr "pluginDictionaries" pluginsList;
      knownPlugins =
        vimPlugins // (builtins.listToAttrs (pluginsAttr "knownPlugins" pluginsList));
    };
    customRC = builtins.foldl' concat "" (pluginsAttr "config" pluginsList);
  };

  pluginsAttr = attr: pluginsList:
    listAttr attr (map toVamWithConfig pluginsList);
  toVamWithConfig = plugin: (toVam plugin) // (
    if plugin ? config then {
      config = plugin.config;
    } else {});
  toVam = plugin:
    if plugin ? fromGitHub then {
      pluginDictionaries = { name = baseNameOf plugin.fromGitHub; };
      knownPlugins = knownFromGitHub plugin;
    } else if plugin ? fromVam then {
      pluginDictionaries = { name = plugin.fromVam; };
      knownPlugins = { name=plugin.fromVam; value=builtins.getAttr plugin.fromVam vimPlugins; };
    } else {};

  listAttr = attr: list:
    map (builtins.getAttr attr) (builtins.filter (builtins.hasAttr attr) list);
  concat = x: y:
    x + "\n" + y;

  knownFromGitHub = plugin:
    let
      repo = baseNameOf plugin.fromGitHub;
      owner = builtins.substring 0 (strlen plugin.fromGitHub - strlen repo - 1) plugin.fromGitHub;
      strlen = builtins.stringLength;
    in {
      name = repo;
      value = vimUtils.buildVimPluginFrom2Nix {
        name = repo;
        src = fetchFromGitHub {
          inherit (plugin) rev sha256;
          inherit owner repo;
        };
      };
    };
in
  vamos
