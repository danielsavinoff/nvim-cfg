vim.pack.add({
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
}, { confirm = false, load = true })

require("mason-lspconfig").setup()
