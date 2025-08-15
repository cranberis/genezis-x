
-- 📦 Модуль управления Python-терминалом
-- Позволяет запускать Python-скрипты в терминале с shell-приглашением и интерактивностью
-- Использует плагин "toggleterm.nvim"

local M = {}

-- 📌 Импортируем объект Terminal из toggleterm
local Terminal = require("toggleterm.terminal").Terminal

-- 🐍 Храним текущий запущенный терминал, чтобы им управлять (открытие/закрытие/перезапуск)
local python_runner = nil

-- 🪟 Сохраняем окно, из которого был запущен скрипт
local last_winid = nil

-- 🪟 Сохраняем буфер, с активным файлом
local last_bufnr = nil

-- 🔁 Основная функция запуска Python-скрипта
function M.run()
  -- Если мы сейчас находимся в терминале toggleterm — возвращаемся в нормальный буфер
  if vim.bo.filetype == "toggleterm" then
    if last_winid and vim.api.nvim_win_is_valid(last_winid) then
      vim.api.nvim_set_current_win(last_winid)
    else
      vim.cmd("wincmd p")
    end
  end

  -- 🪟 Сохраняем окно и буфер при запуске
  last_winid = vim.api.nvim_get_current_win()
  last_bufnr = vim.api.nvim_get_current_buf()

  -- 📄 Получаем имя текущего файла
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Проверка: является ли файл Python-скриптом (.py, .pyw)
  if not bufname:match("%.py[w]?$") then
    print("❌ Это не Python-файл")
    return
  end

  -- 💾 Сохраняем файл перед запуском
  vim.cmd("w")

  -- 📍 Определяем путь до Python-интерпретатора
  local root_dir = vim.fn.getcwd()
  local venv_path = root_dir .. "/.venv/bin/python"
  local python_exec = vim.fn.filereadable(venv_path) == 1 and venv_path or "python3"

  -- 🧠 Формируем команду запуска
  local command = python_exec .. " " .. bufname
  local shell_cmd = string.format([[bash -c 'echo "$ %s"; %s; exec bash']], command, command)

  -- 🔁 Если терминал уже был запущен — пересоздаём объект
  if python_runner then
    python_runner:shutdown()
    python_runner = nil
  end

  -- 🚀 Создаём терминал и запускаем
  python_runner = Terminal:new({
    cmd = shell_cmd,
    direction = "horizontal",
    size = 15,
    close_on_exit = false,
    auto_scroll = true,
    start_in_insert = true,
  })

  python_runner:open()
  
  -- 🎯 Возвращаем фокус в терминал после открытия
  -- Используем vim.defer_fn, чтобы избежать гонки: окно терминала может ещё не существовать
  -- Это гарантирует, что при запуске и перезапуске фокус окажется в интерактивном терминале
  vim.defer_fn(function()
    local term_winid = python_runner.window
    if term_winid and vim.api.nvim_win_is_valid(term_winid) then
      vim.api.nvim_set_current_win(term_winid)
      vim.cmd("startinsert")
    end
  end, 50)

  -- 🧭 Автокоманда: при закрытии окна терминала возвращаем фокус
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local closed_winid = tonumber(args.match)
      if closed_winid == python_runner.window then
        if last_winid and vim.api.nvim_win_is_valid(last_winid) then
          vim.defer_fn(function()
            vim.api.nvim_set_current_win(last_winid)
          end, 50)
        end
      end
    end,
  })
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
