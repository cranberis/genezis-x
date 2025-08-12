
local function my_nvimtree_on_attach(bufnr)
  local api = require('nvim-tree.api')

  -- Cтандартные бинды
  api.config.mappings.default_on_attach(bufnr)

  local function opts(desc)
    return {
      desc = "nvim-tree: " .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true
    }
  end

  -- Открыть файл через системное приложение
  vim.keymap.set('n', 'S', function()
    api.node.run.system()
  end, opts("Open with system app"))

  -- Переключить отображение игнорируемых файлов (.gitignore)
  vim.keymap.set('n', 'gh', function()
    api.tree.toggle_git_ignored()
  end, opts("Toggle git ignored"))

  vim.keymap.set('n', 'gi', function()
    api.tree.toggle_git_ignored()
  end, opts("Toggle git ignored"))

  -- Навигация по дереву c оставлением фокуса на дереве
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts("Close parent"))            -- Выйти из папки

  -- Клавиша 'l' — открыть файл/папку и вернуть фокус
  vim.keymap.set('n', 'l', function()
    local tree_win = vim.api.nvim_get_current_win() -- сохраняем winid дерева
    api.node.open.edit()
    vim.api.nvim_set_current_win(tree_win)          -- возвращаем фокус
  end, opts("Open/edit and refocus"))

  -- Enter — открыть файл/папку и вернуть фокус
  vim.keymap.set('n', '<CR>', function()
    local tree_win = vim.api.nvim_get_current_win() -- сохраняем winid дерева
    api.node.open.edit()
    vim.api.nvim_set_current_win(tree_win)          -- возвращаем фокус
  end, opts("Open/edit and refocus"))
  
  -- Стрелки (альтернативно) с переключением фокуса на открытый файл
  vim.keymap.set('n', '<Left>', api.node.navigate.parent_close, opts("Close parent"))
  vim.keymap.set('n', '<Right>', api.node.open.edit, opts("Open/edit"))
  
  -- Вертикальный split на 'v' с оставлением фокуса на дереве
  vim.keymap.set('n', 'v', function()
    local tree_win = vim.api.nvim_get_current_win() -- сохраняем winid дерева
    api.node.open.vertical()
    vim.api.nvim_set_current_win(tree_win)          -- возвращаем фокус
  end, opts("Open: vertical split and refocus"))

  -- Горизонтальный split на 's' с оставлением фокуса на дереве
  vim.keymap.set('n', 's', function()
    local tree_win = vim.api.nvim_get_current_win() -- сохраняем winid дерева
    api.node.open.horizontal()
    vim.api.nvim_set_current_win(tree_win)          -- возвращаем фокус
  end, opts("Open: horizontal split and refocus"))
end

-- 🛠️ Настройка nvim-tree
require('nvim-tree').setup({
  on_attach = my_nvimtree_on_attach,
  view = {
    side = "left",
    width = 35,
    preserve_window_proportions = true,
  },
  actions = {
    open_file = {
      quit_on_open = false, -- отвечает за отображение/сокрытие дерева после запуска файла
      resize_window = true,
      window_picker = {
        enable = false, -- предотвратить появление prompt'а выбора окна
      },
    },
  },
  update_focused_file = {
    enable = true,
    update_cwd = false,
    ignore_list = {},
  },
})

-- 🛠️ Настройка предпросмотра 
require("core.preview").setup_nvimtree_preview()
