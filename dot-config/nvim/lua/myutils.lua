local M = {}

local SESSION_FILE = ".neovim-session"
M.SESSION_FILE = SESSION_FILE

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
  local fn = fn
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

  local rest = ''
  if #parts > 0 then
    for i, p in vim.spairs(parts) do rest = rest .. ((i > 1) and '/' or '') .. p:sub(1, 3) end
  end
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

return M
