
-- 📊 Команда для сравнения текущих изменений с предыдущим коммитом
vim.api.nvim_create_user_command("CompareWithLast", function()
  vim.cmd("DiffviewOpen HEAD~1")
end, { desc = "Сравнение с HEAD~1" })

-- 🕓 Команда для просмотра истории текущего файла
vim.api.nvim_create_user_command("FileHistory", function()
  local filepath = vim.fn.expand("%") -- получаем путь текущего файла
  vim.cmd("DiffviewFileHistory " .. filepath)
end, { desc = "История текущего файла" })
