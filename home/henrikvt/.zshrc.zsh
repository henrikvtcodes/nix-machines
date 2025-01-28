# If fnm is present (ie running `fnm` returns 0), eval it
if command -v "fnm --version" &> /dev/null; then
  eval "$(fnm env)"
fi