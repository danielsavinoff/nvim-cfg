vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
}, { confirm = false, load = true })

require("mason").setup()
