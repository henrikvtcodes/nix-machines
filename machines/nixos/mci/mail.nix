{
  pkgs,
  config,
  ...
}: let
  port = 18477;
  mailHost = "mx.mci.as63477.net";
  listDomain = "lists.as63477.net";

  dkimSelector = "mail";
  dkimKeyDir = "/var/lib/rspamd/dkim";
  dkimKey = "${dkimKeyDir}/${listDomain}.${dkimSelector}.key";
  # Generate the DKIM keypair on the host on first start if absent. The private
  # key stays on the host (never committed); the public record is written next
  # to it as a .txt for publishing in DNS.
  dkimKeygen = pkgs.writeShellScript "rspamd-dkim-keygen" ''
    set -eu
    install -d -m 0700 "${dkimKeyDir}"
    if [ ! -f "${dkimKey}" ]; then
      ${pkgs.rspamd}/bin/rspamadm dkim_keygen \
        -s "${dkimSelector}" -d "${listDomain}" -k "${dkimKey}" \
        > "${dkimKeyDir}/${listDomain}.${dkimSelector}.txt"
    fi
  '';
in {
  services = {
    postfix = {
      enable = true;

      # Secure submission endpoints reusing the ACME cert (smtpd_tls_chain_files
      # below). No SASL auth is configured, so these do not provide
      # authenticated outbound relay; Postfix's default relay restrictions keep
      # them from being an open relay. To allow authenticated client relay
      # later, add a SASL backend (e.g. Dovecot) and set smtpd_sasl_auth_enable.
      enableSubmission = true; # 587, STARTTLS
      enableSubmissions = true; # 465, implicit TLS (wrappermode)
      submissionOptions = {
        smtpd_tls_security_level = "encrypt";
        smtpd_sasl_auth_enable = "no";
        milter_macro_daemon_name = "ORIGINATING";
      };
      submissionsOptions = {
        smtpd_sasl_auth_enable = "no";
        milter_macro_daemon_name = "ORIGINATING";
      };

      settings.main = {
        # Identity: HELO/EHLO as an FQDN that matches the PTR of the
        # sending IPs (mx.mci.as63477.net -> .25, both v4 and v6).
        myhostname = mailHost;
        # Locally-generated mail (bounces, root/cron) gets a sender domain
        # that has SPF coverage.
        myorigin = listDomain;

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

        # Inbound STARTTLS using the ACME cert below. full.pem is the private
        # key concatenated with the full chain, as expected by chain_files.
        # Opportunistic ("may"): offer TLS but still accept plaintext so mail
        # is never bounced for lack of TLS.
        smtpd_tls_chain_files = ["/var/lib/acme/${mailHost}/full.pem"];
        smtpd_tls_security_level = "may";

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
      siteOwner = "postmaster@lists.as63477.net";
      webHosts = [listDomain];
    };
    nginx.virtualHosts."${listDomain}" = {
      listen = [
        {
          addr = "[::1]";
          inherit port;
        }
      ];
    };
    caddy.virtualHosts."${listDomain}" = {
      extraConfig = ''
        reverse_proxy [::1]:${toString port}
      '';
    };
  };

  # Auto-generate the DKIM key on first start (runs as the rspamd user, writing
  # under its StateDirectory /var/lib/rspamd).
  systemd.services.rspamd.serviceConfig.ExecStartPre = [dkimKeygen];

  # TLS certificate for the mail host, issued via ACME DNS-01 over Cloudflare
  # (reuses the cfDnsApiToken secret declared by the caddy module). DNS-01
  # needs no inbound ports. The cert is group-readable by postfix, and postfix
  # is reloaded when the cert renews.
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@unicycl.ing";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cfDnsApiToken.path;
    };
    certs.${mailHost} = {
      group = "postfix";
      reloadServices = ["postfix.service"];
    };
  };
}
