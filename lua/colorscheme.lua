vim.pack.add({
  { src = "https://github.com/projekt0n/github-nvim-theme" },
})

vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
  },
}, { confirm = false, load = true })

-- Install missing parsers and wait until they are ready.
require("nvim-treesitter")
  .install({ "typescript", "tsx", "javascript" })
  :wait(300000)

-- Enable highlighting automatically.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
  pattern = {
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
  },
  callback = function(event)
    vim.treesitter.start(event.buf)
  end,
})

vim.opt.termguicolors = true

vim.cmd.colorscheme("github_dark_default")
