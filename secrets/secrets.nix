let
  # --------- Henrik's Public Keys ---------
  # Fetch public key from https://henrikvt.com/id_ed25519.pub
  henrik_public_pubkey = builtins.readFile (builtins.fetchurl "https://henrikvt.com/id_ed25519.pub");
  # Fetch git signing key from https://github.com/henrikvtcodes.keys
  henrik_git_pubkey = builtins.readFile (builtins.fetchurl "https://github.com/henrikvtcodes.keys");
  henrik_homelab_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmZEhaLdiFJ6TdyhdBC5fvCiY5c7drQK2EVHGPCPHei";

  # --------- Systems ---------
  svalbard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLF2ymnhVA2fZy9bW3AvittJllvdIhpEEJeNE1JtZ4z root@svalbard";
  valcour = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUWyXkH30owx5qEz8gi6QjbPTEad2xzN7iVRO5knY8Q root@valcour";
  donso = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0fAwr0mzV/YHFGxyc9Id5FzLE34GlVdXb4toYn0p8s root@donso";
  marstrand = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcHEGMX9Oxd+0J5sZNKtq7LHKBNxFw525NPnhh5Ewr2 root@marstrand";
  barnegat = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpfaMerK8+qEPKyuF5V0tCMhu797kmw3knLmXTkQtTT root@barnegat";
  ashokan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxUwEDsGw3KJJhe3f+pxeGVLNs8NkhDxen9Fuwocl6p root@ashokan";
  penikese = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHtuT1HokTm346l4GRdj7WNylz8UQWa4Ycd4hFBidD+ root@penikese";
  moran = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVce/XCWvap7McnE4YmT9yrur4UN7r/y6GMW0Oe0Led root@moran";

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
    penikese
    moran
  ];
in {
  "tailscaleAuthKey.age".publicKeys = users ++ systems;

  "henrikUserPassword.age".publicKeys = henrik ++ [moran];

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

  "netboxSecretKey.age".publicKeys = [ashokan] ++ henrik;
  "mastodonSmtpPassword.age".publicKeys = [ashokan] ++ henrik;
  "mastodonSecretKeyBase.age".publicKeys = [ashokan] ++ henrik;
  "mastodonOtpSecret.age".publicKeys = [ashokan] ++ henrik;
  # Active Record DB Encryption
  "mastodonAREncryptionEnvVars.age".publicKeys = [ashokan] ++ henrik;
  "mastodonVapidEnvVars.age".publicKeys = [ashokan] ++ henrik;
  "jortageSecretEnvVars.age".publicKeys = [ashokan] ++ henrik;
  

  "valcourUnpollerPassword.age".publicKeys = [valcour] ++ henrik;

  "uvmGitlabToken.age".publicKeys = henrik;

  "aristaEapiConf.age".publicKeys = [valcour] ++ henrik;
}
