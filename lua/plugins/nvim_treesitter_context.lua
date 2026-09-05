vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter-context",
  },
})

local context = require("treesitter-context")

context.setup({
  enable = true,
  max_lines = 3,
  trim_scope = "outer",
})

vim.keymap.set("n", "[c", function()
  context.go_to_context(vim.v.count1)
end, { silent = true })
