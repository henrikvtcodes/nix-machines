{pkgs, ...}: {
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    hyprlock.enable = true;
    regreet = {
      enable = true;
    };

    waybar.enable = true;
  };


  services = {
    hypridle.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${pkgs.hyprland}/share/wayland-sessions";
          user = "greeter";
        };
      };
    };
  };

  users.users.greeter = {
    isNormalUser = false;
    description = "greetd greeter user";
    extraGroups = ["video" "audio"];
    linger = true;
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock = {};
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      pyprland
      hyprpicker
      hyprcursor
      hyprlock
      hypridle
      hyprpaper

      kitty

      tuigreet
    ];
  };
}
