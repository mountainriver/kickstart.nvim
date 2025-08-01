vim.api.nvim_create_autocmd({
  'BufReadPost',
  'BufNewFile', -- 当打开或新建一个文件时触发执行
}, {
  pattern = vim.env.HOME .. '/vimWiki/work/diary/*.wiki', -- 匹配文件路径才执行
  callback = function()
    vim.bo.filetype = 'taskwiki' -- 将 buffer 的 filetype 设置为 taskwiki，从而加载taskwiki插件
  end,
})
