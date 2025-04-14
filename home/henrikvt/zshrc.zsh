# If fnm is present (ie running `fnm` returns 0), eval it
if command -v "fnm" &> /dev/null; then
  eval "$(fnm env)"
fi

unalias tldr