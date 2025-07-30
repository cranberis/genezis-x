-- Конфигурация плагина автодополнения nvim-cmp

return {
  "hrsh7th/nvim-cmp",           -- сам плагин автодополнения

  event = "InsertEnter",        -- загружать при входе в режим вставки

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",         -- поддержка автодополнения от LSP
    "hrsh7th/cmp-buffer",           -- предложения из текущего буфера
    "hrsh7th/cmp-path",             -- автодополнение путей к файлам
    "hrsh7th/cmp-cmdline",          -- автодополнение в командной строке
    "hrsh7th/cmp-git",              -- автодополнение для коммитов Git
    "saadparwaiz1/cmp_luasnip",     -- сниппеты от LuaSnip
    "L3MON4D3/LuaSnip",             -- сам движок сниппетов
  },

  config = function()
    local cmp = require("cmp")            -- сам модуль автодополнения
    local luasnip = require("luasnip")    -- модуль сниппетов

    -- Включаем автодополнение с поддержкой сниппетов
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)   -- используем LuaSnip для вставки сниппетов
        end,
      },

      window = {
        completion = cmp.config.window.bordered(),     -- границы окна предложений
        documentation = cmp.config.window.bordered(),  -- границы окна документации
      },

      formatting = {
        fields = { "abbr", "menu", "kind" },  -- порядок отображаемых полей
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),             -- прокрутка документации вверх
        ["<C-f>"] = cmp.mapping.scroll_docs(4),              -- прокрутка документации вниз
        ["<C-Space>"] = cmp.mapping.complete(),              -- вручную вызвать меню
        ["<C-e>"] = cmp.mapping.abort(),                     -- закрыть меню
        ["<CR>"] = cmp.mapping.confirm({ select = true }),   -- подтвердить выбор
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },     -- язык сервера (LSP)
        { name = "luasnip" },      -- сниппеты
        { name = "buffer" },       -- текущий буфер
        { name = "path" },         -- пути к файлам
      }, {
        { name = "nvim_lsp_signature_help" },  -- подсказки по сигнатурам функций
      }),
    })

    -- Отдельная настройка для коммитов Git
    cmp.setup.filetype("gitcommit", {
      sources = cmp.config.sources({
        { name = "cmp_git" },       -- предложения Git
      }, {
        { name = "buffer" },        -- + текущий буфер
      }),
    })

    -- Настройки автодополнения в командной строке `/` и `?`
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },        -- предложения из буфера
      },
    })

    -- Настройки автодополнения в командной строке `:`
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },          -- предложения путей
      }, {
        { name = "cmdline" },       -- команды Vim
      }),
    })

    -- Подключение LSP-сервера `tsserver` с возможностью автодополнения
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    require("lspconfig").tsserver.setup({
      capabilities = capabilities
    })
  end,
}
