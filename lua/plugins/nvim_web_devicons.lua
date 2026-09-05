-- install nvim-web-devicons and its dependency
vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/prichrd/netrw.nvim" },
}, { confirm = false, load = true })

-- setup icons
require("nvim-web-devicons").setup({})

-- setup dependency
require("netrw").setup({
  use_devicons = true,
})

-- prevent icons from disappearing
vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = vim.api.nvim_create_augroup("NetrwFocusIcons", { clear = true }),
  callback = function()
    vim.defer_fn(function()
      local buf = vim.api.nvim_get_current_buf()

      if vim.bo[buf].filetype == "netrw" then
        require("netrw.ui").embelish(buf)
        vim.cmd("redraw!")
      end
    end, 50)
  end,
})
