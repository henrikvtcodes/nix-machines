{
  config,
  pkgs,
  lib,
  ...
}: {
  services.kanidm = {
    enableServer = true;
    enableClient = true;
    serverSettings = {
      bindaddress = "[::1]:33443";
      domain = "idp.unicycl.ing";
      origin = "https://idm.unicycl.ing";
    };
  };
}
