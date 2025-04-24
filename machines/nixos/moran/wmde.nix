{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # programs.uwsm.enable = true;

  programs.hyprlock.enable = true;

  services = {
    hypridle.enable = true;
    # blueman.enable = true;
    # libinput.enable = true;
    # libinput.touchpad = {
    #   tappingButtonMap = "lrm";
    # };
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
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time --time-format '%I:%M %p | %a • %h | %F' \
          --cmd 'uwsm start hyprland'";
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

  programs.waybar.enable = true;

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

  environment.systemPackages = with pkgs; [
    pyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper

    kitty

    greetd.tuigreet
  ];
}
