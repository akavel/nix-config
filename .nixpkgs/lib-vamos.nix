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
        vimPlugins // (builtins.listToAttrs (pluginsAttr "knownPlugins" pluginsList));
    };
    customRC = lib.concatStringsSep "\n" (pluginsAttr "config" pluginsList);
  };

  pluginsAttr = attr: pluginsList:
    listAttr attr (map toVamWithConfig pluginsList);
  toVamWithConfig = plugin: (toVam plugin) // (
    if plugin ? config then {
      config = plugin.config;
    } else {});
  toVam = plugin:
    if plugin ? fromGitHub then {
      pluginDictionaries = { name = nameFromGitHub plugin; };
      knownPlugins = {
        name = nameFromGitHub plugin;
        value = buildFromGitHub plugin;
      };
    } else if plugin ? fromVam then {
      pluginDictionaries = { name = plugin.fromVam; };
      knownPlugins = {
        name = plugin.fromVam;
        value = builtins.getAttr plugin.fromVam vimPlugins;
      };
    } else {};

  listAttr = attr: list:
    map (builtins.getAttr attr) (builtins.filter (builtins.hasAttr attr) list);

  nameFromGitHub = plugin:
    baseNameOf plugin.fromGitHub;
  buildFromGitHub = plugin: with builtins;
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
