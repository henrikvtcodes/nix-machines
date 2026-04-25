{...}: {
  systemd.network = {
    netdevs = {
      "10-virt-vbr0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "vbr0";
        };
        bridgeConfig = {
          STP = "yes";
          ForwardDelaySec = 2;
        };
      };
      # "10-virt-vrf69" = {
      #   netdevConfig = {
      #     Kind = "bridge";
      #     Name = "vbr0";
      #   };
      # };
    };
  };

  networking.vswitches = {
    "vms".interfaces = {
      "int1".name = "wlp1s0";
      "int2".name = "vbr0";
    };
  };
}
