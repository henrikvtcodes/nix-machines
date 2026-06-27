# Routing module

Useful commands once deployed:

```sh
birdc show protocols               # session state for all peers
birdc show route                   # full RIB
birdc show route filtered          # routes rejected by import filters
systemctl start bird-irr-refresh   # force immediate IRR refresh
journalctl -u bird-irr-refresh     # bgpq4 refresh log
journalctl -u bird                 # BIRD log
```

## Roles

Roles define how routes are filtered from peers, whether they are transit, bilats, IX route servers, or anything else.

### Role options

```nix
{...} : {
roles.<name> = {
  filters        = [ "reject_bogon_prefixes" "reject_rpki_invalid" ];
  irrFilter      = false;  # prepend IRR prefix-set check before filter chain
  acceptDefault  = false;  # pre-accept 0.0.0.0/0 / ::/0 before filter chain
  enforceNexthop = false;  # call enforce_peer_nexthop(ip) per neighbor; one filter per neighbor
};
}
```

### Generated filter logic

```bird
filter <peer>_v4_import {   # or <peer>_v4_<idx>_import when enforceNexthop = true
    if is_default_route() then accept;          # only when acceptDefault = true
    if net !~ <peer>_v4 then reject;            # only when irrFilter = true and asSet set
    reject_bogon_prefixes();                    # role.filters, each called in order
    reject_bogon_asns();
    reject_long_as_path();
    reject_out_of_bounds_prefixes();
    reject_rpki_invalid();
    enforce_first_as(<asn>);                    # always, using peer's asn
    enforce_peer_nexthop(<neighbor_ip>);        # only when enforceNexthop = true
    honor_graceful_shutdown();                  # always
    accept;
}
```

### Built-in roles

| Role      | `filters`        | `irrFilter` | `acceptDefault` | `enforceNexthop` |
| --------- | ---------------- | ----------- | --------------- | ---------------- |
| `transit` | all 5 reject fns | `false`     | `true`          | `false`          |
| `peer`    | all 5 reject fns | `true`      | `false`         | `true`           |
| `ixp-rs`  | all 5 reject fns | `true`      | `false`         | `false`          |

**`transit`** accepts default routes & full table. No per-neighbor nexthop enforcement.

**`peer`** is IRR-filtered. `enforceNexthop = true` generates one named filter per neighbor address so the nexthop IP can be hardcoded per session.

**`ixp-rs`** is same as `peer` but without per-neighbor nexthop enforcement.

### Customising roles

Built-in role fields are `lib.mkDefault`, so any field can be overridden without re-specifying the rest:

```nix
# Disable acceptDefault for transit peers on this machine
my.services.routing.roles.transit.acceptDefault = false;

# Skip nexthop enforcement for peers on this machine
my.services.routing.roles.peer.enforceNexthop = false;
```

### Defining new roles

New keys are merged alongside the built-ins:

```nix
{...} : {

my.services.routing.roles.customer = {
  filters        = [ "reject_bogon_prefixes" "reject_bogon_asns" "reject_rpki_invalid" ];
  irrFilter      = true;
  acceptDefault  = false;
  enforceNexthop = true;
};

}
```

Any void function referenced in `filters` must exist in `base.conf` or be defined via `extraConfig`.

## Filter functions

All functions in `base.conf` reject internally with a log message if validation fails, otherwise they fall through. They are composed in named filter blocks generated per peer.

### Import filter functions (call these in role `filters`)

| Function                          | Rejects when                                      |
| --------------------------------- | ------------------------------------------------- |
| `reject_bogon_prefixes()`         | Prefix matches `IPV4_BOGON` or `IPV6_BOGON`       |
| `reject_bogon_asns()`             | AS path contains an ASN from `ASN_BOGON`          |
| `reject_long_as_path()`           | AS path length exceeds 50                         |
| `reject_out_of_bounds_prefixes()` | Prefix longer than /24 (v4) or /48 (v6)           |
| `reject_rpki_invalid()`           | ROA check returns `ROA_INVALID` for the origin AS |

### Enforcement functions

| Function                            | Rejects when                                                |
| ----------------------------------- | ----------------------------------------------------------- |
| `enforce_first_as(int expected)`    | First AS in path ≠ expected (hardcoded per peer from `asn`) |
| `enforce_peer_nexthop(ip expected)` | BGP next-hop ≠ expected (opt-in via role `enforceNexthop`)  |

### Attribute functions

| Function                    | Effect                                                                 |
| --------------------------- | ---------------------------------------------------------------------- |
| `honor_graceful_shutdown()` | RFC 8326: sets `bgp_local_pref = 0` when community `(65535,0)` present |

## RPKI

```nix
{...} : {
rpki = {
  enable = true;                            # default
  host   = "rtr.rpki.cloudflare.com";      # default
  port   = 8282;                            # default
};

}
```

## IRR filtering

```nix
{...}:{
irr = {
  enable          = true;         # default
  host            = "rr.ntt.net"; # default (bgpq4 -h)
  refreshInterval = "daily";      # systemd OnCalendar
  maxPrefixLenV4  = 24;
  maxPrefixLenV6  = 48;
};
}
```

## Full examples

### Dual-stack transit + peer node

```nix

{...}: {
my.services.routing = {
  enable = true;
  asn    = 63477;

  ipv4 = {
    source        = "155.103.251.1";
    machine       = "23.143.82.39";
    localPrefixes = [ "155.103.251.0/24" ];
    staticRoutes  = [{ prefix = "155.103.251.0/24"; via = "SOURCE4"; }];
  };

  ipv6 = {
    source        = "2602:f542:bee::1";
    machine       = "2602:fc26:12:1::39";
    localPrefixes = [ "2602:f542:bee::/48" ];
    staticRoutes  = [{ prefix = "2602:f542:bee::/48"; via = "SOURCE6"; }];
  };

  excludeTailscale = true;

  peers = [
    {
      name       = "up_as1003";
      role       = "transit";
      asn        = 1003;
      neighborV4 = [ "23.143.82.1" ];
      neighborV6 = [ "2602:fc26:12::1" ];
    }
    {
      name         = "pe_as215207";
      role         = "peer";
      asn          = 215207;
      asSet        = "AS-AETHERNET";
      neighborV4   = [ "23.143.82.38" ];
      neighborV6   = [ "2602:fc26:12:1::38" ];
      maxPrefixV4  = 200;
      maxPrefixV6  = 200;
    }
  ];
};

}
```

```bird
# Transit
filter up_as1003_v4_import {
    if is_default_route() then accept;
    reject_bogon_prefixes();
    reject_bogon_asns();
    reject_long_as_path();
    reject_out_of_bounds_prefixes();
    reject_rpki_invalid();
    enforce_first_as(1003);
    honor_graceful_shutdown();
    accept;
}

# Peer
filter pe_as215207_v4_1_import {
    if net !~ pe_as215207_v4 then reject;
    reject_bogon_prefixes();
    reject_bogon_asns();
    reject_long_as_path();
    reject_out_of_bounds_prefixes();
    reject_rpki_invalid();
    enforce_first_as(215207);
    enforce_peer_nexthop(23.143.82.38);
    honor_graceful_shutdown();
    accept;
}

protocol bgp up_as1003_v4_1 from base4 {
  neighbor 23.143.82.1 as 1003;
  ipv4 {
    import filter up_as1003_v4_import;
  };
}

protocol bgp pe_as215207_v4_1 from base4 {
  neighbor 23.143.82.38 as 215207;
  ipv4 {
    import filter pe_as215207_v4_1_import;
    import limit 200 action restart;
  };
}
```

### IPv6-only IXP node

```nix

{}: {
my.services.routing = {
  enable = true;
  asn    = 63477;

  # SOURCE4 is required for `router id` even on v6-only nodes
  ipv4.source = "172.16.255.2";

  ipv6 = {
    source        = "2602:f542:530::1";
    localPrefixes = [ "2602:f542:530::/48" ];
    staticRoutes  = [{ prefix = "2602:f542:530::/48"; via = "SOURCE6"; }];
  };

  excludeTailscale = true;

  peers = [
    {
      name       = "pe_vermontix";
      role       = "ixp-rs";
      asn        = 62848;
      asSet      = "AS-VERMONTIX";
      neighborV6 = [
        "2001:504:137::feed:1"
        "2001:504:137::feed:2"
      ];
    }
  ];
};
}
```

For `ixp-rs` with two neighbors and `enforceNexthop = false`, one filter covers both protocol blocks:

```bird
filter pe_vermontix_v6_import {
    if net !~ pe_vermontix_v6 then reject;
    reject_bogon_prefixes();
    ...
    enforce_first_as(62848);
    honor_graceful_shutdown();
    accept;
}

protocol bgp pe_vermontix_v6_1 from base6 { neighbor 2001:504:137::feed:1 as 62848; ... }
protocol bgp pe_vermontix_v6_2 from base6 { neighbor 2001:504:137::feed:2 as 62848; ... }
```

## Per-peer overrides

| Option                        | Default                | Effect                                                            |
| ----------------------------- | ---------------------- | ----------------------------------------------------------------- |
| `acceptDefault`               | `null` (inherits role) | `true`/`false` overrides the role's `acceptDefault` for this peer |
| `maxPrefixV4` / `maxPrefixV6` | `null`                 | Adds `import limit N action restart`                              |
| `localPref`                   | `null`                 | Overrides `default bgp_local_pref 50` for this session            |
| `multihop`                    | `null`                 | Emits `multihop N;`                                               |
| `passive`                     | `false`                | Emits `passive;`. BIRD waits for the peer to initiate             |
| `extraConfig`                 | `""`                   | Appended verbatim inside each protocol block                      |
