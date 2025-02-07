# This module is imported into programs.nixvim
{...}: {
  enable = true;
  defaultEditor = true;
  colorschemes.catppuccin.settings = {
    flavour = "mocha";
    background.dark = "mocha";
    background.light = "mocha";
  };

  # Javascript/Typescript
  plugins = {
    conform-nvim = {
      settings = {
        formatters_by_ft.javascript = ["prettier"];
        formatters_by_ft.typescript = ["prettier"];
        formatters_by_ft.javascriptreact = ["prettier"];
        formatters_by_ft.typescriptreact = ["prettier"];
      };
    };
    lsp.servers = {
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
