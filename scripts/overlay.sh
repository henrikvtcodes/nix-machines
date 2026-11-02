usage() {
  echo "usage: overlay link <template-dir>" >&2
  echo "       overlay create <path> --template=<dir>" >&2
  exit 1
}

# Link one template file into $PWD. $1 = relative path, $2 = absolute template dir.
link_one() {
  local p=$1 tmpl=$2 dir
  dir=$(dirname "$p")
  if [ ! -d "$PWD/$dir" ]; then
    echo "skip (no such dir in target): $dir" >&2
    return 0
  fi
  if [ -L "$PWD/$p" ] && [ "$(readlink "$PWD/$p")" = "$tmpl/$p" ]; then
    return 0
  fi
  if [ -e "$PWD/$p" ] || [ -L "$PWD/$p" ]; then
    echo "skip (exists): $p" >&2
    return 0
  fi
  ln -s "$tmpl/$p" "$PWD/$p"
  echo "linked: $p"
}

[ $# -ge 1 ] || usage
cmd=$1
shift

case "$cmd" in
  link)
    [ $# -eq 1 ] && [ -d "$1" ] || usage
    tmpl=$(cd "$1" && pwd)
    while IFS= read -r -d '' f; do
      link_one "${f#./}" "$tmpl"
    done < <(cd "$tmpl" && find . -name .git -prune -o -type f -print0)
    ;;
  create)
    path=""
    template=""
    for a in "$@"; do
      case "$a" in
        --template=*) template=${a#--template=} ;;
        *) path=$a ;;
      esac
    done
    [ -n "$path" ] && [ -n "$template" ] && [ -d "$template" ] || usage
    tmpl=$(cd "$template" && pwd)
    dir=$(dirname "$path")
    if [ ! -d "$PWD/$dir" ]; then
      echo "error: no such dir in target: $dir" >&2
      exit 1
    fi
    if [ -e "$PWD/$path" ] || [ -L "$PWD/$path" ] || [ -e "$tmpl/$path" ]; then
      echo "error: already exists: $path" >&2
      exit 1
    fi
    mkdir -p "$tmpl/$dir"
    touch "$tmpl/$path"
    ln -s "$tmpl/$path" "$PWD/$path"
    echo "created: $path"
    ;;
  *) usage ;;
esac
