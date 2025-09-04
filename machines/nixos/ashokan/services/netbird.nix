{config, ...}: {
  services.netbird.server = {
    coturn = {
      enable = true;
      useAcmeCertificates = true;
      domain = "turn.ash.unicycl.ing";
      passwordFile = config.age.secrets.netbirdTurnUserPassword.path;
    };
  };
}
