{...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorschemes.catppuccin.settings = {
      flavour = "mocha";
      background.dark = "mocha";
      background.light = "mocha";
    };
  };
}
