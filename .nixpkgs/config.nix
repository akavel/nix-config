# TODO(akavel): why doesn't this file require args specification in this line?
#  ANSWER: because it's just a nix set, not a func. [correct?]
{
  # TODO(akavel): how come the `with pkgs_` has a `pkgs` inside? is this some
  # fixpoint magic?
  packageOverrides = pkgs_: with pkgs_; {

    # "Declarative user profile/config". Install/update with `nix-env -i all`.
    # NOTE(akavel): Aparently `nix-env -iA nixos.all` is a faster variant.
    all = with pkgs; buildEnv {
      # Make it easy to install with `nix-env -i all` [I believe]
      # TODO(akavel): verify that below line is required [or advised] for
      # `nix-env -i all`
      name = "all";

      paths = [
        firefox
        tree
        nvim      # NeoVim + customized config (see below)
        nix-repl  # REPL for learning Nix
      ];
    };

    nvim = pkgs.neovim.override {
      vimAlias = true;
      #configure = {
      #};
    };
  };
}

/* **** Notes: *****

## Where does 'pkgs' come from in 'packageOverrides' in ~/.nixpkgs/config.nix?

-> start explanation from pkgs/top-level/default.nix
  (this is what imports ~/.nixpkgs/config.nix)

-> explain lib.extends (a la inheritance) and lib.fix'
  - lib.fix' (
      lib.extends grandchild (
        lib.extends child (
          lib.extends parent (
            empty))))
    where:
      empty = self: {};
      grandpa = final: myparent: { ..... };
      parent  = final: myparent: { ..... };
      junior  = final: myparent: { ..... };
    Each func in the "family" can take a "default" value from past/"ancestor"
    (via `myparent.someField`), or a "future" value which will take into
    account all calculations done by all children/"descendants" (via
    `final.someField`), and pass it down to immediate successor. For example:

        let
          lib = import ./nixpkgs/lib/trivial.nix;
          grandpa = final: myparent:
            { name="Aaron";
              aaronsBook="my grandchild will be "+final.name; };
          parent = final: myparent: rec
            { name="Bill";
              billsBook="I'm "+name+", my dad is "+myparent.name; };
          junior = final: myparent: rec
            { name="Chad";
              chadsBook="I'm "+name+", my dad is "+myparent.name; };
          empty = self: {};
        in
          lib.fix' (
            lib.extends junior (
              lib.extends parent (
                lib.extends grandpa (empty))))

-> then func `allPackages` imports `./all-packages.nix`, which defines `pkgs`.
  It's value is actually passed as an argument to the import, and nonetheless
  resolves to the final ("future") set of calculated packages (the final
  fixpoint result). Note that `with pkgs` in all-packages.nix still allows
  to access pkgs by name.

***** */

