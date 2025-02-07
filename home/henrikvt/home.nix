{
  pkgs,
  inputs,
  homeCfg,
  lib,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    inputs.catppuccin.homeManagerModules.catppuccin

    ./nixvim.nix
  ];

  home = {
    packages = with pkgs; [
      fastfetch
      tokei
      q
      ffmpeg
      websocat
      trippy
      podman
      podman-compose
      podman-tui
      jq
      imagemagick
      hyperfine
      git-lfs
      fd
      iperf3
      magic-wormhole
      glab
      python3
      nyancat
      moon-buggy
      sl
      cowsay
    ];

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat -p";
      lzg = "${pkgs.lazygit}/bin/lazygit";
    };

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs = {
    zsh = {
      enable = true;
      autocd = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      historySubstringSearch.enable = true;

      history = {
        size = 12000;
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
      };

      oh-my-zsh = {
        enable = true;
        theme = "josh";
        plugins = [
          "git"
          "common-aliases"
          "sudo"
          "command-not-found"
          "vscode"
          "nvm"
          "tailscale"
          "bun"
          "fnm"
          "fzf"
          "zoxide"
          "lol"
        ];
      };

      zplug = {
        enable = true;
        plugins = [
          {
            name = "djui/alias-tips";
          }
          {
            name = "hlissner/zsh-autopair";
          }
        ];
      };

      profileExtra = builtins.readFile ./zprofile.zsh;
      initExtra = builtins.readFile ./zshrc.zsh;
    };

    # Prompt
    starship = {
      enable = true;
      settings = let
        startblock = "$username$hostname$directory$git_branch$git_state$git_status";
        languages = "$bun$deno$nodejs$elixir$erlang$gleam$java$kotlin$scala$gradle$golang$python$rust$zig";
        promptline = "$sudo$cmd_duration$line_break$battery$time$status$shell$character";
      in {
        format = lib.strings.concatStrings [
          startblock
          languages
          promptline
        ];
        nodejs = {
          detect_files = ["package.json" "!bun.lock" "!bun.lockb"];
        };
      };
    };

    # Shell-integrated tools
    zoxide.enable = true;
    fzf.enable = true;
    thefuck.enable = true;
    dircolors.enable = true;
    btop.enable = true;

    direnv.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      colors = "always";
    };

    # Other tools
    bat.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      userName = "Henrik VT";
      userEmail = "commits@henrikvt.com";
      aliases = {
        a = "add";
        ua = "reset HEAD";
        p = "push";
        c = "commit";
        b = "branch";
        co = "checkout";
        cb = "checkout -b";
        sw = "switch";
        swc = "switch -c";
        ap = "add -p";
        ca = "commit -a";
        cm = "commit -m";
        cam = "commit -am";
        amend = "commit --amend";
        s = "status -sb";
        l = "log --all --graph --decorate --oneline";
      };
      extraConfig = {
        init.defaultBranch = "main";
        color.ui = "auto";
        color.diff = {
          meta = "white bold";
          frag = "cyan bold";
          old = "red bold";
          new = "green bold";
        };

        core = {
          editor = "vim";
          excludesfile = "~/.gitignore";
          attributesfile = "~/.gitattributes";
          ignorecase = false;
          compression = 0;
        };
        push = {
          autoSetupRemote = true;
          default = "current";
        };
        pull.rebase = false;
        protocol.file.allow = "always";
      };
    };
    lazygit.enable = true;
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    gh-dash.enable = homeCfg.ghDash;

    yazi = {
      enable = true;
      settings = {
        manager = {
          show_hidden = false;
          sort_by = "alphabetical";
          sort_dir_first = true;
        };
      };
    };
  };

  catppuccin = {
    enable = true;
  };

  xdg.configFile."ghostty/config" = lib.mkIf homeCfg.ghostty {
    enable = true;
    source = ./ghostty.txt;
  };

  # ======================== DO NOT CHANGE THIS ========================
  home.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
