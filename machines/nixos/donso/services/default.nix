{ ... }:
{
  services.paperless = {
    enable = true;
    dataDir = "/data/main/paperless";
    address = "0.0.0.0";
    port = 6443;
  };
}
