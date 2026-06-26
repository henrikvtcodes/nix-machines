{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.services.routing;

  staticRouteSubmodule = lib.types.submodule (_: {
    options = with lib; {
      prefix = mkOption {type = types.str;};
      via = mkOption {type = types.str;};
    };
  });

  familySubmodule = lib.types.submodule (_: {
    options = with lib; {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      source = mkOption {
        type = types.str;
        description = "Source address used as router ID / krt_prefsrc (SOURCE4 or SOURCE6).";
      };
      machine = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Machine address (MACHINE4 or MACHINE6).";
      };
      localPrefixes = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Local prefixes for this address family (LOCALv4 or LOCALv6).";
      };
      staticRoutes = mkOption {
        type = types.listOf staticRouteSubmodule;
        default = [];
        description = "Static routes to announce for this family.";
      };
    };
  });

  roleSubmodule = lib.types.submodule (_: {
    options = with lib; {
      filters = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Void BIRD filter functions to call in sequence (no args). Each rejects internally on violation and falls through otherwise.";
      };
      irrFilter = mkOption {
        type = types.bool;
        default = false;
        description = "Prepend an IRR prefix-set check (net !~ <peer>_vX) before the filter chain. Requires asSet on each peer using this role.";
      };
      acceptDefault = mkOption {
        type = types.bool;
        default = false;
        description = "Pre-accept default routes (0.0.0.0/0 and ::/0) before the filter chain.";
      };
      enforceNexthop = mkOption {
        type = types.bool;
        default = false;
        description = "Emit enforce_peer_nexthop(<ip>) per neighbor address. Generates one named filter per neighbor address rather than one per peer.";
      };
    };
  });

  peerSubmodule = lib.types.submodule (_: {
    options = with lib; {
      name = mkOption {
        type = types.str;
        description = "Protocol name stem. Must be a valid BIRD identifier. Used in protocol names, filter names, IRR defines, and irr filenames.";
      };
      role = mkOption {
        type = types.str;
        description = "Role name. Must match a key in roles (built-in or user-defined).";
      };
      asn = mkOption {
        type = types.int;
        description = "Remote AS number.";
      };
      neighborV4 = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "IPv4 neighbor addresses. One protocol block is generated per address.";
      };
      neighborV6 = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "IPv6 neighbor addresses. One protocol block is generated per address.";
      };
      asSet = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "AS-SET or ASN for bgpq4 IRR filtering. Required when the peer's role has irrFilter = true.";
      };
      acceptDefault = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Override the role's acceptDefault for this peer. Null inherits from the role.";
      };
      maxPrefixV4 = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Import limit for IPv4 prefixes (import limit N action restart).";
      };
      maxPrefixV6 = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Import limit for IPv6 prefixes (import limit N action restart).";
      };
      localPref = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "Per-peer override of the default bgp_local_pref (50).";
      };
      multihop = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "BGP multihop TTL.";
      };
      passive = mkOption {
        type = types.bool;
        default = false;
        description = "Passive BGP session (do not initiate connections).";
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra BIRD configuration appended inside each protocol block for this peer.";
      };
    };
  });

  # ── Config generation helpers ──────────────────────────────────────────────

  opt = cond: s:
    if cond
    then s
    else "";

  mkPrefixList = prefixes:
    if prefixes == []
    then "[]"
    else "[\n" + lib.concatStringsSep ",\n" (map (p: "    ${p}") prefixes) + "\n]";

  mkStaticRoutes = routes:
    lib.concatMapStrings (r: "  route ${r.prefix} via ${r.via};\n") routes;

  # ── Named filter generation ────────────────────────────────────────────────
  # Each peer gets one named filter per family (or one per neighbor address when
  # role.enforceNexthop = true). Filters are emitted before protocol blocks.

  # Name of the BIRD filter for a peer, family, and optional neighbor index.
  # idx is non-null only when role.enforceNexthop = true.
  mkFilterName = peer: family: idx:
    if idx != null
    then "${peer.name}_${family}_${toString idx}_import"
    else "${peer.name}_${family}_import";

  # Ordered lines of the filter body for a peer, family, and optional neighbor IP.
  mkFilterLines = peer: family: neighborIp: let
    role = cfg.roles.${peer.role};
    acceptDef =
      if peer.acceptDefault != null
      then peer.acceptDefault
      else role.acceptDefault;
    irrSet = "${peer.name}_${family}";
  in
    lib.optional acceptDef "if is_default_route() then accept;"
    ++ lib.optional (role.irrFilter && peer.asSet != null) "if net !~ ${irrSet} then reject;"
    ++ map (fn: "${fn}();") role.filters
    ++ ["enforce_first_as(${toString peer.asn});"]
    ++ lib.optional (role.enforceNexthop && neighborIp != null)
    "enforce_peer_nexthop(${neighborIp});"
    ++ ["honor_graceful_shutdown();"]
    ++ ["accept;"];

  # One named filter block.
  mkFilterBlock = peer: family: idx: neighborIp: let
    name = mkFilterName peer family idx;
    lines = mkFilterLines peer family neighborIp;
  in ''
    filter ${name} {
        ${lib.concatStringsSep "\n    " lines}
    }
  '';

  # All named filter blocks for one peer (both families).
  mkPeerFilterBlocks = peer: let
    role = cfg.roles.${peer.role};
    mkFamilyFilters = family: neighbors:
      if role.enforceNexthop
      then lib.concatStrings (lib.imap1 (idx: ip: mkFilterBlock peer family idx ip) neighbors)
      else mkFilterBlock peer family null null;
  in
    opt (cfg.ipv4.enable && peer.neighborV4 != []) (mkFamilyFilters "v4" peer.neighborV4)
    + opt (cfg.ipv6.enable && peer.neighborV6 != []) (mkFamilyFilters "v6" peer.neighborV6);

  # ── Protocol block generation ──────────────────────────────────────────────

  mkBgpProtocol = peer: family: idx: neighborIp: let
    role = cfg.roles.${peer.role};
    template =
      if family == "v4"
      then "base4"
      else "base6";
    afFamily =
      if family == "v4"
      then "ipv4"
      else "ipv6";
    maxPrefix =
      if family == "v4"
      then peer.maxPrefixV4
      else peer.maxPrefixV6;
    protName = "${peer.name}_${family}_${toString idx}";
    importFilter = mkFilterName peer family (
      if role.enforceNexthop
      then idx
      else null
    );
  in
    "protocol bgp ${protName} from ${template} {\n"
    + "  neighbor ${neighborIp} as ${toString peer.asn};\n"
    + opt (peer.multihop != null) "  multihop ${toString peer.multihop};\n"
    + opt peer.passive "  passive;\n"
    + opt (peer.localPref != null) "  default bgp_local_pref ${toString peer.localPref};\n"
    + "  ${afFamily} {\n"
    + "    import filter ${importFilter};\n"
    + opt (maxPrefix != null) "    import limit ${toString maxPrefix} action restart;\n"
    + "  };\n"
    + opt (peer.extraConfig != "") "${peer.extraConfig}\n"
    + "}\n\n";

  mkPeerProtocols = peer:
    lib.concatStrings (
      lib.optionals cfg.ipv4.enable (lib.imap1 (mkBgpProtocol peer "v4") peer.neighborV4)
      ++ lib.optionals cfg.ipv6.enable (lib.imap1 (mkBgpProtocol peer "v6") peer.neighborV6)
    );

  # IRR include lines for a peer (only when irr.enable and peer has asSet)
  mkIrrIncludes = peer:
    lib.concatStringsSep "\n" (
      lib.optional (cfg.ipv4.enable && peer.neighborV4 != [])
      ''include "/var/lib/bird/irr/${peer.name}_v4.conf";''
      ++ lib.optional (cfg.ipv6.enable && peer.neighborV6 != [])
      ''include "/var/lib/bird/irr/${peer.name}_v6.conf";''
    );

  # ── Full generated bird.conf ───────────────────────────────────────────────

  birdConfig = let
    defines = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
      "define ASN = ${toString cfg.asn};"
      (opt cfg.ipv4.enable "define SOURCE4 = ${cfg.ipv4.source};")
      (opt cfg.ipv6.enable "define SOURCE6 = ${cfg.ipv6.source};")
      (opt (cfg.ipv4.enable && cfg.ipv4.machine != null) "define MACHINE4 = ${cfg.ipv4.machine};")
      (opt (cfg.ipv6.enable && cfg.ipv6.machine != null) "define MACHINE6 = ${cfg.ipv6.machine};")
      (opt cfg.ipv4.enable "define LOCALv4 = ${mkPrefixList cfg.ipv4.localPrefixes};")
      (opt cfg.ipv6.enable "define LOCALv6 = ${mkPrefixList cfg.ipv6.localPrefixes};")
    ]);

    static4 = opt cfg.ipv4.enable ''
      protocol static static4 {
        ipv4 {};
      ${mkStaticRoutes cfg.ipv4.staticRoutes}}
    '';

    static6 = opt cfg.ipv6.enable ''
      protocol static static6 {
        ipv6 {};
      ${mkStaticRoutes cfg.ipv6.staticRoutes}}
    '';

    tailscaleStatics = opt cfg.excludeTailscale ''
      protocol static tailscale4 {
        ipv4;
        route 100.64.0.0/10 via "tailscale0";
      }

      protocol static tailscale6 {
        ipv6;
        route fd7a:115c:a1e0::/48 via "tailscale0";
      }
    '';

    rpkiBlock = opt cfg.rpki.enable ''
      protocol rpki {
        roa4 { table rpki4; };
        roa6 { table rpki6; };

        transport tcp;
        remote "${cfg.rpki.host}" port ${toString cfg.rpki.port};

        retry keep 90;
        refresh keep 900;
        expire keep 172800;
      }
    '';

    irrIncludes = opt cfg.irr.enable (
      lib.concatStringsSep "\n"
      (map mkIrrIncludes (lib.filter (p: p.asSet != null) cfg.peers))
    );

    namedFilters = lib.concatStrings (map mkPeerFilterBlocks cfg.peers);

    peerBlocks = lib.concatStrings (map mkPeerProtocols cfg.peers);
  in
    lib.concatStringsSep "\n" (lib.filter (s: s != "") [
      defines
      static4
      static6
      tailscaleStatics
      ''include "base.conf";''
      rpkiBlock
      irrIncludes
      namedFilters
      peerBlocks
      cfg.extraConfig
    ]);

  # ── bgpq4 refresh ─────────────────────────────────────────────────────────

  irrPeers = lib.filter (p: p.asSet != null) cfg.peers;
  hasIrrPeers = cfg.irr.enable && irrPeers != [];

  irrRefreshScript = let
    bgpq4 = "${pkgs.bgpq4}/bin/bgpq4";
    birdc = "${pkgs.bird2}/bin/birdc";
    irrDir = "/var/lib/bird/irr";
    mkPeerRefresh = peer: let
      v4 = opt (cfg.ipv4.enable && peer.neighborV4 != []) ''
        tmp=$(mktemp)
        if ${bgpq4} -h ${cfg.irr.host} -4 -A -b -m ${toString cfg.irr.maxPrefixLenV4} -l ${peer.name}_v4 ${peer.asSet} > "$tmp"; then
          mv "$tmp" ${irrDir}/${peer.name}_v4.conf
          echo "Updated ${peer.name} v4 prefixes"
        else
          echo "bgpq4 failed for ${peer.name} v4, keeping existing" >&2
          rm -f "$tmp"
        fi
      '';
      v6 = opt (cfg.ipv6.enable && peer.neighborV6 != []) ''
        tmp=$(mktemp)
        if ${bgpq4} -h ${cfg.irr.host} -6 -A -b -m ${toString cfg.irr.maxPrefixLenV6} -l ${peer.name}_v6 ${peer.asSet} > "$tmp"; then
          mv "$tmp" ${irrDir}/${peer.name}_v6.conf
          echo "Updated ${peer.name} v6 prefixes"
        else
          echo "bgpq4 failed for ${peer.name} v6, keeping existing" >&2
          rm -f "$tmp"
        fi
      '';
    in
      v4 + v6;
  in ''
    set -euo pipefail
    mkdir -p ${irrDir}
    ${lib.concatStrings (map mkPeerRefresh irrPeers)}
    ${birdc} configure
  '';

  irrTmpfiles =
    lib.concatMap (
      peer:
        lib.optional (cfg.ipv4.enable && peer.neighborV4 != [])
        "f /var/lib/bird/irr/${peer.name}_v4.conf 0640 bird bird - define ${peer.name}_v4 = [];"
        ++ lib.optional (cfg.ipv6.enable && peer.neighborV6 != [])
        "f /var/lib/bird/irr/${peer.name}_v6.conf 0640 bird bird - define ${peer.name}_v6 = [];"
    )
    irrPeers;
in {
  options.my.services.routing = with lib; {
    enable = mkEnableOption "BIRD2 BGP routing";

    asn = mkOption {
      type = types.int;
      description = "Local AS number.";
    };

    ipv4 = mkOption {
      type = familySubmodule;
      default = {};
      description = "IPv4 family configuration. source is required when enable = true.";
    };

    ipv6 = mkOption {
      type = familySubmodule;
      default = {};
      description = "IPv6 family configuration. source is required when enable = true.";
    };

    rpki = mkOption {
      type = types.submodule (_: {
        options = with lib; {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Emit protocol rpki block. When false, ROA tables stay empty and reject_rpki_invalid() is fail-open.";
          };
          host = mkOption {
            type = types.str;
            default = "rtr.rpki.cloudflare.com";
            description = "RTR server hostname.";
          };
          port = mkOption {
            type = types.int;
            default = 8282;
            description = "RTR server port.";
          };
        };
      });
      default = {};
      description = "RPKI validation configuration.";
    };

    irr = mkOption {
      type = types.submodule (_: {
        options = with lib; {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Enable bgpq4-based IRR prefix filtering for peers with asSet.";
          };
          host = mkOption {
            type = types.str;
            default = "rr.ntt.net";
            description = "IRR host for bgpq4 (-h flag).";
          };
          refreshInterval = mkOption {
            type = types.str;
            default = "daily";
            description = "systemd OnCalendar value for the IRR refresh timer.";
          };
          maxPrefixLenV4 = mkOption {
            type = types.int;
            default = 24;
            description = "Maximum IPv4 prefix length passed to bgpq4 (-m).";
          };
          maxPrefixLenV6 = mkOption {
            type = types.int;
            default = 48;
            description = "Maximum IPv6 prefix length passed to bgpq4 (-m).";
          };
        };
      });
      default = {};
      description = "IRR prefix filtering via bgpq4.";
    };

    roles = mkOption {
      type = types.attrsOf roleSubmodule;
      default = {};
      description = ''
        Role definitions. Built-in roles (transit, peer, ixp-rs) are set as defaults
        and can be overridden field-by-field. New role names are merged in alongside them.
      '';
    };

    excludeTailscale = mkEnableOption "Carve out Tailscale address ranges from BIRD (100.64.0.0/10, fd7a:115c:a1e0::/48)";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra BIRD configuration appended verbatim to the generated bird.conf.";
    };

    peers = mkOption {
      type = types.listOf peerSubmodule;
      default = [];
      description = "BGP peers. Each peer generates one named import filter and one or more protocol blocks.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Built-in role defaults — overridable field-by-field via my.services.routing.roles.<name>
    my.services.routing.roles = {
      transit = {
        filters = lib.mkDefault [
          "reject_bogon_prefixes"
          "reject_bogon_asns"
          "reject_long_as_path"
          "reject_out_of_bounds_prefixes"
          "reject_rpki_invalid"
        ];
        irrFilter = lib.mkDefault false;
        acceptDefault = lib.mkDefault true;
        enforceNexthop = lib.mkDefault false;
      };
      peer = {
        filters = lib.mkDefault [
          "reject_bogon_prefixes"
          "reject_bogon_asns"
          "reject_long_as_path"
          "reject_out_of_bounds_prefixes"
          "reject_rpki_invalid"
        ];
        irrFilter = lib.mkDefault true;
        acceptDefault = lib.mkDefault false;
        enforceNexthop = lib.mkDefault true;
      };
      "ixp-rs" = {
        filters = lib.mkDefault [
          "reject_bogon_prefixes"
          "reject_bogon_asns"
          "reject_long_as_path"
          "reject_out_of_bounds_prefixes"
          "reject_rpki_invalid"
        ];
        irrFilter = lib.mkDefault true;
        acceptDefault = lib.mkDefault false;
        enforceNexthop = lib.mkDefault false;
      };
    };

    assertions =
      lib.concatMap (peer: [
        {
          assertion = peer.neighborV4 != [] || peer.neighborV6 != [];
          message = "routing: peer '${peer.name}' must have at least one neighborV4 or neighborV6";
        }
        {
          assertion = cfg.roles ? ${peer.role};
          message = "routing: peer '${peer.name}' references unknown role '${peer.role}'";
        }
        {
          assertion =
            !(
              cfg.roles ? ${peer.role}
              && (cfg.roles.${peer.role}).irrFilter
              && cfg.irr.enable
              && peer.asSet == null
            );
          message = "routing: peer '${peer.name}' uses role '${peer.role}' (irrFilter = true) but has no asSet";
        }
      ])
      cfg.peers;

    environment.etc."bird/constants.conf".source = ./constants.conf;
    environment.etc."bird/base.conf".source = ./base.conf;

    services.bird = {
      enable = true;
      package = pkgs.bird2;
      config = birdConfig;
      checkConfig = false;
    };

    systemd.services.bird.reloadTriggers = [
      config.environment.etc."bird/base.conf".source
      config.environment.etc."bird/constants.conf".source
    ];

    boot.kernel.sysctl = {
      "net.core.rmem_default" = 4194304;
      "net.core.rmem_max" = 4194304;
    };

    systemd.services.bird-irr-refresh = lib.mkIf hasIrrPeers {
      description = "Refresh BIRD IRR prefix lists via bgpq4";
      after = ["network-online.target" "bird.service"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "bird";
        Group = "bird";
        ExecStart = "${pkgs.writeShellScript "bird-irr-refresh" irrRefreshScript}";
      };
    };

    systemd.timers.bird-irr-refresh = lib.mkIf hasIrrPeers {
      description = "Timer for BIRD IRR prefix list refresh";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.irr.refreshInterval;
        OnBootSec = "5min";
        Persistent = true;
      };
    };

    systemd.tmpfiles.rules =
      lib.mkIf hasIrrPeers
      (["d /var/lib/bird/irr 0750 bird bird -"] ++ irrTmpfiles);

    environment.systemPackages = lib.mkIf hasIrrPeers [pkgs.bgpq4];
  };
}
