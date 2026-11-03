return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- systems
          "bash",
          "c",
          "cpp",
          "cmake",
          "make",
          "glsl",
          -- go
          "go",
          "gomod",
          "gosum",
          "gowork",
          -- web / react
          "javascript",
          "typescript",
          "tsx",
          "jsdoc",
          "html",
          "css",
          "json",
          "graphql",
          -- config / docs
          "lua",
          "luadoc",
          "vim",
          "vimdoc",
          "query",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "dockerfile",
          "gitcommit",
          "diff",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<bs>",
            scope_incremental = false,
          },
        },
      })
    end,
  },

  -- Auto close/rename JSX and HTML tags
  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} },

  -- Shows the current function/component at the top when scrolled past it
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPre", "BufNewFile" },
    opts = { max_lines = 3 },
  },
}
