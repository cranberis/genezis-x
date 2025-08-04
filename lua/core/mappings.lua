vim.g.mapleader = " "

-- Quit
vim.keymap.set('n', '<C-q>', '<cmd>:q<CR>')

-- Copy all text
vim.keymap.set('n', '<C-a>', '<cmd>%y+<CR>')

-- Saving a file via Ctrl+S
vim.keymap.set('i', '<C-s>', '<cmd>:w<CR>')
vim.keymap.set('n', '<C-s>', '<cmd>:w<CR>')

-- NvimTree
vim.keymap.set('n', '<leader>t', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>tf', ':NvimTreeFocus<CR>')

-- BufferLine
vim.keymap.set('n','<Tab>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n','<S-Tab>', ':BufferLineCyclePrev<CR>')
vim.keymap.set('n', '<C-l>', ':BufferLineCloseOthers<CR>')

-- TodoList
vim.keymap.set('n', '<leader>nl', ':TodoTelescope<CR>')

-- ToggleTerm
vim.keymap.set('n', '<leader>s', ':ToggleTerm direction=float<CR>')

-- PythonRunner
vim.keymap.set('n', '<leader>pr', ':PythonRunner<CR>')         -- 🔁 Запуск Python-файла
vim.keymap.set('n', '<leader>pt', ':PythonRunnerToggle<CR>')   -- 👁 Показать/скрыть терминал

-- 🔁 Diffview: сравнение и история коммитов
vim.keymap.set("n", "<Leader>gd", "<Cmd>CompareWithLast<CR>", { desc = "Git Diff: HEAD~1" })
vim.keymap.set("n", "<Leader>gh", "<Cmd>FileHistory<CR>", { desc = "Git: История файла" })
