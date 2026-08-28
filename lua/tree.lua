vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_banner = 0 -- hide the top banner
vim.g.netrw_winsize = 25 -- fix the left split width
vim.g.netrw_browse_split = 0 -- open files in the previous window
vim.g.netrw_altfile = 1 -- keep the alternate file correct

vim.keymap.set("n", "<leader>e", ":Lexplore<cr>", { silent = true })

-- netrw's built-in `%` opens new files in the netrw window instead of
-- respecting `netrw_browse_split`. Override it to open in the previous window.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "%", function()
			local fname = vim.fn.input("Enter filename: ")
			if fname == "" then
				return
			end

			local dir = vim.b.netrw_curdir or vim.fn.getcwd()
			local path = dir .. "/" .. fname

			if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
				vim.notify("Already exists: " .. fname, vim.log.levels.WARN)
				return
			end

			if fname:match("/$") then
				vim.fn.mkdir(path, "p")
				vim.cmd("edit")
			else
				local f = io.open(path, "w")
				if not f then
					vim.notify("Failed to create: " .. fname, vim.log.levels.ERROR)
					return
				end
				f:close()

				local escaped = vim.fn.fnameescape(path)
				if vim.fn.winnr("#") == 0 then
					vim.cmd("edit " .. escaped)
				else
					vim.cmd("wincmd p")
					vim.cmd("edit " .. escaped)
				end
			end
		end, { buffer = true, silent = true, noremap = true, desc = "Create file in previous window" })
	end,
})

vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/prichrd/netrw.nvim" },
}, { confirm = false, load = true })

require("nvim-web-devicons").setup({})

require("netrw").setup({
  use_devicons = true,
})

-- Show icons on a startup.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("NetrwInitialIcons", { clear = true }),
  callback = vim.schedule_wrap(function()
    if vim.bo.filetype == "netrw" then
      vim.api.nvim_exec_autocmds("OptionSet", {
        group = "netrw",
        pattern = "modified",
      })
    end
  end),
})
