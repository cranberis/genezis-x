
-- 🔍 Diffview.nvim — визуальное сравнение изменений между коммитами
return {
  {
    "sindrets/diffview.nvim",         -- сам плагин
    event = "VeryLazy",               -- загружается лениво при вызове :Diffview*
    dependencies = {
      "nvim-lua/plenary.nvim",        -- обязательная зависимость
    },
    -- 🔧 Настройка прямо в декларации — загрузится, когда плагин будет доступен
    config = function()
      require("diffview").setup({
        use_icons = true, -- включаем иконки (если devicons установлены)
      })
    end,
  },
}
