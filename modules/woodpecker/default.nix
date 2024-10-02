{ config, lib, ... }:
{
  imports = [
    ./server.nix
    ./agent.nix
  ];
}
