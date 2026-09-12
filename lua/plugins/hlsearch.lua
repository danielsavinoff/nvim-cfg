vim.pack.add({
  { src = "https://github.com/nvimdev/hlsearch.nvim" },
}, { confirm = false, load = true })

require("hlsearch").setup()
