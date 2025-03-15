return {
  'vimwiki/vimwiki',
  init = function()
    vim.g.vimwiki_conceal_pre = 1
    vim.g.vimwiki_toc_link_format = 0
    vim.g.vimwiki_global_ext = 0 --避免.md的filetype被设置为vimwiki

    -- 定义三个 Wiki 实例
    local wiki_1 = {
      path = vim.fn.expand '~/vimWiki/work/', -- 使用绝对路径
      path_html = vim.fn.expand '~/vimWiki_html/work_html',
      nested_syntaxes = {
        ['bash'] = 'bash',
        ['python'] = 'python',
        ['c++'] = 'cpp', -- 确保键名用 [] 包裹
      },
      auto_toc = 1,
    }

    local wiki_2 = {
      path = vim.fn.expand '~/vimWiki/live/',
      path_html = vim.fn.expand '~/vimWiki_html/live_html',
      auto_toc = 1,
    }

    local wiki_3 = {
      name = 'learn',
      path = vim.fn.expand '~/vimWiki/learn/',
      path_html = vim.fn.expand '~/vimWiki_html/learn_html',
      auto_toc = 1,
    }

    vim.g.vimwiki_list = { wiki_1, wiki_2, wiki_3 }

    -- 绑定快捷键（示例）
    --vim.keymap.set('n', '<Space>', '<cmd>VimwikiToggleListItem<CR>', { noremap = true, silent = true })
  end,
}
