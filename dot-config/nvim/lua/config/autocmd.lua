local myutils = require("myutils")

local undo_augroup = vim.api.nvim_create_augroup('UndoFileManagement', { clear = true })

vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = myutils.call_once(function()
    if vim.v.this_session:sub(-#myutils.SESSION_FILE) ~= myutils.SESSION_FILE then
      return
    end

    vim.g.mysession_was_loaded = 1
    if vim.fn.filereadable(myutils.RC_FILE) == 1 then
      vim.cmd("luafile " .. myutils.RC_FILE)
    end
    vim.opt.swapfile = false
    vim.opt.backup = false
    vim.opt.undofile = false

    vim.api.nvim_create_autocmd({'BufEnter', 'VimEnter'}, {
      group = undo_augroup,
      pattern = '*',
      callback = myutils.read_undo,
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = undo_augroup,
      pattern = '*',
      callback = myutils.write_undo,
    })

  end),
})

local function save_session()
  if not vim.g.mysession_was_loaded then
    return
  end

  if vim.fn.filereadable(myutils.SESSION_FILE) == 0 then
    return
  end

  vim.cmd("mksession! " .. myutils.SESSION_FILE)
end

vim.api.nvim_create_autocmd(
  {
    "BufEnter",
    "BufFilePost",
    "BufWritePost",
    "VimLeave"
  },
  {
    callback = save_session
  }
)
