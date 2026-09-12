vim.pack.add({
  { src = "https://github.com/Erl-koenig/theme-hub.nvim" },
}, { confirm = false, load = true })

require("theme-hub").setup({
  persistent = true,
})
