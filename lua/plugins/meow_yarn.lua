vim.pack.add({
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/retran/meow.yarn.nvim" },
}, { confirm = false, load = true })

require("meow.yarn").setup({})

vim.keymap.set("n", "<leader>yS", "<Cmd>MeowYarn type super<CR>", { desc = "Yarn: Super Types" })
vim.keymap.set("n", "<leader>ys", "<Cmd>MeowYarn type sub<CR>", { desc = "Yarn: Sub Types" })
vim.keymap.set("n", "<leader>yC", "<Cmd>MeowYarn call callers<CR>", { desc = "Yarn: Callers" })
vim.keymap.set("n", "<leader>yc", "<Cmd>MeowYarn call callees<CR>", { desc = "Yarn: Callees" })
