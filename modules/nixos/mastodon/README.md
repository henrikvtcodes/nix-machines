# Mastodon

## How to generate keys

1. `podman compose run --rm --user=root -- web bash` in this directory
2. Run the following: `bundle exec rails mastodon:webpush:generate_vapid_key`, `rails db:encryption:init` and `bundle exec rails secret` x2 (for otp secret and secret key base)
