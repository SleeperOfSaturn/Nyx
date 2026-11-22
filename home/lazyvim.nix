# home/lazyvim.nix
#
# LazyVim configuration:
# Gruvbox Dark Hard, Blink completion, C/C++ and Nix tooling.

{ config, pkgs, lib, ... }:

{
  programs.lazyvim = {
    enable = true;

    extras = {
      lang.nix.enable = true;
    };
  };

  xdg.configFile."nvim/lua/plugins/gruvbox.lua".text = ''
    return {
      {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        opts = {
          contrast = "hard",
          terminal_colors = true,
          transparent_mode = false,
        },
        config = function(_, opts)
          require("gruvbox").setup(opts)
          vim.o.background = "dark"
          vim.cmd.colorscheme("gruvbox")
        end,
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/completion.lua".text = ''
    return {
      {
        "saghen/blink.cmp",
        version = "*",
        dependencies = {
          "rafamadriz/friendly-snippets",
        },
        opts = {
          keymap = {
            preset = "default",
          },
          completion = {
            documentation = {
              auto_show = true,
              auto_show_delay_ms = 250,
            },
            ghost_text = {
              enabled = true,
            },
            menu = {
              border = "rounded",
            },
          },
          sources = {
            default = {
              "lsp",
              "path",
              "snippets",
              "buffer",
            },
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/lsp.lua".text = ''
    return {
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            clangd = {},
            nixd = {},
          },
        },
      },
    }
  '';

  home.packages = with pkgs; [
    gcc
    gdb
    clang-tools
    nixd
    nixfmt
    ripgrep
    fd
  ];
}

