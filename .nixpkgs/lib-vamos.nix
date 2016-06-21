# TODO(akavel): try to remove ..., unless it's ok and not impacting performance/materializations
{ lib, vimUtils, vimPlugins, fetchFromGitHub, ... }:
let
  /* vamos is a helper/wrapper for vim plugin manager named "vam".
     It allows to specify plugins like below:
     TODO(akavel): add example usage & explain
  */
  vamos = pluginsList: {
    vam = {
      pluginDictionaries = pluginsAttr "pluginDictionaries" pluginsList;
      knownPlugins =
        vimPlugins // mergeSets (pluginsAttr "knownPlugins" pluginsList);
    };
    customRC = lib.concatStringsSep "\n" (pluginsAttr "config" pluginsList);
  };

  pluginsAttr = attr: pluginsList:
    lib.catAttrs attr (map toVamWithConfig pluginsList);
  toVamWithConfig = plugin: (toVam plugin) // (
    if plugin ? config then {
      config = plugin.config;
    } else {});
  toVam = plugin:
    if plugin ? fromGitHub then {
      pluginDictionaries = { name = nameFromGitHub plugin; };
      knownPlugins = {
        ${nameFromGitHub plugin} = buildFromGitHub plugin;
      };
    } else if plugin ? fromVam then {
      pluginDictionaries = { name = plugin.fromVam; };
      knownPlugins = {
        ${plugin.fromVam} = builtins.getAttr plugin.fromVam vimPlugins;
      };
    } else {};
  mergeSets = listOfSets:
    builtins.foldl' (x: y: x//y) {} listOfSets;

  nameFromGitHub = plugin:
    baseNameOf plugin.fromGitHub;
  buildFromGitHub = plugin:
    let
      repo = baseNameOf plugin.fromGitHub;
      owner = lib.removeSuffix "/${repo}" plugin.fromGitHub;
    in
      vimUtils.buildVimPluginFrom2Nix {
        name = nameFromGitHub plugin;
        src = fetchFromGitHub {
          inherit (plugin) rev sha256;
          inherit owner repo;
        };
      };
in
  vamos
