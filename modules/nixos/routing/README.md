# routing module

NixOS module (`my.services.routing`) that configures [BIRDv2](https://bird.network.cz/) for BGP routing with RPKI validation and IRR prefix filtering.

## How it works

The module ships two static BIRD config files and generates the machine-specific `bird.conf` from Nix options at build time.

**Static files (always installed to `/etc/bird/`):**

- `constants.conf` — bogon prefix sets (`IPV4_BOGON`, `IPV6_BOGON`, `ASN_BOGON`), private ASN set (`ASN_PRIVATE` for export stripping), the `reject_route(string reason)` internal helper, and validators: `ip_bogon()`, `is_default_route()`, `bad_prefix_len()`.
- `base.conf` — everything shared across machines: `router id SOURCE4`, RPKI ROA tables (`rpki4`/`rpki6`), all filter functions (see below), kernel/device protocols, and the BGP templates `base`/`base4`/`base6`.

**Generated `bird.conf` (order matters for BIRD2 forward-references):**

1. `define` constants: `ASN`, `SOURCE4`, `SOURCE6`, `MACHINE4`, `MACHINE6`, `LOCALv4`, `LOCALv6`
2. `protocol static static4` / `static6` — announces your own prefixes; tailscale carve-outs optional
3. `include "base.conf"` — pulls in all filter functions, kernel/device protocols, BGP templates
4. `protocol rpki { … }` — RTR session to populate `rpki4`/`rpki6` tables (optional, see RPKI section)
5. `include "/etc/bird/irr/<peer>_v{4,6}.conf"` — bgpq4-generated prefix-set defines per peer
6. Named `filter` blocks per peer (one per family, or one per neighbor when `enforceNexthop = true`)
7. `protocol bgp …` — one block per neighbor address, per peer

---

## Filter functions

All functions in `base.conf` are **void** — each rejects internally with a log message on violation and falls through otherwise. They are composed in named filter blocks generated per peer.

### Import filter functions (call these in role `filters`)

| Function | Rejects when |
|---|---|
| `reject_bogon_prefixes()` | Prefix matches `IPV4_BOGON` or `IPV6_BOGON` |
| `reject_bogon_asns()` | AS path contains an ASN from `ASN_BOGON` |
| `reject_long_as_path()` | AS path length exceeds 50 |
| `reject_out_of_bounds_prefixes()` | Prefix longer than /24 (v4) or /48 (v6) |
| `reject_rpki_invalid()` | ROA check returns `ROA_INVALID` for the origin AS |

### Enforcement functions (called automatically per peer)

| Function | Rejects when |
|---|---|
| `enforce_first_as(int expected)` | First AS in path ≠ expected (hardcoded per peer from `asn`) |
| `enforce_peer_nexthop(ip expected)` | BGP next-hop ≠ expected (opt-in via role `enforceNexthop`) |

### Attribute functions

| Function | Effect |
|---|---|
| `honor_graceful_shutdown()` | RFC 8326: sets `bgp_local_pref = 0` when community `(65535,0)` present |

---

## Roles

Every peer has a `role`. Roles are defined in the `roles` attrset and determine what filter functions are called, in what order, and how the named filter block is structured.

### Role options

```nix
roles.<name> = {
  filters        = [ "reject_bogon_prefixes" "reject_rpki_invalid" ];
  irrFilter      = false;  # prepend IRR prefix-set check before filter chain
  acceptDefault  = false;  # pre-accept 0.0.0.0/0 / ::/0 before filter chain
  enforceNexthop = false;  # call enforce_peer_nexthop(ip) per neighbor; one filter per neighbor
};
```

### Generated filter logic (per peer, per family)

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

Three roles are provided as defaults. All fields use `lib.mkDefault` so any can be overridden per-machine:

| Role | `filters` | `irrFilter` | `acceptDefault` | `enforceNexthop` |
|---|---|---|---|---|
| `transit` | all 5 reject fns | `false` | `true` | `false` |
| `peer` | all 5 reject fns | `true` | `false` | `true` |
| `ixp-rs` | all 5 reject fns | `true` | `false` | `false` |

**`transit`** — upstream providers. Pre-accepts default routes, no IRR filtering (transit carries the full DFZ). No per-neighbor nexthop enforcement (transit may use route reflectors).

**`peer`** — bilateral peers. IRR-filtered against a bgpq4-built prefix set. `enforceNexthop = true` generates one named filter per neighbor address so the nexthop IP can be hardcoded per session.

**`ixp-rs`** — IXP route servers. Same as `peer` but without per-neighbor nexthop enforcement — route servers are allowed to set arbitrary nexthops.

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
my.services.routing.roles.customer = {
  filters        = [ "reject_bogon_prefixes" "reject_bogon_asns" "reject_rpki_invalid" ];
  irrFilter      = true;
  acceptDefault  = false;
  enforceNexthop = true;
};
```

Any void function referenced in `filters` must exist in `base.conf` or be defined via `extraConfig`.

---

## RPKI

```nix
rpki = {
  enable = true;                            # default
  host   = "rtr.rpki.cloudflare.com";      # default
  port   = 8282;                            # default
};
```

When enabled, a `protocol rpki` block is emitted after `include "base.conf"`, connecting to the RTR server and populating `rpki4`/`rpki6`. The `reject_rpki_invalid()` function then rejects routes with `ROA_INVALID` origin.

When `rpki.enable = false`, the `protocol rpki` block is omitted. The `roa4`/`roa6` tables declared in `base.conf` stay empty, so `roa_check` returns `ROA_UNKNOWN` and `reject_rpki_invalid()` passes all routes. This is **fail-open** — routes are not rejected on RPKI grounds.

---

## IRR filtering

```nix
irr = {
  enable          = true;         # default
  host            = "rr.ntt.net"; # default (bgpq4 -h)
  refreshInterval = "daily";      # systemd OnCalendar
  maxPrefixLenV4  = 24;
  maxPrefixLenV6  = 48;
};
```

For each peer with an `asSet` whose role has `irrFilter = true`:

1. `systemd-tmpfiles` seeds `/etc/bird/irr/<name>_v{4,6}.conf` with `define <name>_vX = [];` if the file doesn't exist yet — empty prefix set means BIRD rejects all routes from that peer until the first successful bgpq4 run (**fail-closed bootstrap**).
2. On boot (`OnBootSec = 5min`) and on the configured schedule (`refreshInterval`), `bird-irr-refresh.service` runs `bgpq4` and atomically replaces the file, then calls `birdc configure` to reload BIRD without dropping sessions.
3. The generated filter includes `if net !~ <name>_vX then reject;` before the rest of the filter chain.

---

## Full examples

### Dual-stack transit + peer node

```nix
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
```

Generated filter blocks (excerpt):

```bird
# Transit — one filter covers all neighbors (enforceNexthop = false)
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

# Peer — one filter per neighbor (enforceNexthop = true, one neighbor → index 1)
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

---

## Per-peer overrides

| Option | Default | Effect |
|---|---|---|
| `acceptDefault` | `null` (inherits role) | `true`/`false` overrides the role's `acceptDefault` for this peer |
| `maxPrefixV4` / `maxPrefixV6` | `null` | Adds `import limit N action restart` |
| `localPref` | `null` | Overrides `default bgp_local_pref 50` for this session |
| `multihop` | `null` | Emits `multihop N;` |
| `passive` | `false` | Emits `passive;` — BIRD waits for the peer to initiate |
| `extraConfig` | `""` | Appended verbatim inside each protocol block |

---

## Runtime files

| Path | Managed by | Purpose |
|---|---|---|
| `/etc/bird/bird.conf` | NixOS (build-time) | Generated main config |
| `/etc/bird/base.conf` | NixOS (build-time) | Filter functions and BGP templates |
| `/etc/bird/constants.conf` | NixOS (build-time) | Bogon sets, validators, `reject_route()` helper |
| `/etc/bird/irr/<peer>_v4.conf` | `bird-irr-refresh.service` | bgpq4 prefix-set define for v4 |
| `/etc/bird/irr/<peer>_v6.conf` | `bird-irr-refresh.service` | bgpq4 prefix-set define for v6 |

Useful commands once deployed:

```sh
birdc show protocols               # session state for all peers
birdc show route                   # full RIB
birdc show route filtered          # routes rejected by import filters
systemctl start bird-irr-refresh   # force immediate IRR refresh
journalctl -u bird-irr-refresh     # bgpq4 refresh log
journalctl -u bird                 # BIRD log (route rejections appear here)
```
