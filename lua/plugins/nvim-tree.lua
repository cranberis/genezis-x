
local function my_nvimtree_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return {
      desc = "nvim-tree: " .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true
    }
  end
  
  -- Навигация по дереву c оставлением фокуса на дереве
  vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts("Close parent"))            -- Выйти из папки
  
  vim.keymap.set('n', 'l', function()
    api.node.open.edit()
    vim.cmd("wincmd h")                         -- возвращаем фокус на окно дерева
  end, opts("Open/edit and refocus"))           -- Зайти в папку/открыть файл

  vim.keymap.set('n', '<CR>', function()
    api.node.open.edit()
    vim.cmd("wincmd h")                         -- возвращаем фокус на окно дерева
  end, opts("Open/edit and refocus"))           -- Enter - зайти в папку/открыть файл
  -- Стрелки (альтернативно) с переключением фокуса на открытый файл
  vim.keymap.set('n', '<Left>', api.node.navigate.parent_close, opts("Close parent"))
  vim.keymap.set('n', '<Right>', api.node.open.edit, opts("Open/edit"))
  -- Открыть в split, если надо
  vim.keymap.set('n', 's', api.node.open.vertical, opts("Open: vertical split"))
  vim.keymap.set('n', 'i', api.node.open.horizontal, opts("Open: horizontal split"))
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

