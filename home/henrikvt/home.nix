{
  pkgs,
  inputs,
  homeCfg,
  lib,
  ...
}: {
  imports =
    [
      inputs.nixvim.homeManagerModules.nixvim
      inputs.catppuccin.homeManagerModules.catppuccin
    ]
    ++ homeCfg.extraModules;

  home = {
    packages = with pkgs;
      [
        fastfetch
        tokei
        q
        ffmpeg
        websocat
        # trippy (this fucks with my mac and also it just doesn't work?)
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
        wget
        ripgrep
        mprocs
        du-dust
        fd
        xh
      ]
      ++ lib.optionals homeCfg.client [
        presenterm
        nyancat
        moon-buggy
        sl
        cowsay
        lolcat
        ninvaders
        fortune
      ];

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat -p";
      lzg = "lazygit";
      gib = "git pull";
      nixsize = "${pkgs.diskus}/bin/diskus /nix/store";
    };

    sessionVariables = {
      EDITOR = "nvim";
    };

    # activation.tldr-alias = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   unalias tldr
    # '';
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
          "grc"
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
        command_timeout = 2 * 1000;
        # Prompt section configs
        bun = {
          detect_files = ["bun.lock" "bun.lockb" "bunfig.toml"];
          style = "bold white";
        };
        rust = {
          style = "bold #CE412B";
        };
        java = {
          style = "bold red";
        };
        nodejs = {
          detect_files = ["package.json" "!bun.lock" "!bun.lockb"];
        };
        sudo = {
          disabled = false;
        };
        nix_shell = {
          disabled = false;
        };
      };
    };

    # Shell-integrated tools
    zoxide.enable = true;
    fzf.enable = true;
    # pay-respects.enable = true;
    dircolors.enable = true;
    btop.enable = true;
    atuin = {
      enable = true;
      flags = ["--disable-up-arrow"];
    };
    nix-index.enable = true;
    zellij.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global = {
          disable_stdin = true;
          hide_env_diff = true;
        };
      };
    };
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
      delta.enable = true;
    };
    lazygit.enable = true;
    lazygit.settings = {};
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    gh-dash.enable = homeCfg.ghDash;

    nixvim = import ./nixvim.nix {
      inherit pkgs;
    };

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

    tealdeer = {
      enable = true;
      settings = {
        cache_dir = "$HOME/.cache/tealdeer";
        cache_size = 100;
        cache_timeout = 604800;
        color = "auto";
        format = "markdown";
        pager = "less -R";
      };
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  xdg.configFile."ghostty/config" = lib.mkIf homeCfg.ghostty {
    enable = true;
    source = ./ghostty.txt;
  };

  # ======================== DO NOT CHANGE THIS ========================
  home.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
