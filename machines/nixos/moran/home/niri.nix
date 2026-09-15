{
  lib,
  pkgs,
  ...
}: {
  programs.niri.settings = {
    input = {
      keyboard.xkb.layout = "us";
      touchpad = {
        natural-scroll = true;
        click-method = "clickfinger";
        dwt = false;
      };
    };

    layout = {
      gaps = 0;
      # full-width columns, closest to the old hyprland master layout
      default-column-width.proportion = 1.0;
      focus-ring = {
        active.color = "#89b4fa";
        urgent.color = "#f38ba8";
      };
    };

    # hyprland `rounding = 10` equivalent
    prefer-no-csd = true;
    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 10.0;
          top-right = 10.0;
          bottom-right = 10.0;
          bottom-left = 10.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [
          {
            app-id = "^firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }
      {
        matches = [{app-id = "^org.keepassxc.KeePassXC$";}];
        block-out-from = "screencast";
      }
    ];

    outputs."eDP-1".background-color = "#1e1e2e";

    cursor = {
      theme = "catppuccin-mocha-dark-cursors";
      size = 24;
    };

    # same location the hyprshot config used
    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    # x11 apps (steam, prismlauncher); niri 26.02+ spawns this natively
    xwayland-satellite = {
      enable = true;
      path = lib.getExe pkgs.xwayland-satellite;
    };

    # nm-applet/blueman/avizo etc. start via home-manager services on
    # graphical-session.target; this is only the stuff with no service
    spawn-at-startup = [
      { argv = ["avizo-service"]; }
      { argv = ["wayland-pipewire-idle-inhibit"]; }
      { argv = ["1password" "--silent"]; }
      { argv = ["wl-clip-persist" "--clipboard" "regular"]; }
    ];

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [];
      "Mod+O" = {
        repeat = false;
        action.toggle-overview = [];
      };

      "Mod+Return".action.spawn = ["ghostty" "+new-window"];
      "Mod+D".action.spawn = "fuzzel";
      "Mod+B".action.spawn = "firefox";
      "Mod+Shift+B".action.spawn = ["firefox" "--private-window"];
      "Mod+E".action.spawn = "zeditor";
      "Mod+Z".action.spawn = "zeditor";

      "Mod+Q" = {
        repeat = false;
        action.close-window = [];
      };
      "Mod+Shift+E".action.quit.skip-confirmation = true;
      "Mod+F".action.fullscreen-window = [];
      "Mod+M".action.maximize-window-to-edges = [];

      "Mod+X".action.spawn = "wl-clip";
      "Mod+C".action.spawn = "wl-copy";
      "Mod+V".action.spawn = "wl-paste";
      "Mod+Shift+C".action.spawn-sh = "hyprpicker | wl-copy";

      "Mod+Left".action.focus-column-left = [];
      "Mod+Right".action.focus-column-right = [];
      "Mod+Up".action.focus-window-up = [];
      "Mod+Down".action.focus-window-down = [];
      "Mod+H".action.focus-column-left = [];
      "Mod+L".action.focus-column-right = [];
      "Mod+K".action.focus-window-up = [];
      "Mod+J".action.focus-window-down = [];

      "Mod+Ctrl+Left".action.move-column-left = [];
      "Mod+Ctrl+Right".action.move-column-right = [];
      "Mod+Ctrl+Up".action.move-window-up = [];
      "Mod+Ctrl+Down".action.move-window-down = [];
      "Mod+Ctrl+H".action.move-column-left = [];
      "Mod+Ctrl+L".action.move-column-right = [];
      "Mod+Ctrl+K".action.move-window-up = [];
      "Mod+Ctrl+J".action.move-window-down = [];

      "Mod+Home".action.focus-column-first = [];
      "Mod+End".action.focus-column-last = [];
      "Mod+Ctrl+Home".action.move-column-to-first = [];
      "Mod+Ctrl+End".action.move-column-to-last = [];

      "Mod+Shift+Left".action.focus-monitor-left = [];
      "Mod+Shift+Right".action.focus-monitor-right = [];
      "Mod+Shift+Up".action.focus-monitor-up = [];
      "Mod+Shift+Down".action.focus-monitor-down = [];
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];

      "Mod+Page_Down".action.focus-workspace-down = [];
      "Mod+Page_Up".action.focus-workspace-up = [];
      "Mod+U".action.focus-workspace-down = [];
      "Mod+I".action.focus-workspace-up = [];
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [];
      "Mod+Tab".action.focus-workspace-previous = [];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+0".action.focus-workspace = 10;

      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;
      "Mod+Shift+0".action.move-column-to-workspace = 10;

      "Mod+BracketLeft".action.consume-or-expel-window-left = [];
      "Mod+BracketRight".action.consume-or-expel-window-right = [];
      "Mod+Comma".action.consume-window-into-column = [];
      "Mod+Period".action.expel-window-from-column = [];

      "Mod+R".action.switch-preset-column-width = [];
      "Mod+Shift+R".action.switch-preset-column-width-back = [];
      "Mod+Ctrl+R".action.reset-window-height = [];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";

      "Mod+G".action.toggle-window-floating = [];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
      "Mod+W".action.toggle-column-tabbed-display = [];

      "Print".action.screenshot = [];
      "Mod+Print".action.screenshot-screen = [];
      "Alt+Print".action.screenshot-window = [];

      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action.focus-workspace-down = [];
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action.focus-workspace-up = [];
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-down = [];
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-up = [];
      };
      "Mod+WheelScrollRight".action.focus-column-right = [];
      "Mod+WheelScrollLeft".action.focus-column-left = [];
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];

      "Mod+Escape" = {
        allow-inhibiting = false;
        action.toggle-keyboard-shortcuts-inhibit = [];
      };

      "Mod+Shift+P".action.power-off-monitors = [];

      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = ["volumectl" "-u" "up"];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = ["volumectl" "-u" "down"];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = ["volumectl" "toggle-mute"];
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = ["lightctl" "up"];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = ["lightctl" "down"];
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action.spawn = ["playerctl" "next"];
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action.spawn = ["playerctl" "previous"];
      };
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action.spawn = ["playerctl" "play-pause"];
      };
      "XF86AudioPause" = {
        allow-when-locked = true;
        action.spawn = ["playerctl" "play-pause"];
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "1e1e2e";
      inside-color = "181825";
      ring-color = "89b4fa";
      key-hl-color = "a6e3a1";
      bs-hl-color = "f38ba8";
      inside-ver-color = "89b4fa";
      ring-ver-color = "89b4fa";
      text-ver-color = "1e1e2e";
      inside-wrong-color = "f38ba8";
      ring-wrong-color = "f38ba8";
      text-wrong-color = "1e1e2e";
      line-uses-inside = true;
      indicator-radius = 100;
      indicator-thickness = 10;
    };
  };

  # hypridle replacement, only runs in the niri session
  services.swayidle = {
    enable = true;
    systemdTargets = ["graphical-session.target"];
    timeouts = [
      {
        timeout = 300;
        command = "${lib.getExe pkgs.swaylock} -f";
      }
      {
        timeout = 600;
        command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
      }
    ];
    events = {
      before-sleep = "${lib.getExe pkgs.playerctl} pause; ${lib.getExe pkgs.swaylock}";
      lock = "${lib.getExe pkgs.swaylock}";
    };
  };

  systemd.user.services.swayidle.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
}
