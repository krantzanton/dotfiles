return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "cmake",
          "lua",
          "vim",
          "vimdoc",
          "markdown",
          "markdown_inline",
          "query",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
