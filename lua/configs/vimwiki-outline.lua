local function get_vimwiki_headings()
  local headings = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for line_num, line in ipairs(lines) do
    -- 匹配 Vimwiki 的 = 标题语法（兼容首尾空格）
    local level_str, title = line:match '^%s*(=+)(.-)=+%s*$'
    if level_str and title then
      title = title:gsub('^%s*(.-)%s*$', '%1') -- 清理标题内部空格
      local level = #level_str
      table.insert(headings, {
        text = string.rep('  ', level - 1) .. ' ' .. title, -- 使用树状图标
        line = line_num, -- 使用 1-based 行号
      })
    end
  end
  return headings
end

local function smart_outline()
  local filetype = vim.bo.filetype -- 获取当前文件类型

  if filetype == 'vimwiki' then
    -- Vimwiki 专属大纲逻辑
    local headings = get_vimwiki_headings()
    if #headings == 0 then
      vim.notify('No Vimwiki headings found!', vim.log.levels.WARN)
      return
    end

    -- 获取当前窗口尺寸
    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)

    -- 计算浮动窗口参数
    local width = math.floor(win_width * 0.3) -- 占窗口宽度的30%
    local max_height = math.floor(win_height * 0.8)
    local height = math.min(#headings + 2, max_height) -- 内容行数+边框

    -- 计算右侧居中位置
    local col = win_width - width - 1 -- 右侧留出1列边距
    local row = math.floor((win_height - height) / 2) -- 垂直居中

    -- 创建右侧浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'win', -- 相对于当前窗口
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      title = ' Vimwiki Outline ',
      title_pos = 'center',
    })

    -- 填充内容
    local lines = {}
    for _, h in ipairs(headings) do
      table.insert(lines, h.text)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- 设置高亮和跳转逻辑
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
      callback = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(win)
        local target_line = headings[cursor_pos[1]].line
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_win_set_cursor(0, { target_line, 0 })
      end,
    })

    -- 关闭窗口快捷键
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
      callback = function()
        vim.api.nvim_win_close(win, true)
      end,
    })
  else
    -- 其他文件类型使用 Lspsaga Outline
    if package.loaded['lspsaga'] then
      vim.cmd 'Lspsaga outline'
    else
      vim.notify('Lspsaga not loaded!', vim.log.levels.ERROR)
    end
  end
end
-- 统一映射快捷键
vim.keymap.set('n', '<leader>o', smart_outline, { desc = 'Toggle Smart Outline' })
