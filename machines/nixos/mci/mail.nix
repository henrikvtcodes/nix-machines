{...}: let
  port = 18477;
in {
  services = {
    postfix = {
      enable = true;
      settings.main = {
        smtp_bind_address = "155.103.251.25";
        smtp_bind_address6 = "2602:f542:bee::25";
        smtp_bind_address_enforce = "yes";
        smtp_address_preference = "ipv6";
        transport_maps = ["hash:/var/lib/mailman/data/postfix_lmtp"];
        local_recipient_maps = ["hash:/var/lib/mailman/data/postfix_lmtp"];
        relay_domains = ["hash:/var/lib/mailman/data/postfix_domains"];
      };
    };
    mailman = {
      enable = true;
      enablePostfix = true;
      hyperkitty.enable = true;
      serve.enable = true;
      webHosts = ["lists.as63477.net"];
    };
    nginx.virtualHosts."lists.as63477.net" = {
      listen = [
        {
          addr = "::1";
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
