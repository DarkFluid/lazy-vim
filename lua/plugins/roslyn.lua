return {
  -- Roslyn needs a custom Mason registry to be installable via :MasonInstall roslyn
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "roslyn-nightly",
      },
    },
  },

  -- Explicitly disable omnisharp so mason-lspconfig's automatic_enable
  -- doesn't start it just because the binary is still installed in Mason.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = false,
        rzls = false,
        html = {
          filetypes = { "html", "cshtml", "razor" },
        },
      },
    },
  },

  -- Treesitter grammar for C#
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c_sharp", "html", "razor" })
      end
    end,
  },

  -- Roslyn LSP — the same server used by VS Code's C# Dev Kit
  {
    "seblyng/roslyn.nvim",
    ft = { "cs" },
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      -- Let Neovim handle filewatching (safest default)
      filewatching = "auto",
      -- Search parent dirs for .sln files (useful for nested project layouts)
      broad_search = false,
      -- Silence "Roslyn is initializing..." notifications
      silent = false,
    },
    config = function(_, opts)
      require("roslyn").setup(opts)

      -- Language server settings (sent to the server, not plugin config)
      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = false,
            csharp_enable_inlay_hints_for_implicit_variable_types = false,
            csharp_enable_inlay_hints_for_lambda_parameter_types = false,
            csharp_enable_inlay_hints_for_types = false,
            dotnet_enable_inlay_hints_for_parameters = false,
          },
          ["csharp|background_analysis"] = {
            -- Only analyse open files to keep CPU usage low
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|formatting"] = {
            dotnet_organize_imports_on_format = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
          },
        },
      })
    end,
  },

  -- Use Roslyn's own formatter for C# — same engine as Visual Studio,
  -- fully respects .editorconfig (tabs, Allman braces, 140-char line length, etc.)
  {
    "stevearc/conform.nvim",
    optional = true,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cshtml", "razor" },
        callback = function(args)
          vim.b[args.buf].autoformat = false
        end,
      })
    end,
    opts = {
      formatters_by_ft = {
        cs = { "lsp" },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "cshtml" or ft == "razor" then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
  },
}
