{pkgs, ...}: {
  programs = {
    hyprlock = {
      enable = true;
      settings = {
        auth = {
          "fingerprint:enabled" = true;
        };
      };
    };
  };

  home.packages = with pkgs; [
    grim
    hyprpicker
    # hyprsysteminfo
    playerctl
    # slurp
    wayland-pipewire-idle-inhibit
    wl-clipboard-rs
    wl-clip-persist
  ];

  services = {
    hypridle.enable = true;
    hyprpaper.enable = true;
    network-manager-applet.enable = true;
    blueman-applet.enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      input = {
        kb_model = "pc104";
        kb_options = "kb_options";
        natural_scroll = true;

        touchpad = {
          disable_while_typing = false;
          natural_scroll = true;
          clickfinger_behavior = true;
        };
      };
    };
  };
}
