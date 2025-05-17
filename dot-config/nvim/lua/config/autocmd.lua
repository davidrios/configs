local myutils = require('myutils')

local my_augroup = vim.api.nvim_create_augroup('11ea7949-c92d-4a4e-85d6-5208fa4b3b44', { clear = true })

local function save_session()
  if not vim.g.mysession_was_loaded then
    return
  end

  if vim.fn.filereadable(myutils.SESSION_FILE) == 0 then
    return
  end

  vim.cmd('mksession! ' .. vim.fn.fnameescape(myutils.SESSION_FILE))
end

vim.api.nvim_create_autocmd('SessionLoadPost', {
  group = my_augroup,
  callback = function()
    if vim.v.this_session:sub(-#myutils.SESSION_FILE) ~= myutils.SESSION_FILE then
      return true
    end

    vim.g.mysession_was_loaded = 1
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false

    vim.api.nvim_create_autocmd({'BufEnter', 'VimEnter'}, {
      group = my_augroup,
      pattern = '*',
      callback = myutils.cached_fn(
        function()
          myutils.read_undo()
        end,
        function(ev) return ev.file end
      ),
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = my_augroup,
      pattern = '*',
      callback = myutils.write_undo,
    })

    -- vim.api.nvim_create_autocmd({'VimEnter'}, {
    --   group = my_augroup,
    --   pattern = '*',
    --   callback = myutils.handle_session_nvimtree,
    -- })

    vim.api.nvim_create_autocmd(
      'VimLeave',
      {
        group = my_augroup,
        callback = function()
          for _, n in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.bufname(n):match('NvimTree_[0-9]+') then
              vim.api.nvim_buf_delete(n, {force=true})
            end
          end
          return true
        end
      }
    )

    vim.api.nvim_create_autocmd(
      {
        'BufEnter',
        'BufFilePost',
        'BufWritePost',
        'VimLeave'
      },
      {
        group = my_augroup,
        callback = save_session
      }
    )

    if vim.fn.filereadable(myutils.RC_FILE) == 1 then
      vim.cmd('luafile ' .. vim.fn.fnameescape(myutils.RC_FILE))
    end

    return true
  end
})

-- vim.api.nvim_create_autocmd('SessionLoadPost', {
--   group = my_augroup,
--   callback = function(ev)
--     if not vim.g.mysession_was_loaded then
--       return
--     end
--
--     vim.print(myutils.str_join(' : ', {'sess ', vim.fn.expand('%'), vim.api.nvim_tabpage_get_number(0), vim.api.nvim_win_get_number(0)}))
--     if ev.file:match('NvimTree_[0-9]+$') then
--       -- vim.api.nvim_buf_delete(vim.fn.bufnr(ev.file), {force=true})
--       -- local winid = vim.fn.win_getid()
--       -- vim.cmd('NvimTreeFindFile')
--       -- vim.fn.win_gotoid(winid)
--     end
--   end
-- })

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  group = my_augroup,
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})
