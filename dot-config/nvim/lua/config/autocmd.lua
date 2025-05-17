local myutils = require('myutils')

local my_augroup = vim.api.nvim_create_augroup('11ea7949-c92d-4a4e-85d6-5208fa4b3b44', { clear = true })

local function save_session()
  if vim.g.mysession_was_loaded == nil then
    return
  end

  if vim.fn.filereadable(vim.g.mysession_was_loaded) == 0 then
    return
  end

  vim.cmd('mksession! ' .. vim.fn.fnameescape(vim.g.mysession_was_loaded))
end

vim.api.nvim_create_autocmd('SessionLoadPost', {
  group = my_augroup,
  callback = function()
    local sessionfpath = myutils.relative_to_cwd(vim.v.this_session)
    if sessionfpath:sub(1, #myutils.SESSION_FILE) ~= myutils.SESSION_FILE then
      return true
    end

    -- vim.print('session loaded!')

    vim.g.mysession_was_loaded = sessionfpath
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false

    local read_undo_cached = myutils.CachedFn:new(
      function(fpath)
        myutils.read_undo(fpath)
        -- vim.print('readundo!' .. fpath)
      end,
      myutils.cache_key_1
    )

    vim.api.nvim_create_autocmd({'BufEnter', 'VimEnter'}, {
      group = my_augroup,
      pattern = '*',
      callback = function(ev)
        if #ev.file == 0 then
          return
        end
        local fpath = ev.file
        if fpath:sub(1, 1) == '/' then
          fpath = myutils.relative_to_cwd(ev.file)
        end
        read_undo_cached(fpath)
      end,
    })

    vim.api.nvim_create_autocmd('BufDelete', {
      group = my_augroup,
      pattern = '*',
      callback = function(ev)
        if #ev.file == 0 then
          return
        end
        local fpath = ev.file
        if fpath:sub(1, 1) == '/' then
          fpath = myutils.relative_to_cwd(ev.file)
        end
        read_undo_cached:remove_key(fpath)
        -- vim.print('removed_undo:' .. fpath)
      end
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = my_augroup,
      pattern = '*',
      callback = function(ev)
        return myutils.write_undo(myutils.relative_to_cwd(ev.file))
      end,
    })

    vim.api.nvim_create_autocmd(
      'VimLeave',
      {
        group = my_augroup,
        callback = function()
          for _, n in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.bufname(n):match('NvimTree_[0-9]+')
               or vim.fn.bufname(n):match('undotree_[0-9]+') then
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

    local suffix = sessionfpath:sub(#myutils.SESSION_FILE + 1)
    if #suffix > 0 then
      local rc_file = myutils.RC_FILE .. suffix
      if vim.fn.filereadable(rc_file) == 1 then
        vim.cmd('luafile ' .. vim.fn.fnameescape(rc_file))
      end
    end

    return true
  end
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  group = my_augroup,
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})
