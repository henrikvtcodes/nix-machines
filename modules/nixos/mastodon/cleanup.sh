
# Credit: https://github.com/czerwonk/nixfiles/blob/main/nixos/services/mastodon/cleanup.sh
run_in_container() {
  echo $@;
  podman exec mastodon-web $@
}

run_in_container bin/tootctl media remove --days=7
run_in_container bin/tootctl media remove --days=7 --remove-headers
run_in_container bin/tootctl media remove --days=7 --prune-profiles
run_in_container bin/tootctl statuses remove --days=14
run_in_container bin/tootctl preview_cards remove --days=30
#run_in_container tootctl accounts prune