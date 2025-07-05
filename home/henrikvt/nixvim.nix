# This module is imported into programs.nixvim, thus everthing exists in that scope
{homeCfg, lib,  ...}: {
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

    #  ------
    # | LSP |
    # ------
    # Javascript/Typescript
    conform-nvim = lib.mkIf homeCfg.client  {
      settings = {
        formatters_by_ft.javascript = ["prettier"];
        formatters_by_ft.typescript = ["prettier"];
        formatters_by_ft.javascriptreact = ["prettier"];
        formatters_by_ft.typescriptreact = ["prettier"];
      };
    };
    lsp.servers = lib.mkIf homeCfg.client {
      ts_ls = {
        enable = true;
        filetypes = [
          "javascript"
          "javascriptreact"
          "typescript"
          "typescriptreact"
        ];
      };
      eslint.enable = true;
      # Svelte with TS support
      svelte = {
        enable = true;
        initOptions.svelte.plugin = {
          html = {
            enable = true;
            tagComplete.enable = true;
            completions = {
              enable = true;
              emmet = true;
            };
          };
          typescript = {
            enable = true;
            signatureHelp.enable = true;
            semanticTokens.enable = true;
            hover.enable = true;
          };
        };
      };
    };
  };
}
