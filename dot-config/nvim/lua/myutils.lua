local sha1 = require("sha1")

local M = {}

local SESSION_FILE = ".neovim/session"
M.SESSION_FILE = SESSION_FILE

local RC_FILE = ".neovim/rc"
M.RC_FILE = RC_FILE

local UNDO_DIR = ".neovim/undo"
M.UNDO_DIR = UNDO_DIR

local function get_last_x(my_list, x)
  local len = #my_list
  local start_index = math.max(1, len - x + 1)
  local last_x = {}

  for i = start_index, len do
    table.insert(last_x, my_list[i])
  end

  return last_x
end
M.get_last_x = get_last_x

local function call_once(fn)
  local is_called = false
  local function wrapped()
    if is_called then
      return
    end
    is_called = true
    fn()
  end
  return wrapped
end
M.call_once = call_once

local function str_join(chr, arr, fn)
  if #arr == 0 then
    return ''
  end
  local rest = ''
  for i, p in vim.spairs(arr) do
    rest = rest .. ((i > 1) and chr or '') .. (fn ~= nil and fn(p, i) or p)
  end
  return rest
end
M.str_join = str_join

local function my_tab_label(n)
  local buflist = vim.fn.tabpagebuflist(n)
  local winnr = vim.fn.tabpagewinnr(n)
  local bufnr = buflist[winnr]
  local bufname = vim.fn.bufname(bufnr)
  if #bufname == 0 then
    bufname = '[No Name]'
  end

  local parts = get_last_x(vim.split(bufname, '/'), 3)
  local fname = table.remove(parts)

  local rest = str_join("/", parts, function(part) return part:sub(1, 3) end)
  if #rest > 0 then
    rest = '(' .. rest .. ')'
  end
  return n .. ':' .. fname .. (vim.bo[bufnr].modified and '*' or '') .. rest
end
M.my_tab_label = my_tab_label

local function my_tab_line()
  local s = ''
  local tabnr_last = vim.fn.tabpagenr('$')
  local tabnr_current = vim.fn.tabpagenr()

  for i = 1, tabnr_last do
    if i == tabnr_current then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end
    s = s .. '%' .. i .. 'T'
    s = s .. ' %{v:lua.require(\'myutils\').my_tab_label(' .. i .. ')}'
  end

  s = s .. '%#TabLineFill#%T'

  if tabnr_last > 1 then
    s = s .. '%=%#TabLine#%999Xclose'
  end

  return s
end
M.my_tab_line = my_tab_line

local undo_fname_cache = {}
local undo_path_levels = 3

local function gen_undo_fpath()
  local fpath = vim.fn.expand("%")
  if undo_fname_cache[fpath] then
    return undo_fname_cache[fpath]
  end
  local fname = sha1(fpath)
  local parts = {UNDO_DIR}
  for i = 1,undo_path_levels do
    table.insert(parts, string.sub(fname, i, i))
  end
  table.insert(parts, fname)
  undo_fname_cache[fpath] = parts
  return undo_fname_cache[fpath]
end
M.gen_undo_fpath = gen_undo_fpath
vim.api.nvim_create_user_command("MyUtilsUndoPath", function ()
  vim.print(str_join("/", gen_undo_fpath()))
end, {})

local redo_loaded = {}
local function read_undo()
  local undo_file_path = str_join("/", gen_undo_fpath())
  if redo_loaded[undo_file_path] then
    return
  end
  if vim.fn.filereadable(undo_file_path) == 1 then
    vim.cmd('silent rundo ' .. vim.fn.fnameescape(undo_file_path))
    redo_loaded[undo_file_path] = true
  end
end
M.read_undo = read_undo

local function write_undo()
  local undo_file_path = gen_undo_fpath()
  local fname = undo_file_path[#undo_file_path]
  local undo_file_dir = ""
  for i=1,#undo_file_path-1 do
    undo_file_dir = undo_file_dir .. (i > 1 and '/' or '') .. undo_file_path[i]
  end
  if #undo_file_dir > 0 then
    vim.fn.mkdir(undo_file_dir, "p")
  end
  vim.cmd('silent wundo ' .. vim.fn.fnameescape(undo_file_dir .. "/" .. fname))
end
M.write_undo = write_undo


return M
