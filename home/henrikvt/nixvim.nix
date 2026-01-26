# This module is imported into programs.nixvim, thus everthing exists in that scope
_: {
  enable = true;
  defaultEditor = true;
  colorschemes.catppuccin.settings = {
    flavour = "mocha";
    background.dark = "mocha";
    background.light = "mocha";
  };

  plugins = {
    #  ----------------
    # | General Stuff |
    #  ----------------
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          virt_text = true;
          virt_text_pos = "eol";
        };
        signcolumn = true;
        signs = {
          add = {text = "│";};
          change = {text = "│";};
          changedelete = {text = "~";};
          delete = {text = "_";};
          topdelete = {text = "‾";};
          untracked = {text = "┆";};
        };
        watch_gitdir = {follow_files = true;};
      };
    };

    hop.enable = true;
    illuminate.enable = true;

    nvim-lightbulb.enable = true;
    lualine = {
      enable = true;
      settings.options.globalstatus = true;
    };

    luasnip.enable = true;
    neo-tree.enable = true;

    nvim-autopairs.enable = true;
    # colorizer.enable = true;

    render-markdown.enable = true;
    todo-comments.enable = true;

    treesitter = {
      enable = true;

      folding = false;
      settings.indent.enable = true;
    };

    vim-surround.enable = true;
    web-devicons.enable = true;
  };
}
