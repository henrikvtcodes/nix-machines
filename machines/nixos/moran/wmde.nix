{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # programs.uwsm.enable = true;

  services = {
    blueman.enable = true;
    libinput.enable = true;
    libinput.touchpad = {
      tappingButtonMap = "lrm";
    };
    # xserver = {
    #   enable = true;
    #   xkb = {
    #     layout = "us";
    #     variant = "";
    #   };
    # };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet";
          user = "greeter";
        };
      };
    };
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock = {};
  };

  # programs = {
  #   regreet = {
  #     enable = true;
  #   };
  # };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
