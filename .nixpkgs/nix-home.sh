#!/usr/bin/env bash
# TODO(akavel): write usage doc for --help
set -e
set -o pipefail

src="${1:-~/.nix-profile/etc/nix-home}"
dst="${2:-~}"
shift 2

function err {
    echo "$(basename "$0"): $@" >&2
}
function die {
    err "$@"
    exit 1
}
# tempfile prints path of a newly created temporary file
function tempfile {
    mktemp --suffix=".$$.$(basename "$0")"
}
# unmkdir removes empty dirs from $root down to $path
function unmkdir {
    local root="$1"
    local path="$2"
    while [ ${#path} -gt ${#root} ]; do
        rmdir "$path" || return
        path="$(dirname "$path")"
    done
}
# subtree prints relative paths of all files in $root tree, separated by NUL byte and sorted
function subtree {
    local root="$1"
    find "$root/" -type f -printf '%P\0' |
        sort -z
}

# Remember current state of $src in $oldsrc
# TODO(akavel): maybe try pinning old nix profile instead?
oldsrc="$( tempfile )"
trap "rm '$oldsrc'" EXIT
subtree "$src" > "$oldsrc"

# TODO(akavel): For safety, verify $dst paths to be potentially removed are all correct links

if [ $# -eq 0 ]; then
  nix-env -iA nixos.home
else
  nix-env "$@"
fi

# Create links in $dst to files in $src
subtree "$src" |
    while IFS= read -r -d '' path; do
        [ -e "$dst/$path" ] && continue
        printf "add: %q\n" $path
        mkdir -p "$(dirname "$dst/$path")"
        ln -s -r "$src/$path" "$dst/$path"
    done
# Remove links to removed files
comm -z -23 "$oldsrc" <( subtree "$src" ) |
    while IFS= read -r -d '' path; do
        printf "remove: %q\n" $path
        if [ ! -L "$dst/$path" ]; then
            err "$dst/$path: is not a symbolic link, refusing to remove"
            continue
        fi
        rm "$dst/$path"
        unmkdir "$dst" "$(dirname "$dst/$path")"
    done

