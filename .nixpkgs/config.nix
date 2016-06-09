# NOTE(akavel): this file can be either a set, or a func (both are allowed).
{
  packageOverrides = defaultPkgs: with defaultPkgs; {
    # NOTE(akavel): `pkgs` below contains "final" packages "from the future",
    # after all overrides. And `defaultPkgs` contains packages in "pristine"
    # state (before any of the following overrides were applied).

    # "Declarative user profile/config". Install/update with `nix-env -i all`.
    # (This is a "fake package" named "all".)
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

    # TODO(akavel): as below, or: `neovim = defaultPkgs.neovim.override {` ?
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

## Various notes about Nix language

- `let` is recursive and lazy: `let x = x; in x` gives error about infinite
  recursion; `let x = x; in 5` just evaluates to `5`.
- `with foo; ...` still keeps `foo` visible inside the `...` code.
- `{ inherit (foo.bar) baz; }` is shortcut for `{ baz = foo.bar.baz; }`.
- `import ./foo/bar.nix arg1 arg2` loads code from ./foo/bar.nix and then
  calls it as a function with arguments `arg1` and `arg2`.
- `foo.bar or baz` returns `foo.bar` if `foo` has attribute `bar`, or
  expression `baz` otherwise. In other words, `baz` is a "default value" if
  `.bar` is missing.

***** */

