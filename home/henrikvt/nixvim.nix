{...}: {
  programs.nixvim = {
    enable = true;
    colorschemes.catppuccin.settings = {
      flavour = "mocha";
      background.dark = "mocha";
      background.light = "mocha";
    };
  };
}
