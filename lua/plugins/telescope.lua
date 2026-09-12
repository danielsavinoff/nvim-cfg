vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
}, {
  confirm = false,
  load = true,
})

require("telescope").setup({
  defaults = {
    initial_mode = "normal",
  },
})

require("telescope").load_extension("ui-select")

local telescope = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", telescope.find_files)
vim.keymap.set("n", "<leader>fg", telescope.live_grep)
vim.keymap.set("n", "<leader>fb", telescope.buffers)
vim.keymap.set("n", "<leader>fh", telescope.help_tags)
vim.keymap.set("n", "<leader>gs", telescope.git_status)
