{pkgs, ...}: {
  catppuccin.waybar.mode = "createLink";

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./waybar.css;

    settings = {
      default = {
        position = "top";
        margin = "10 10 0 10";
        modules-left = [
          "hyprland/workspaces"
          "tray"
          "hyprland/submap"
          "hyprland/scratchpad"
        ];
        modules-center = ["clock"];
        modules-right = [
          "pulseaudio"
          "backlight"
          "battery"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          persistent-workspaces = {
            "1" = [];
          };
        };

        "hyprland/submap" = {
          format = ''<span style="italic">{}</span>'';
        };

        "hyprland/scratchpad" = {
          format = "{icon} {count}";
          show-empty = false;
          format-icons = [
            ""
            ""
          ];
          tooltip = true;
          tooltip-format = "{app}: {title}";
          on-click = "sway scratchpad show";
        };

        clock = {
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format = "{:%a, %d %b, %I:%M %p}";
        };

        pulseaudio = {
          reverse-scrolling = 1;
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
        };

        backlight = {
          device = "amd_backlight";
          format = "{percent}% ";
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 20;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
        };

        tray = {
          icon-size = 16;
          spacing = 10;
        };

        # notifications = {
        #   tooltip = false;
        #   format = "{icon}";
        #   format-icons = {
        #     notification = "<span foreground='red'><sup></sup></span>";
        #     none = "";
        #     dnd-notification = "<span foreground='red'><sup></sup></span>";
        #     dnd-none = "";
        #     inhibited-notification = "<span foreground='red'><sup></sup></span>";
        #     inhibited-none = "";
        #     dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        #     dnd-inhibited-none = "";
        #   };
        #   return-type = "json";
        #   exec-if = "which swaync-client";
        #   exec = "swaync-client -swb";
        #   on-click = "swaync-client -t -sw";
        #   on-click-right = "swaync-client -d -sw";
        #   escape = true;
        # };
      };
    };
  };
}
