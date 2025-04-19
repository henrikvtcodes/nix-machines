{...}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

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
    greetd = {
      enable = true;
    };
  };

  programs = {
    regreet = {
      enable = true;
    };
  };

  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
