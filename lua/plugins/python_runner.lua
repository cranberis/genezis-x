
-- 📦 Модуль управления Python-терминалом
-- Позволяет запускать Python-скрипты в терминале с shell-приглашением и интерактивностью
-- Использует плагин "toggleterm.nvim"

local M = {}

-- 📌 Импортируем объект Terminal из toggleterm
local Terminal = require("toggleterm.terminal").Terminal

-- 🐍 Храним текущий запущенный терминал, чтобы им управлять (открытие/закрытие/перезапуск)
local python_runner = nil

-- 🔁 Основная функция запуска Python-скрипта
function M.run()
  -- Если мы сейчас находимся в терминале toggleterm — возвращаемся в нормальный буфер
  if vim.bo.filetype == "toggleterm" then
    vim.cmd("wincmd p")
  end

  -- 📄 Получаем имя текущего буфера (файла)
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Проверка: является ли файл Python-скриптом (.py, .pyw)
  if not bufname:match("%.py[w]?$") then
    print("❌ Это не Python-файл")
    return
  end

  -- 💾 Сохраняем файл перед запуском
  vim.cmd("w")

  -- 📍 Определяем путь до Python-интерпретатора: сначала пробуем .venv, иначе используем system-wide python3
  local root_dir = vim.fn.getcwd()
  local venv_path = root_dir .. "/.venv/bin/python"
  local python_exec = vim.fn.filereadable(venv_path) == 1 and venv_path or "python3"

  -- 🔒 Если терминал уже был запущен — закрываем, чтобы создать новый
  if python_runner and python_runner.close then
    python_runner:close()
    python_runner = nil
  end

  -- 🧠 Формируем команду запуска с shell-приглашением (echo "$ ..."; exec bash)
  local command = python_exec .. " " .. bufname
  local shell_cmd = string.format([[bash -c 'echo "$ %s"; %s; exec bash']], command, command)

  -- 🚀 Создаём терминал и запускаем в горизонтальном окне (15 строк)
  python_runner = Terminal:new({
    cmd = shell_cmd,
    direction = "horizontal",
    size = 15,
    close_on_exit = false, -- Не закрываем терминал после завершения
    auto_scroll = true,    -- Автоматическая прокрутка вниз
    start_in_insert = true,-- Сразу переходим в режим ввода
    on_exit = function()
      vim.cmd("stopinsert") -- ❌ Выход из insert-режима после завершения процесса
    end,
  })

  python_runner:open() -- 🎬 Открываем терминал
end

-- 👁 Переключение отображения терминала (toggle)
function M.toggle()
  if python_runner then
    python_runner:toggle()
    vim.cmd("stopinsert")
  else
    print("❗ Нет активного терминала")
  end
end

-- 🔧 Регистрируем пользовательские Vim-команды: :PythonRunner, :PythonRunnerToggle
-- Это позволяет вызывать функционал из mappings.lua одной строкой:
-- vim.keymap.set('n', '<leader>pr', ':PythonRunner<CR>')
-- и, соответственно: 
-- vim.keymap.set('n', '<leader>pt', ':PythonRunnerToggle<CR>')
-- Команда запуска Python-файла
vim.api.nvim_create_user_command("PythonRunner", function()
  require("plugins.python_runner").run()
end, {})

-- 👁 Команда показа/скрытия терминала
vim.api.nvim_create_user_command("PythonRunnerToggle", function()
  require("plugins.python_runner").toggle()
end, {})

return M
