{lib, ...}: let
  hostAddr = "2602:f542:70::1"; # murphy's loopback address
  mk = {
    iface,
    addr,
  }: {
    autoStart = true;
    privateNetwork = true;
    extraVeths.${iface} = {
      hostAddress6 = hostAddr;
      localAddress6 = addr;
    };
    config = {...}: {
      system.stateVersion = "25.11";
      networking.useHostResolvConf = lib.mkForce false;
      # networking.defaultGateway6 did not install a route for the extra veth,
      # so configure the interface with networkd instead.
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."40-${iface}" = {
        matchConfig.Name = iface;
        address = ["${addr}/128"];
        routes = [
          {
            Gateway = hostAddr;
            GatewayOnLink = true; # our address is a /128, so the gateway isn't in a connected prefix
          }
        ];
        networkConfig = {
          IPv6AcceptRA = false;
          LinkLocalAddressing = "ipv6";
        };
      };
    };
  };
in {
  containers.nettest1 = mk {
    iface = "nt1";
    addr = "2602:f542:70::100:1";
  };
  containers.nettest2 = mk {
    iface = "nt2";
    addr = "2602:f542:70::100:2";
  };
}
