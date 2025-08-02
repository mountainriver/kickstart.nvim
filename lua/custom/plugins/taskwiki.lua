return {
  {
    'tools-life/taskwiki',
    --enabled = false,
    ft = 'vimwiki',
    dependencies = { 'vimwiki/vimwiki', 'nvim-lua/plenary.nvim' },
    -- keys = {
    --   { "<leader>ww", ":VimwikiIndex<cr>", desc = "VimWiki Index" },
    --   { "<leader>wn", ":VimwikiMakeDiaryNote<cr>", desc = "New Diary Note" },
    -- },
    init = function() -- 必须在 TaskWiki 内部逻辑之前设置
      vim.g.taskwiki_dont_fold = 1 -- 关闭折叠机制
      vim.g.taskwiki_dont_preserve_folds = 1 -- 关闭记忆折叠状态
      vim.g.taskwiki_disable_concealcursor = 1 -- 禁用 Taskwiki 隐藏
    end,
    config = function()
      --vim.g.vimwiki_list = {
      --  {
      --    path = '~/vimWiki',
      --    syntax = 'markdown',
      --    ext = '.md',
      --    diary_rel_path = 'diary',
      --    diary_frequency = 'daily',
      --  },
      --}
      vim.g.vimwiki_auto_header = 1 -- 保存时自动同步任务
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = { '*.md', '*.wiki' },
        callback = function()
          vim.cmd 'TaskWikiBufferSave'
        end,
      })
    end,
  },
}
