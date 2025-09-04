{config, ...}: {
  services.netbird.server = {
    coturn = {
      enable = true;
      useAcmeCertificates = true;
      domain = "turn.nyc.unicycl.ing";
      passwordFile = config.age.secrets.netbirdTurnUserPassword.path;
    };
  };
}
