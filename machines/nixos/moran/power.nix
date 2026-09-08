{pkgs, ...}: let
  inherit (pkgs) bash coreutils procps systemd;

  # Matches only authenticated sshd children ("sshd: user@pts/0",
  # "sshd: user@notty", "sshd: user [priv]"); the listener ("sshd: /nix/...")
  # and pre-auth titles ("sshd: [accepted]", "sshd: [preauth]") are excluded.
  sshSessionCheck = "${procps}/bin/pgrep -f \"^sshd: [a-z_]\"";

  sshLidInhibitScript = pkgs.writeShellScript "ssh-lid-inhibit" ''
    while ! ${sshSessionCheck} >/dev/null 2>&1; do
      ${coreutils}/bin/sleep 15
    done

    exec ${systemd}/bin/systemd-inhibit \
      --what=handle-lid-switch:sleep \
      --mode=block \
      --who="ssh-keep-awake" \
      --why="Active SSH session" \
      ${bash}/bin/bash -c \
      'while ${sshSessionCheck} >/dev/null 2>&1; do ${coreutils}/bin/sleep 10; done'
  '';
in {
  # Keep moran awake while someone is logged in over SSH: closing the lid is
  # suppressed by a block inhibitor held for as long as any authenticated sshd
  # session exists. Display sleep is unaffected (Hyprland turns off the built-in
  # panel on lid close, and hypridle's DPMS timers keep running).
  #
  # Note: if the last SSH session ends while the lid is closed, the machine
  # stays awake (lid events are edge-triggered; logind will not retroactively
  # suspend). Open the lid or suspend manually to sleep it again.
  systemd.services.ssh-lid-inhibit = {
    description = "Inhibit suspend and lid-close while SSH sessions are active";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sshLidInhibitScript}";
      Restart = "always";
      RestartSec = 15;
    };
  };

  # Deferred: Wake-on-SSH via Tailscale (not implemented).
  #
  # How it would work:
  #   tailscale set --wake-on-connect=true registers this node as wakeable.
  #   When a tailnet peer connects to it while asleep, an always-on tailnet
  #   node on the same LAN broadcasts a Wake-on-LAN magic packet, the NIC
  #   wakes the machine, and the connection proceeds.
  #
  # To implement:
  #   - Add a `wakeOnConnect` option to modules/nixos/tailscale that appends
  #     "--wake-on-connect=true" to extraSetFlags (applied at boot by
  #     tailscaled-set.service; persists across reboots).
  #   - Only enable while plugged into AC: the NIC keeps listening through
  #     suspend and would drain the battery otherwise. Toggle it dynamically,
  #     e.g. a oneshot service running
  #       tailscale set --wake-on-connect=$(systemd-ac-power >/dev/null && echo true || echo false)
  #     triggered by a udev rule on power_supply Mains "online" changes, or a
  #     coarse OnUnitActiveSec=60s timer.
  #   - tailscaled manages the NIC's WoL flag itself when the pref is on; if
  #     it does not stick, add systemd.network.links."50-wol" with
  #     matchConfig = { Driver = "r8152"; } and
  #     linkConfig.WakeOnLan = "magic" (the Ethernet expansion card is a USB
  #     NIC whose interface name derives from its MAC, hence driver matching).
  #   - Caveats: Framework 13 AMD only does s2idle (no S3), so WoL through the
  #     Ethernet expansion card needs BIOS wake-from-USB enabled and must be
  #     tested end to end; Wi-Fi (mt7921) WoWLAN is unreliable. Tailscale WoL
  #     also requires a relay node on the same LAN, so it only works where
  #     another tailnet machine is always on (broadcasts are typically blocked
  #     on dorm/campus networks).
}
