{config, ...}: {
  systemd.services.knot.reloadTriggers = [
    config.environment.etc."knot/knot.conf".source
    ./251.103.155.in-addr.arpa.zone
    ./0.2.4.5.f.2.0.6.2.ip6.arpa.zone
    ./d.0.0.f.c.b.f.2.0.6.2.ip6.arpa.zone
  ];

  services.knot = {
    enable = true;
    settings = {
      server = {
        listen = ["155.103.251.53@53" "2602:f542:bee::53@53"];
      };
      mod-synthrecord = [
        {
          id = "pine-1-rdns";
          type = "reverse";
          origin = "rdns4.static.as63477.net";
          network = "155.103.251.0/24";
          ttl = 3600;
        }
        {
          id = "spruce-1-rdns";
          type = "reverse";
          origin = "rdns6.static.as63477.net";
          network = "2602:F542::/36";
          ttl = 3600;
        }
        {
          id = "aethernet-bns-1-rdns";
          type = "reverse";
          origin = "rdns6.static.as215207.net";
          network = "2602:FBCF:D0::/44";
          ttl = 3600;
        }
      ];
      remote = [
        {
          id = "nsglobal-collector";
          address = [
            "204.87.183.53"
            "2607:7c80:54:6::53"
          ];
        }
      ];
      acl = [
        {
          id = "nsglobal-axfr";
          remote = ["nsglobal-collector"];
          action = ["transfer"];
        }
      ];
      zone = [
        {
          domain = "251.103.155.in-addr.arpa";
          file = ./251.103.155.in-addr.arpa.zone;
          module = "mod-synthrecord/pine-1-rdns";
          acl = ["nsglobal-axfr"];
          notify = ["nsglobal-collector"];
        }
        {
          domain = "0.2.4.5.f.2.0.6.2.ip6.arpa";
          file = ./0.2.4.5.f.2.0.6.2.ip6.arpa.zone;
          module = "mod-synthrecord/spruce-1-rdns";
          acl = ["nsglobal-axfr"];
          notify = ["nsglobal-collector"];
        }
        {
          domain = "d.0.0.f.c.b.f.2.0.6.2.ip6.arpa";
          file = ./d.0.0.f.c.b.f.2.0.6.2.ip6.arpa.zone;
          module = "mod-synthrecord/aethernet-bns-1-rdns";
        }
      ];
    };
  };
}
