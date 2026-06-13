{...}: let
  port = 18477;
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

        # DKIM signing via opendkim milter (inet socket below).
        milter_default_action = "accept";
        smtpd_milters = ["inet:localhost:8891"];
        non_smtpd_milters = ["inet:localhost:8891"];

        transport_maps = ["hash:/var/lib/mailman/data/postfix_lmtp"];
        local_recipient_maps = ["hash:/var/lib/mailman/data/postfix_lmtp"];
        relay_domains = ["hash:/var/lib/mailman/data/postfix_domains"];
      };
    };
    opendkim = {
      enable = true;
      selector = "mail";
      domains = "csl:lists.as63477.net";
      # inet socket avoids unix-socket permission/chroot issues with Postfix.
      socket = "inet:8891@localhost";
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
}
