{pkgs, ...}: let
  port = 18477;
  dkimSelector = "mail";
  dkimDomain = "lists.as63477.net";
  dkimKeyDir = "/var/lib/rspamd/dkim";
  dkimKey = "${dkimKeyDir}/${dkimDomain}.${dkimSelector}.key";
  # Generate the DKIM keypair on the host on first start if absent. The private
  # key stays on the host (never committed); the public record is written next
  # to it as a .txt for publishing in DNS.
  dkimKeygen = pkgs.writeShellScript "rspamd-dkim-keygen" ''
    set -eu
    install -d -m 0700 "${dkimKeyDir}"
    if [ ! -f "${dkimKey}" ]; then
      ${pkgs.rspamd}/bin/rspamadm dkim_keygen \
        -s "${dkimSelector}" -d "${dkimDomain}" -k "${dkimKey}" \
        > "${dkimKeyDir}/${dkimDomain}.${dkimSelector}.txt"
    fi
  '';
in {
  services = {
    postfix = {
      enable = true;
      settings.main = {
        # Identity: HELO/EHLO as an FQDN that matches the PTR of the
        # sending IPs (mx.mci.as63477.net -> .25, both v4 and v6).
        myhostname = "mx.mci.as63477.net";
        # Locally-generated mail (bounces, root/cron) gets a sender domain
        # that has SPF coverage.
        myorigin = "lists.as63477.net";

        # Always egress from the dedicated mail IPs.
        smtp_bind_address = "155.103.251.25";
        smtp_bind_address6 = "2602:f542:bee::25";
        smtp_bind_address_enforce = "yes";
        # "any" lets Postfix fall back to IPv4 when a remote's IPv6 :25 is
        # unreachable, instead of hard-failing on an IPv6-only attempt.
        smtp_address_preference = "any";

        # If the rspamd milter is unavailable, accept (unsigned) instead of
        # deferring all mail. The milter sockets themselves are configured by
        # services.rspamd.postfix below.
        milter_default_action = "accept";

        transport_maps = ["hash:/var/lib/mailman/data/postfix_lmtp"];
        local_recipient_maps = ["hash:/var/lib/mailman/data/postfix_lmtp"];
        relay_domains = ["hash:/var/lib/mailman/data/postfix_domains"];
      };
    };
    # DKIM signing via rspamd (opendkim is marked insecure/unmaintained in
    # nixpkgs). postfix.enable wires the rspamd milter into Postfix.
    rspamd = {
      enable = true;
      postfix.enable = true;
      locals."dkim_signing.conf".text = ''
        selector = "${dkimSelector}";
        path = "${dkimKeyDir}/$domain.$selector.key";
        # Mailman hands mail to Postfix over the loopback, so it is "local".
        sign_local = true;
        sign_authenticated = true;
        allow_username_mismatch = true;
        use_domain = "header";
      '';
    };
    mailman = {
      enable = true;
      enablePostfix = true;
      hyperkitty.enable = true;
      serve.enable = true;
      siteOwner = "postmaster@as63477.net";
      webHosts = ["lists.as63477.net"];
    };
    nginx.virtualHosts."lists.as63477.net" = {
      listen = [
        {
          addr = "[::1]";
          inherit port;
        }
      ];
    };
    caddy.virtualHosts."lists.as63477.net" = {
      extraConfig = ''
        reverse_proxy [::1]:${toString port}
      '';
    };
  };

  # Auto-generate the DKIM key on first start (runs as the rspamd user, writing
  # under its StateDirectory /var/lib/rspamd).
  systemd.services.rspamd.serviceConfig.ExecStartPre = [dkimKeygen];
}
