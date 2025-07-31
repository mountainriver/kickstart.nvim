return {
  {
    'tools-life/taskwiki',
    dependencies = { 'vimwiki/vimwiki', 'nvim-lua/plenary.nvim' },
    ft = { 'markdown', 'vimwiki' },
    -- keys = {
    --   { "<leader>ww", ":VimwikiIndex<cr>", desc = "VimWiki Index" },
    --   { "<leader>wn", ":VimwikiMakeDiaryNote<cr>", desc = "New Diary Note" },
    -- },
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
          vim.cmd 'TaskWikiSync'
        end,
      })
    end,
  },
}
