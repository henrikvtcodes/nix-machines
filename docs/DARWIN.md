# Managing Darwin Machines

## In The Event of a Broken `$PATH`

1. Diagnose the issue (improper formatting, invalid directory, etc)
2. Copy the darwin-rebuild command from current system: `cp -i /run/current-system/sw/bin/darwin-rebuild emergency-darwin-rebuild`
3. Update permissions (allow write by owner): `sudo chmod 755 emergency-darwin-rebuild`
4. Manually edit the PATH variable in darwin-rebuild: `vi emergency-darwin-rebuild`
5. Try rollback: `./emergency-darwin-rebuild --rollback` (if no generations available, fix nix conf and rebuild with that: `./emergency-darwin-rebuild switch --flake <absolute path to local flake>` )
