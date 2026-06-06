vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.hpp", "*.c", "*.h", "*.vert","*.frag" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

vim.filetype.add({
  extension = {
    vert = "glsl",
    frag = "glsl",
  },
})
