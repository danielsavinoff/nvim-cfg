local M = {}
local root_directory

local function listing_paths()
  local paths = {}
  local parents = { [0] = vim.w.netrw_treetop or vim.b.netrw_curdir }
  if vim.w.netrw_liststyle ~= 3 or not parents[0] then
    return paths
  end
  for line, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local depth = 0
    while text:sub(1, 2) == "| " or text:sub(1, 4) == "│ " do
      text = text:sub(text:sub(1, 2) == "| " and 3 or 5)
      depth = depth + 1
    end
    if depth > 0 and parents[depth - 1] then
      local path = vim.fs.joinpath(parents[depth - 1], (text:gsub("[/@*=|]$", "")))
      paths[line] = path
      parents[depth] = path
    end
  end
  return paths
end

local function capture_window()
  return {
    directory = root_directory,
    expanded = vim.tbl_keys(vim.w.netrw_treedict or {}),
    style = vim.w.netrw_liststyle or vim.g.netrw_liststyle,
    view = vim.fn.winsaveview(),
    selected = vim.fn.getline("."),
    selected_path = listing_paths()[vim.fn.line(".")],
  }
end

local function restore_view(state)
  local view = vim.deepcopy(state.view)
  -- Prefer the same entry if files were inserted before the saved cursor.
  local nearest
  local paths = listing_paths()
  for line, text in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local matches = state.selected_path and paths[line] == state.selected_path
      or not state.selected_path and text == state.selected
    if matches and (not nearest or math.abs(line - view.lnum) < math.abs(nearest - view.lnum)) then
      nearest = line
    end
  end
  view.lnum = nearest or math.min(view.lnum, vim.api.nvim_buf_line_count(0))
  vim.fn.winrestview(view)
end

local group = vim.api.nvim_create_augroup("netrw_session", { clear = true })
vim.api.nvim_create_autocmd("BufLeave", {
  group = group,
  callback = function()
    if vim.bo.filetype == "netrw" then
      vim.w.netrw_session_state = capture_window()
    end
  end,
})

function M.save()
  local states = {}
  for tab, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for window, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      vim.api.nvim_win_call(win, function()
        local visible = vim.bo.filetype == "netrw"
        local state = visible and capture_window() or vim.w.netrw_session_state
        if state then
          state.tab = tab
          state.window = window
          state.visible = visible
          table.insert(states, state)
        end
      end)
    end
  end
  return vim.json.encode({ netrw = states })
end

local function restore_window(state)
  state = vim.deepcopy(state)
  state.directory = root_directory
  if vim.fn.isdirectory(state.directory) == 0 then
    return
  end

  -- Rebuild the listing from disk; session files only retain its buffer name.
  vim.w.netrw_treetop = nil
  vim.w.netrw_treedict = nil
  vim.w.netrw_liststyle = state.style
  vim.fn["netrw#LocalBrowseCheck"](state.directory)
  -- A file several directories below the project root must be visible.
  local parent = state.selected_path and vim.fs.dirname(state.selected_path)
  while parent and parent ~= state.directory and vim.startswith(parent, state.directory .. "/") do
    if not vim.tbl_contains(state.expanded, parent) then
      table.insert(state.expanded, parent)
    end
    parent = vim.fs.dirname(parent)
  end
  table.sort(state.expanded, function(a, b)
    return #a < #b
  end)
  for _, directory in ipairs(state.expanded) do
    if directory ~= state.directory and vim.startswith(directory, state.directory .. "/")
      and vim.fn.isdirectory(directory) == 1 then
      vim.fn["netrw#LocalBrowseCheck"](directory)
    end
  end

  restore_view(state)
end

local function restore_history(state)
  if state.visible == false then
    vim.w.netrw_session_state = state
  else
    restore_window(state)
  end
end

function M.rex()
  if vim.bo.filetype == "netrw" then
    vim.w.netrw_session_state = capture_window()
    vim.cmd("Rexplore")
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  local state = vim.w.netrw_session_state or {
    directory = root_directory,
    expanded = {},
    style = 3,
    view = { lnum = 1, col = 0, topline = 1 },
    selected_path = file,
  }
  restore_window(state)
  vim.w.netrw_rexfile = vim.fn.fnameescape(file)
end

function M.restore(_, data)
  local tabs = vim.api.nvim_list_tabpages()
  for _, state in ipairs(vim.json.decode(data).netrw or {}) do
    local tab = tabs[state.tab]
    local win = tab and vim.api.nvim_tabpage_list_wins(tab)[state.window]
    if win then
      vim.api.nvim_win_call(win, function()
        restore_history(state)
      end)
    end
  end
end

local session_path
local session_enabled = false

function M.save_session()
  if not session_enabled then
    return
  end
  local data = M.save()
  vim.fn.mkdir(vim.fs.dirname(session_path), "p")
  vim.cmd.mksession({ args = { vim.fn.fnameescape(session_path) }, bang = true })
  vim.fn.writefile({ data }, session_path .. ".json")
end

function M.load_session()
  if vim.fn.filereadable(session_path) == 0 then
    return
  end
  local data
  if vim.fn.filereadable(session_path .. ".json") == 1 then
    data = table.concat(vim.fn.readfile(session_path .. ".json"), "\n")
  end
  vim.cmd.source(vim.fn.fnameescape(session_path))
  if data then
    M.restore(nil, data)
  end
end

function M.setup(opts)
  opts = opts or {}
  local args = vim.fn.argv()
  local directory = vim.fn.getcwd()
  if #args > 0 then
    directory = vim.fn.fnamemodify(args[1], vim.fn.isdirectory(args[1]) == 1 and ":p" or ":p:h")
  end
  directory = vim.fs.normalize(directory):gsub("(.)/$", "%1")
  root_directory = directory
  local function encode(path)
    return (path:gsub("[^%w%-_]", function(char)
      return string.format("%%%02X", string.byte(char))
    end))
  end
  session_path = (opts.directory or vim.fn.stdpath("state") .. "/netrw_session")
    .. "/" .. encode(root_directory) .. ".vim"
  local restore_on_start = #args == 0 or (#args == 1 and vim.fn.isdirectory(args[1]) == 1)
  session_enabled = true

  vim.api.nvim_create_user_command("Rex", M.rex, {
    desc = "Return to the project tree and its saved cursor position",
  })
  local lifecycle = vim.api.nvim_create_augroup("netrw_session_lifecycle", { clear = true })
  local function has_ui()
    return #vim.api.nvim_list_uis() > 0 or opts.headless == true
  end
  -- Reloading the config happens after VimEnter, so enable saving immediately.
  local interactive = vim.v.vim_did_enter == 1 and has_ui()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = lifecycle,
    nested = true,
    callback = function()
      -- Check after startup, when the UI has attached. Headless commands must
      -- not overwrite interactive sessions.
      interactive = has_ui()
      if restore_on_start and interactive then
        local ok, err = pcall(M.load_session)
        if not ok then
          session_enabled = false
          vim.notify("Could not restore session: " .. err, vim.log.levels.ERROR)
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = lifecycle,
    callback = function()
      if interactive then
        M.save_session()
      end
    end,
  })
end

M.setup()

return M
