-- 🧠 Автокоманды Neovim

-- Автоформатирование Python-файлов при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
