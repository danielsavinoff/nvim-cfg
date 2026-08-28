vim.opt.grepprg = "grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist"
vim.opt.grepformat = "%f:%l:%m"

vim.keymap.set("n", "<leader>g", function()
	vim.ui.input({ prompt = "Grep: " }, function(pattern)
		if pattern then
			vim.cmd("silent grep! " .. vim.fn.fnameescape(pattern))
			vim.cmd("copen")
		end
	end)
end, { silent = true })
