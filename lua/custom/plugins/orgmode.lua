return {
  {
    'nvim-orgmode/orgmode',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-orgmode/telescope-orgmode.nvim',
      'nvim-orgmode/org-bullets.nvim',
      -- 'Saghen/blink.cmp',
    },
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
      require('orgmode').setup_ts_grammar() -- 确保 parser 能被识别
      require('orgmode').setup {
        org_agenda_files = '~/orgfiles/**/*',
        org_default_notes_file = '~/orgfiles/refile.org',
        org_todo_keywords = { 'TODO(t)', 'WAITING(w)', 'INPROGRESS(i)', '|', 'DONE(d)', 'CANCELED(c)' }, --竖线 | 分隔未完成和完成状态。括号中的字母为快速切换快捷键（如 ,tit 切换到 INPROGRESS）
        org_agenda_span = 'day', -- agenda视图只显示当天
        -- 捕获模板定义（快速添加任务、笔记等）
        org_capture_templates = {
          t = {
            description = 'Task',
            template = '* TODO %?\n  SCHEDULED: <%<%Y-%m-%d %A>>', -- %? 为光标位置，
            target = '~/orgfiles/tasks.org',
            headline = 'Inbox',
          },
          n = {
            description = 'Note',
            template = '* %?\n  %u', -- %u 插入当前时间（非活跃格式）
            target = '~/orgfiles/notes.org',
          },
        },
      }

      -- NOTE: If you are using nvim-treesitter with ~ensure_installed = "all"~ option
      -- add ~org~ to ignore_install
      -- require('nvim-treesitter.configs').setup({
      --   ensure_installed = 'all',
      --   ignore_install = { 'org' },
      -- })
      require('org-bullets').setup()
    end,
  },
  {
    'chipsenkbeil/org-roam.nvim',
    tag = '0.1.1',
    dependencies = {
      {
        'nvim-orgmode/orgmode',
        tag = '0.3.7',
      },
    },
    config = function()
      require('org-roam').setup {
        directory = '~/orgfiles/.org_roam_files',
        -- optional
        org_files = {
          '~/orgfiles',
        },
      }
    end,
  },
  {
    'nvim-orgmode/telescope-orgmode.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-orgmode/orgmode',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('telescope').load_extension 'orgmode'

      vim.keymap.set('n', '<leader>r', require('telescope').extensions.orgmode.refile_heading)
      vim.keymap.set('n', '<leader>fh', require('telescope').extensions.orgmode.search_headings)
      vim.keymap.set('n', '<leader>li', require('telescope').extensions.orgmode.insert_link)
    end,
  },
}
