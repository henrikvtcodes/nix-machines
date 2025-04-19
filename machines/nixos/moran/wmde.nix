{...}:{
  services = {
    libinput.touchpad = {
      tappingButtonMap = "lrm";
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
  
  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}