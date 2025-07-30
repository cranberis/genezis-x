-- Подключаем модуль null-ls
local null_ls = require("null-ls")

-- Инициализируем таблицу для хранения выбранных источников
local sources = {}

-- Получаем тип текущего открытого файла
local filetype = vim.bo.filetype

-- В зависимости от типа файла добавляем соответствующие инструменты
if filetype == "python" then
  -- Форматтер Black для Python
  table.insert(sources, null_ls.builtins.formatting.black)
  -- Форматтер Ruff для Python
  table.insert(sources, null_ls.builtins.formatting.ruff)
  -- Диагностика Flake8 для Python
  table.insert(sources, null_ls.builtins.diagnostics.flake8)

elseif filetype == "json" or filetype == "javascript" then
  -- Форматтер Prettier для JS / JSON
  table.insert(sources, null_ls.builtins.formatting.prettier)

elseif filetype == "lua" then
  -- Форматтер Stylua для Lua
  table.insert(sources, null_ls.builtins.formatting.stylua)
end

-- Инициализируем null-ls с выбранными источниками
null_ls.setup({ sources = sources })
