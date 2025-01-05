{pkgs, ...}: {
  imports = [
    ./zsh.nix
  ];

  home = {
    packages = with pkgs; [
      fastfetch
      tokei
      q
      flyctl
      ffmpeg
      websocat
      trippy
      podman-compose
      podman-tui
      jq
      imagemagick
      hyperfine
      git-lfs
      fd
      wifi-password
      iperf3
      magic-wormhole
    ];

    shellAliases = {
      cat = "bat -p";
      less = "bat --style plain --paging always";
    };
  };

  programs = {
    zsh = {
      enable = true;
      autocd = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
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
          "history-substring-search"
          "tailscale"
          "bun"
          "fnm"
          "fzf"
          "zoxide"
        ];
      };
    };

    # Prompt
    starship = {
      enable = true;
    };

    # Shell-integrated tools
    zoxide.enable = true;
    fzf.enable = true;
    thefuck.enable = true;
    dircolors.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      colors = "always";
    };

    # Other tools
    bat.enable = true;
  };
}
