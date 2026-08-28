vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
}, { confirm = false, load = true })

vim.opt.signcolumn = "yes"

local gitsigns = require("gitsigns")

local function format_blame(name, info)
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1

  if #vim.diagnostic.get(0, { lnum = line }) > 0 then
    return {}
  end

	local template = "  <author>, <author_time:%R> — <summary>"

	local text = require("gitsigns.blame_formatter").expand_string(
    template, name, info, { self_author_text = "You" }
  )

  return { { text, "GitSignsCurrentLineBlame" } }
end

gitsigns.setup({
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 0,
    virt_text_pos = "eol",
  },
  current_line_blame_formatter = format_blame,
  current_line_blame_formatter_nc = format_blame,
})

-- Recheck even when diagnostics change without cursor movement.
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("GitBlameDiagnostics", { clear = true }),
  callback = function(event)
    if event.buf ~= vim.api.nvim_get_current_buf() then
      return
    end

    gitsigns.toggle_current_line_blame(false)
    gitsigns.toggle_current_line_blame(true)
  end,
})
