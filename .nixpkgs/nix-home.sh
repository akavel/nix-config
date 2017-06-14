#!/usr/bin/env bash
# TODO(akavel): write usage doc for --help
# TODO(akavel): --init  [create sample ~/.nixpkgs/config.nix]
# TODO(akavel): --purge [delete all recognized links]
set -e
set -o pipefail

SCRIPT="$(basename "$0")"
src=@contents@
dst=@links@

function err {
    echo "$SCRIPT: $@" >&2
}
function die {
    err "$@"
    exit 1
}
# tempfile  # print path of a newly created temporary file
function tempfile {
    mktemp --suffix=".$$.$SCRIPT"
}
# unmkdir root path  # remove empty dirs from $root down to $path
function unmkdir {
    local root="$1"
    local path="$2"
    while [ ${#path} -gt ${#root} ]; do
        rmdir "$path" >&/dev/null || return
        path="$(dirname "$path")"
    done
}
# subtree root  # print relative paths of all (links to) files in $root tree, separated by NUL byte and sorted
function subtree {
    local root="$1"
    (find "$root/" -xtype f -printf '%P\0' 2>/dev/null || true) |
        sort -z
}
# linkrel src dst  # create relative symbolic link at $dst pointing to $src
function linkrel {
    # NOTE(akavel): `ln -r` would follow target symlink, we don't want that
    local relto="$(dirname "$2")"
    ln -s "$(realpath -s --relative-to="$relto" "$1")" "$2"
}

# Remember current state of $src in $oldsrc
# TODO(akavel): maybe try pinning old nix profile instead?
oldsrc="$( tempfile )"
trap "rm '$oldsrc'" EXIT
subtree "$src" > "$oldsrc"

# TODO(akavel): For safety, verify $dst paths to be potentially removed are all correct links

if [ $# -eq 0 ]; then
  nix-env -iA nixpkgs.home
else
  nix-env "$@"
fi

# Create links in $dst to files in $src
subtree "$src" |
    while IFS= read -r -d '' path; do
        if [ -L "$dst/$path" ]; then
          continue
        elif [ -e "$dst/$path" ]; then
          err "warning: $dst/$path is a regular file, refusing to override"
          continue
        fi
        printf "%s: +%q\n" "$SCRIPT" "$path"
        mkdir -p "$(dirname "$dst/$path")"
        linkrel "$src/$path" "$dst/$path"
    done
# Remove links to removed files
comm -z -23 "$oldsrc" <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "%s: -%q\n" "$SCRIPT" "$path"
        if [ ! -L "$dst/$path" ]; then
            err "warning: $dst/$path is not a symbolic link, refusing to remove"
            continue
        fi
        # FIXME(akavel): only remove if the link points to expected path
        rm "$dst/$path"
        unmkdir "$dst" "$(dirname "$dst/$path")"
    done


