local myutils = require("myutils")

vim.api.nvim_create_autocmd("SessionLoadPost", {
  callback = myutils.call_once(function()
    vim.g.session_was_loaded = 1
    if vim.fn.filereadable(myutils.RC_FILE) == 1 then
      vim.cmd("luafile " .. myutils.RC_FILE)
    end
  end),
})

local function save_session()
  if not vim.g.session_was_loaded then
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
