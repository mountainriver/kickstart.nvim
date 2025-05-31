return {
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- 自定义调色板
      local customPalette = {
        wave = {
          -- 覆盖 wave 主题特定颜色
          peachRed = '#FF5F87', -- 更鲜艳的错误色
          carpYellow = '#FFB454', -- 更明亮的警告色
        },
        all = {
          -- 全局覆盖
          sumiInk1b = '#1a1918', -- 主背景色
          fujiWhite = '#DCD7BA', -- 主文本色
        },
      }

      require('kanagawa').setup {
        theme = 'dragon', -- 使用 dragon 主题
        transparent = true, -- 透明背景

        -- 自定义背景效果
        dimInactive = true, -- 非活动窗口变暗
        dimPercentage = 15, -- 变暗程度 (0-100)

        -- 语法高亮增强
        keywordStyle = { italic = false, bold = true }, -- 关键字加粗
        commentStyle = { italic = true }, -- 注释斜体
        functionStyle = { bold = true }, -- 函数名加粗

        -- 集成插件支持
        overrides = function(palette)
          local colors = {}
          -- 自定义标题颜色
          colors['@text.title'] = { fg = palette.carpYellow, bold = true }

          -- 自定义错误样式
          colors.DiagnosticError = { fg = palette.peachRed, undercurl = true }

          -- 浮动窗口透明
          colors.NormalFloat = { bg = 'none' }
          colors.FloatBorder = { bg = 'none', fg = palette.dragonBlue }
          -- 普通行号
          colors.LineNr = {
            fg = '#8c8a87', -- 主题内置的标准灰色
            bg = 'none', -- 透明背景
          } -- 当前行号
          colors.CursorLineNr = {
            fg = palette.carpYellow, -- 更亮的黄色
            bold = true, -- 加粗
            italic = true, -- 斜体
          }
          -- 折叠区域行号
          colors.FoldedLineNr = { fg = palette.fujiGray } -- 灰色

          return colors
        end,

        -- 应用自定义调色板
        colors = customPalette,
      }

      vim.cmd.colorscheme 'kanagawa'

      -- 额外高亮设置，会覆盖部分设置
      --vim.api.nvim_set_hl(0, 'LineNr', { fg = 'none', bg = 'none' })
    end,
  },
}
