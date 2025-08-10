
local M = {}

local preview_win = nil
local preview_buf = nil
local preview_scroll = 1 -- 📍 текущая строка предпросмотра
local debounce_timer = nil

-- 🔒 Максимальный размер файла для предпросмотра (в байтах)
local MAX_FILE_SIZE = 100 * 1024 -- 100 KB

-- 🧠 Кэш для уже прочитанных файлов
local file_cache = {}

-- 🔍 Проверка: является ли файл бинарным или неподходящего формата
local function is_binary(path)
  local ext = vim.fn.fnamemodify(path, ":e"):lower()

  -- 📦 Расширения, которые считаем неподходящими для предпросмотра
  local unsupported_exts = {
    pdf = true,
    zip = true,
    tar = true,
    gz = true,
    rar = true,
    png = true,
    jpg = true,
    jpeg = true,
    svg = true,
    mp3 = true,
    mp4 = true,
    avi = true,
    mov = true,
    doc = true,
    docx = true,
    xls = true,
    xlsx = true,
    ppt = true,
    pptx = true,
    odt = true,
    ods = true,
  }

  if unsupported_exts[ext] then
    return true
  end

  -- 🔍 Проверка по содержимому файла
  local file = io.open(path, "rb")
  if not file then return true end
  local chunk = file:read(1024)
  file:close()
  if not chunk then return true end
  return chunk:find("\0") ~= nil
end

-- 🧹 Закрытие окна предпросмотра
local function close_preview()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
    preview_win = nil
  end
  if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
    vim.api.nvim_buf_delete(preview_buf, { force = true })
    preview_buf = nil
  end
end

-- 🔽 Прокрутка вниз
local function scroll_preview_down()
  if preview_buf and vim.api.nvim_buf_is_valid(preview_buf)
     and preview_win and vim.api.nvim_win_is_valid(preview_win) then
    local line_count = vim.api.nvim_buf_line_count(preview_buf)
    preview_scroll = math.min(preview_scroll + 1, line_count)
    vim.api.nvim_win_set_cursor(preview_win, { preview_scroll, 0 })
  end
end

-- 🔼 Прокрутка вверх
local function scroll_preview_up()    
  if preview_buf and vim.api.nvim_buf_is_valid(preview_buf)
     and preview_win and vim.api.nvim_win_is_valid(preview_win) then
    preview_scroll = math.max(preview_scroll - 1, 1)
    vim.api.nvim_win_set_cursor(preview_win, { preview_scroll, 0 })
  end
end

-- 📦 Открытие окна предпросмотра
local function open_preview(lines, filetype)
  close_preview()

  -- Создаём буфер предпросмотра
  preview_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)

  if filetype then
    vim.api.nvim_buf_set_option(preview_buf, "filetype", filetype)
  end

  -- Геометрия редактора
  local tree_width = require("nvim-tree.view").View.width
  local winheight = vim.fn.winheight(0) -- высота окна редактора
  local preview_width = vim.o.columns - tree_width - 2
  local preview_height = math.floor(winheight * 0.4)
  local preview_center = math.floor(preview_height / 2)

  -- Позиция курсора в окне
  local cursor_line = vim.fn.winline()

  -- Точки A, B, C — курсор
  local A = 1
  local B = winheight
  local C = math.floor(winheight / 2)

  -- Точки a, b, c — центр предпросмотра
  local a = A + 1
  local b = B - preview_height - 1
  local c = C - preview_center

  -- Вычисляем относительное смещение курсора от центра
  local delta_percent
  if cursor_line < C then
    delta_percent = (cursor_line - C) / (C - A)
  else
    delta_percent = (cursor_line - C) / (B - C)
  end

  -- Вычисляем приращение позиции предпросмотра
  local delta_pixels
  if cursor_line < C then
    delta_pixels = delta_percent * (c - a)
  else
    delta_pixels = delta_percent * (b - c)
  end

  -- Итоговая позиция предпросмотра
  local preview_row = math.floor(c + delta_pixels)
  preview_row = math.max(preview_row, 1)
  preview_row = math.min(preview_row, winheight - preview_height - 2)

  -- Создаём окно предпросмотра
  preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = "editor",
    width = preview_width,
    height = preview_height,
    row = preview_row,
    col = tree_width + 2,
    style = "minimal",
    border = "rounded",
    focusable = false,
    zindex = 50,
  })

  -- Cброс прокрутки при открытии окна    
  preview_scroll = (#lines > 1 and lines[1]:match("^📄")) and 2 or 1
  vim.api.nvim_win_set_cursor(preview_win, { preview_scroll, 0 })
end

-- 📘 Markdown: упрощённый предпросмотр
local function format_markdown(lines)
  local formatted = {}
  for _, line in ipairs(lines) do
    if line:match("^#") then
      table.insert(formatted, "🔹 " .. line)
    elseif line:match("^%- ") or line:match("^%* ") then
      table.insert(formatted, "  • " .. line)
    else
      table.insert(formatted, line)
    end
  end
  return formatted
end

-- 🧾 JSON: автоформатирование с отступами
local function format_json(raw)
  local ok, parsed = pcall(vim.fn.json_decode, table.concat(raw, "\n"))
  if not ok or type(parsed) ~= "table" then return raw end

  local pretty = vim.fn.json_encode(parsed)
  return vim.split(pretty, "\n", { plain = true })
end

-- 🧠 Основная функция предпросмотра
local function preview_node()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path then
    close_preview()
    return
  end

  local path = node.absolute_path
  local lines = {}
  local filetype = nil

  if node.type == "directory" then
    -- 📁 Предпросмотр содержимого папки
    lines = vim.fn.systemlist("ls -lha --group-directories-first " .. vim.fn.shellescape(path))
    if #lines == 0 then
      lines = { "📁 Папка пуста" }
    end

  elseif node.type == "file" then
    -- 📄 Получаем информацию о файле
    local stat = vim.loop.fs_stat(path)

    -- 🧠 Используем кэш, если файл уже был прочитан
    if file_cache[path] then
      lines = file_cache[path].lines
      filetype = file_cache[path].filetype
    else
      -- 🔍 Проверка на бинарность
      if is_binary(path) then
        lines = {
          "⚠️ Предпросмотр данного файла не поддерживается",
          "Файл бинарный или неподходящего формата",
        }
      else
        -- 🧾 Определяем тип файла
        filetype = vim.filetype.match({ filename = path })

        -- 📄 Если это лог и он большой — показываем хвост
        if filetype == "log" and stat and stat.size > MAX_FILE_SIZE then
          local tail_cmd = "tail -c " .. MAX_FILE_SIZE .. " " .. vim.fn.shellescape(path)
          local output = vim.fn.systemlist(tail_cmd)
          lines = output
          table.insert(lines, 1, "📄 Показан хвост лог-файла (" .. MAX_FILE_SIZE .. " байт)")

        -- 📄 Если файл большой, но не лог — показываем начало
        elseif stat and stat.size > MAX_FILE_SIZE then
          local file = io.open(path, "rb")
          if file then
            local chunk = file:read(MAX_FILE_SIZE)
            file:close()
            if chunk then
              lines = vim.split(chunk, "\n", { plain = true })
              table.insert(lines, 1, "📄 Показан фрагмент файла (" .. MAX_FILE_SIZE .. " байт)")
            else
              lines = { "❌ Не удалось прочитать начало файла" }
            end
          else
            lines = { "❌ Не удалось открыть файл" }
          end

        -- 📄 Обычный текстовый файл
        else
          local ok, content = pcall(vim.fn.readfile, path)
          lines = ok and content or { "❌ Не удалось прочитать файл" }
        end

        -- 📘 Markdown: форматируем заголовки и списки
        if filetype == "markdown" then
          lines = format_markdown(lines)
        end

        -- 🧾 JSON: форматируем с отступами
        if filetype == "json" then
          lines = format_json(lines)
        end

        -- 💾 Сохраняем в кэш
        file_cache[path] = {
          lines = lines,
          filetype = filetype,
        }
      end
    end

  else
    lines = { "❓ Неизвестный тип узла" }
  end

  open_preview(lines, filetype)
end

-- 🛠️ Настройка предпросмотра для nvim-tree
function M.setup_nvimtree_preview()
  -- 📌 Автокоманда при перемещении курсора
  vim.api.nvim_create_autocmd("CursorMoved", {
    pattern = "NvimTree*",
    callback = function()
      -- 🕒 Задержка (debounce) — чтобы не мельтешило
      if debounce_timer and not vim.loop.is_closing(debounce_timer) then
        debounce_timer:stop()
        debounce_timer:close()
      end

      debounce_timer = vim.defer_fn(function()
        preview_node()
      end, 150) -- задержка 150 мс
    end,
  })
  
  -- 🎮 Горячие клавиши для прокрутки предпросмотра
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "NvimTree",
    callback = function(args)
      local opts = { noremap = true, silent = true, buffer = args.buf }
      vim.keymap.set("n", "<A-j>", scroll_preview_down, opts)
      vim.keymap.set("n", "<A-k>", scroll_preview_up, opts)
    end,
  })

  -- 🧹 Закрытие предпросмотра при уходе из буфера
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    pattern = "NvimTree*",
    callback = function()
      close_preview()
    end,
  })
end

return M
