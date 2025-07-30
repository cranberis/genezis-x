-- Плагин для поддержки форматирования через null-ls
return {
  "nvimtools/none-ls.nvim",
  config = function()
    require("null-ls-config") -- конфигурация находится в отдельном файле
  end,
}
