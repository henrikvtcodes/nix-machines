{config, ...}: let
  domain = "unicycl.ing";
in {
  services.kanidm = {
    enableServer = true;
    serverSettings = {
      origin = "https://idp.${domain}";
      inherit domain;
      bindaddress = "[::]:33443";
      ldapbindaddress = "[::]:33636";
    };
  };
}
