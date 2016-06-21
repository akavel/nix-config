# TODO(akavel): try to remove ..., unless it's ok and not impacting performance/materializations
{ lib, vimUtils, vimPlugins, fetchFromGitHub, ... }:
let
  /* vamos is a helper/wrapper for vim plugin manager named "vam".
     It allows to specify plugins like below:

        vamos = import ./lib-vamos.nix pkgs;
        nvim = pkgs.neovim.override {
          configure = vamos [

            { fromVam="surround"; }

            { fromVam="ctrlp"; config=''
                let g:ctrlp_extensions = ['mixed', 'line', 'buffertag', 'tag']
                let g:ctrlp_custom_ignore = '\v\.pyc''$'
              ''; }

            { fromGitHub="powerman/vim-plugin-AnsiEsc"; rev="13.3"; sha256="0xjwp60z17830lvs4y8az8ym4rm2h625k4n52jc0cdhqwv8gwqpg"; }

            { fromGitHub="t9md/vim-choosewin"; rev="7795149689f4793439eb2c402e0c74d172311a6f"; sha256="1lv4fksk1wky7mgk1vsy2mcy1km6jd52wszpvjya6qpg6zi960z0";
              config=''
                nmap - <Plug>(choosewin)
                " let g:choosewin_overlay_enable = 1
                let g:choosewin_overlay_enable = 0
              ''; }

            { config = ''
                " indentation settings
                set expandtab           " replace TABs with spaces
                set autoindent
              ''; }

          ];
        };
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
