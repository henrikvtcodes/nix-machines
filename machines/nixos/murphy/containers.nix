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
      networking.defaultGateway6 = {
        address = hostAddr;
        interface = iface;
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
