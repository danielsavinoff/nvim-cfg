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
  attach_to_untracked = true,
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']ch', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[ch', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)

    -- Unstaged change: working tree vs index 
    map('n', '<leader>hd', gitsigns.diffthis)

    -- All uncommitted changes: working tree vs HEAD
    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end)

    -- Show list of hunks in a buffer
    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>td', gitsigns.toggle_deleted)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
})

-- Close Gitsigns diff.
vim.keymap.set("n", "<leader>hc", function()
  local current = vim.api.nvim_get_current_win()

  vim.cmd("diffoff!")

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    if win ~= current and name:match("^gitsigns://") then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { desc = "Close Gitsigns diff" })

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
