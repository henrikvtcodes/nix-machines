let
  # --------- Henrik's Public Keys ---------
  # Fetch public key from https://henrikvt.com/id_ed25519.pub
  henrik_public_pubkey = builtins.readFile (builtins.fetchurl "https://henrikvt.com/id_ed25519.pub");
  # Fetch git signing key from https://github.com/henrikvtcodes.keys
  henrik_git_pubkey = builtins.readFile (builtins.fetchurl "https://github.com/henrikvtcodes.keys");
  henrik_homelab_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmZEhaLdiFJ6TdyhdBC5fvCiY5c7drQK2EVHGPCPHei";

  # --------- Systems ---------
  svalbard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLF2ymnhVA2fZy9bW3AvittJllvdIhpEEJeNE1JtZ4z";
  valcour = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUWyXkH30owx5qEz8gi6QjbPTEad2xzN7iVRO5knY8Q";
  donso = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0fAwr0mzV/YHFGxyc9Id5FzLE34GlVdXb4toYn0p8s";
  marstrand = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcHEGMX9Oxd+0J5sZNKtq7LHKBNxFw525NPnhh5Ewr2";
  barnegat = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpfaMerK8+qEPKyuF5V0tCMhu797kmw3knLmXTkQtTT";
  ashokan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDC34CtI9ZTBPF8d01dCaQ8pj1fYnXpaZVT5IDv2w8KU";

  henrik = [
    henrik_public_pubkey
    henrik_git_pubkey
    henrik_homelab_pubkey
  ];

  users = [] ++ henrik;

  systems = [
    svalbard
    valcour
    donso
    marstrand
    barnegat
    ashokan
  ];
in {
  "tailscaleAuthKey.age".publicKeys = users ++ systems;

  "henrikUserPassword.age".publicKeys = henrik;

  "svalbardHealthcheckUrl.age".publicKeys = [svalbard] ++ henrik;
  "valcourHealthcheckUrl.age".publicKeys = [valcour] ++ henrik;

  "cfDnsApiToken.age".publicKeys = [barnegat ashokan] ++ henrik;
  "ciServerSecrets.age".publicKeys = [barnegat] ++ henrik;
  "ciAgentSecrets.age".publicKeys =
    [
      marstrand
      barnegat
    ]
    ++ henrik;

  "mastodonSmtpPassword.age".publicKeys = [ashokan] ++ henrik;
}
