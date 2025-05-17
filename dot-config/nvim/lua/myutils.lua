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

local function call_once_old(fn)
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
M.call_once_old = call_once_old

local CACHE_NIL_KEY = {}
local _cache_id = 0
local function cached_fn(fn, cache_key_fn)
  local cache = {}
  local cache_id = _cache_id
  _cache_id = _cache_id + 1
  local cache_cnt = 0

  local function wrapped(...)
    local key = CACHE_NIL_KEY
    if cache_key_fn ~= nil then
      key = cache_key_fn(...)
    end

    if key == nil then
      key = CACHE_NIL_KEY
    end

    if cache[key] ~= nil then
      local value = cache[key][1]
      cache_cnt = cache_cnt + 1
      vim.print(str_join(':', {'retrieved', cache_id, cache_cnt, key, value}, tostring))
      return value
    end

    local value = fn(...)
    cache[key] = {value}
    vim.print(str_join(':', {'computed', cache_id, key, value}, tostring))
    return value
  end
  return wrapped
end
M.cached_fn = cached_fn

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

local undo_path_levels = 3
local function _gen_undo_fpath(fpath)
  local fname = sha1(fpath)
  local parts = {UNDO_DIR}
  for i = 1,undo_path_levels do
    table.insert(parts, string.sub(fname, i, i))
  end
  table.insert(parts, fname)
  return parts
end
M._gen_undo_fpath = _gen_undo_fpath
local _cached_gen_undo_fpath = cached_fn(
  _gen_undo_fpath,
  function(fpath) return fpath end
)
M._cached_gen_undo_fpath = _cached_gen_undo_fpath

local function gen_undo_fpath(fpath)
  if fpath == nil then
    fpath = vim.fn.expand("%")
  end
  return _cached_gen_undo_fpath(fpath)
end
M.gen_undo_fpath = gen_undo_fpath
vim.api.nvim_create_user_command("MyUtilsUndoPath", function ()
  vim.print(str_join("/", gen_undo_fpath()))
end, {})

local function read_undo(fpath)
  local undo_file_path = str_join("/", gen_undo_fpath(fpath))
  if vim.fn.filereadable(undo_file_path) == 1 then
    vim.cmd('silent rundo ' .. vim.fn.fnameescape(undo_file_path))
    vim.print('readundo! ' .. undo_file_path)
  end
end
M.read_undo = read_undo
vim.api.nvim_create_user_command(
  "MyUtilsReadUndo",
  function () read_undo() end,
  {}
)

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

-- local cnt = 0
-- local function handle_session_nvimtree ()
--   -- local restorewin = nil
--   -- local delbuf = nil
--   -- local curtab = vim.api.nvim_tabpage_get_number(0)
--   -- local curwin = vim.api.nvim_win_get_number(0)
--   -- for _, w in ipairs(vim.api.nvim_tabpage_list_wins(curtab)) do
--   --   local bufnr = vim.api.nvim_win_get_buf(w)
--   --   if vim.fn.bufname(bufnr):match('NvimTree_[0-9]+') then
--   --     delbuf = bufnr
--   --   else
--   --     if w == curwin then
--   --       restorewin = w
--   --     end
--   --   end
--   -- end
--
--   -- local grestorewin = nil
--   -- local curtab = vim.api.nvim_tabpage_get_number(0)
--   -- local gcurwin = vim.api.nvim_win_get_number(0)
--   -- for _, t in ipairs(vim.api.nvim_list_tabpages()) do
--   --   local restorewin = nil
--   --   local delbuf = nil
--   --   for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
--   --     local bufnr = vim.api.nvim_win_get_buf(w)
--   --     if vim.fn.bufname(bufnr):match('NvimTree_[0-9]+') then
--   --       delbuf = bufnr
--   --     else
--   --       if w == gcurwin then
--   --         grestorewin = w
--   --       end
--   --     end
--   --   end
--   -- end
--
--   local restored = false
--   for _, n in ipairs(vim.api.nvim_list_bufs()) do
--     if vim.fn.bufname(n):match('NvimTree_[0-9]+') then
--       vim.api.nvim_buf_delete(n, {force=true})
--       if not restored then
--         restored = true
--         local winid = vim.fn.win_getid()
--         vim.cmd('NvimTreeFindFile')
--         vim.fn.win_gotoid(winid)
--       end
--     end
--   end
--
--   vim.print('nvim tree! ' .. cnt)
-- end
-- M.handle_session_nvimtree = handle_session_nvimtree
-- vim.api.nvim_create_user_command("MyUtilsSessionNvimTree", handle_session_nvimtree, {})

return M
