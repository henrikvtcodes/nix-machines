let

  # --------- Henrik's Public Keys ---------
  # Fetch public key from https://henrikvt.com/id_ed25519.pub
  henrik_public_pubkey = builtins.readFile (builtins.fetchurl "https://henrikvt.com/id_ed25519.pub");
  # Fetch git signing key from https://github.com/henrikvtcodes.keys
  henrik_git_pubkey = builtins.readFile (builtins.fetchurl "https://github.com/henrikvtcodes.keys");
  henrik_homelab_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmZEhaLdiFJ6TdyhdBC5fvCiY5c7drQK2EVHGPCPHei";

  # --------- Systems ---------
  svalbard = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIApAfSOQUWsDCYUKaPHxO8j4Wo9xGBSlvASMRIrNLYtD";

  valcour = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUWyXkH30owx5qEz8gi6QjbPTEad2xzN7iVRO5knY8Q root@nixos";

  donso = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLNjGDW9Uzr/O5aGLipFJPFTPLsaj5UVxk1cd54dQ05";

  henrik = [
    henrik_public_pubkey
    henrik_git_pubkey
    henrik_homelab_pubkey
  ];

  users = [ ] ++ henrik;

  systems = [
    svalbard
    valcour
    donso
  ];
in
{
  "tailscaleAuthKey.age".publicKeys = users ++ systems;

  "henrikUserPassword.age".publicKeys = henrik;
}
