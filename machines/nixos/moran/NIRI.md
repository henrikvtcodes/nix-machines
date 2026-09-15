# niri

moran runs niri alongside hyprland. pick either session in tuigreet (F3).
side-by-side files: `wmde.nix` (system enable + greetd) and `home/niri.nix` (compositor
config, swaylock, swayidle). the hyprland side stays untouched until cutover, below.

nix integration: `github:sodiboo/niri-flake` in `flake.nix` provides `programs.niri.settings`
in home-manager with build-time config validation (`niri validate` runs against the package).
the compositor package itself is nixpkgs `pkgs.niri` (26.04 at time of writing, newer than
the flake's stable pin) so it substitutes from cache.nixos.org. the flake module also
enables the `niri.cachix.org` substituter (`niri-flake.cache.enable`, default on).

## what changed vs hyprland

- layout: hyprland `master` -> scrollable tiling with `layout.default-column-width.proportion = 1.0`
  (full-width columns stacked vertically, closest feel to master). `Mod+R` cycles the 1/3 1/2 2/3
  preset widths. niri has no master/dwindle layout.
- gaps: `gaps_out = [100 0 0 0]` (clearing space for waybar) is unnecessary; waybar reserves
  space via layer-shell exclusive zone. `layout.gaps = 0`.
- rounding: `decoration.rounding = 10` -> window rule `geometry-corner-radius 10` +
  `clip-to-geometry` + `prefer-no-csd`.
- `dim_inactive` -> no equivalent. focus is shown by the focus ring instead
  (colored catppuccin mocha blue in `home/niri.nix`).
- gesture `3, horizontal, workspace` -> niri touchpad gestures are fixed and not remappable:
  3-finger VERTICAL swipe switches workspaces, horizontal scrolls the view.
  muscle memory change.
- alt-tab: `cyclenext`/`bringactivetotop` -> niri's built-in `recent-windows` MRU switcher
  (default Alt+Tab bind, niri >= 25.11). no config needed.
- hypridle -> swayidle (gated to the niri session): 300s lock, 600s
  `niri msg action power-off-monitors` (monitors wake on any input),
  before-sleep pauses media + locks. hypridle is gated to hyprland in `home/hypr.nix`.
- hyprlock -> swaylock, catppuccin mocha themed. the `swaylock` PAM service (created by the
  niri-flake module) automatically gets fingerprint + u2f auth because
  `services.fprintd.enable` and `security.pam.u2f.enable` are on.
- hyprpaper -> dropped. it was enabled with empty settings (no wallpaper configured), so niri's
  built-in `background-color` is used instead (`outputs."eDP-1"` for now; per-output only,
  a `*` wildcard rule can be added later if desired).
- hyprshot -> niri's built-in screenshots: `Print` opens the interactive screenshot UI (region
  select, saves to `screenshot-path` and copies to clipboard), `Mod+Print` grabs the output.
  `screenshot-path` matches the old hyprshot save location. satty kept for annotation.
- hyprpicker -> kept, works on niri (`Mod+Shift+C` pipes to wl-copy).
- hyprpolkitagent -> kept as the polkit agent for both sessions; the niri-flake module's own
  KDE polkit agent is disabled in `wmde.nix` to avoid duplicates.
- xwayland (built into hyprland) -> xwayland-satellite via niri's native
  `xwayland-satellite` config section (niri 26.02+), needed for steam/prismlauncher.
- uwsm -> dropped for niri; `niri-session` has native systemd session integration.
- waybar: added `niri/workspaces` alongside `hyprland/workspaces` (the inactive one renders
  empty). `hyprland/submap` and `hyprland/scratchpad` have no niri equivalent (scratchpad was
  vestigial anyway, its on-click called sway).
- fixed in passing: hyprland's `kb_options = "kb_options"` set xkb options to the literal
  string; the niri config just sets `layout = "us"`.
- media keys work while locked (`allow-when-locked`), a small upgrade over hyprland's binds.

## cutover

after niri is validated (gestures, lock + fingerprint, idle/dpms, screenshots, steam),
remove the hyprland side:

- [ ] delete `home/hypr.nix` and its import in `home/default.nix`
- [ ] remove `programs.hyprland`, `hyprlock`, the hyprland session path from tuigreet
      `--sessions`, and hypr* systemPackages in `wmde.nix`
- [ ] `default.nix`: remove `programs.hyprlock.enable`, `services.hypridle.enable`,
      `pam.services.hyprlock`, and the hyprland cachix substituter/key
- [ ] `flake.nix`: remove the `hyprland` input and `niri.nixosModules.niri` is already
      there; drop the hyprland destructure
- [ ] `home/default.nix`: remove `programs.hyprshot`
- [ ] waybar: drop the `hyprland/*` modules
- [ ] update this file to reflect the final state
