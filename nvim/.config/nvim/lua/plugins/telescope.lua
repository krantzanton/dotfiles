return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          --layout_strategy = "horizontal",
          --border = true,
          layout_config = {
            prompt_position = "bottom",
          },
          sorting_strategy = "ascending",
        },
      })

      -- keymaps
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Find word (grep)" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    end,
  },
}
