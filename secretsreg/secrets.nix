let
  # Fetch public key from https://henrikvt.com/id_ed25519.pub
  henrik_public_pubkey = builtins.readFile (builtins.fetchurl "https://henrikvt.com/id_ed25519.pub");

  # Fetch git signing key from https://github.com/henrikvtcodes.keys
  henrik_git_pubkey = builtins.readFile (builtins.fetchurl "https://github.com/henrikvtcodes.keys");

  henrik_homelab_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmZEhaLdiFJ6TdyhdBC5fvCiY5c7drQK2EVHGPCPHei";

  svalbard = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVakorGdO+dvFRvqe6L9e5LVW2i4/dWuIceku3hPvLg/dM76T8wfncdZfduV4NRfRJ8uygFqL32UvkF4k1Q+w7edQpCayU1BCEgF4XR3/vSVIw8Th9nf0RLbfHKzTayFfZO7++R8wm+njzu4viXVvSFOF0QnTtxjnvk7dLxthgOSw6eUx9BIVfl7c9NcphMKLZtwrYVm7/Kq9js9LRLm86CZh9Cyrk57cwLOfZmKbNbSF7KNMN/ADNvdZ6KMNIUNHgsJyWKWM/D51eio/qReix/8C161oEUn1FG6F7OwL/esFP/QrQuNU6vyqWzobN9NzALS/tWBIteWmH+Hb1MK34DSqEpJF8DRXso5PcIvimW9QVsKTpb9dU/K4FWswjLC+NmhAbY2SjuTDbEUHiYwJDVyjxVw4ELjTjfYILLT9AUZ8lzBOQKLsKVl4gpOTcRPLG1L0o0vCK6Uo9SFSqc/WD9Mp687T1yLtT2GI0BlBl2SgZDrmMkfqebTB8S4ecdehSgUaq9ajR4ZXN04TF2hF+BnhBZ8rpTSrNQ8qvNxlym2uUru2E/MXMMYmH5cdRduLxOrKRTsNTV9dAXH77gAmgzVULbl1AB4oMMqZcvE4BCvo4khvqG0AF7pFD6s1/GDu1DWNtjljZTv4ptEwTPA2pWlKJvoosgXJksW/YVcak1w==";

  doghouse = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMUWyXkH30owx5qEz8gi6QjbPTEad2xzN7iVRO5knY8Q root@nixos";

  henrik = [
    henrik_public_pubkey
    henrik_git_pubkey
    henrik_homelab_pubkey
  ];

  users = [ ] ++ henrik;

  systems = [
    svalbard
    doghouse
  ];
in
{
  "tailscaleAuthKey.age".publicKeys = users ++ systems;

  "henrikUserPassword.age".publicKeys = henrik;
}
