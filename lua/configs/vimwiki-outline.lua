-- 全局变量存储大纲窗口和缓冲区
local outline_win, outline_buf

local function get_vimwiki_headings()
  local headings = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for line_num, line in ipairs(lines) do
    local level_str, title = line:match '^%s*(=+)(.-)=+%s*$'
    if level_str and title then
      title = title:gsub('^%s*(.-)%s*$', '%1')
      local level = #level_str
      table.insert(headings, {
        text = string.rep('  ', level - 1) .. '󰛓  ' .. title,
        line = line_num, -- 1-based 行号
      })
    end
  end
  return headings
end

local function open_or_update_outline()
  local headings = get_vimwiki_headings()
  if #headings == 0 then
    vim.notify('未找到 Vimwiki 标题！', vim.log.levels.WARN)
    return
  end

  -- 获取当前窗口尺寸
  local win_width = vim.api.nvim_win_get_width(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local width = math.floor(win_width * 0.3) -- 占窗口宽度的30%
  local max_height = math.floor(win_height * 0.8)
  local height = math.min(#headings + 2, max_height)
  local col = win_width - width - 1
  local row = math.floor((win_height - height) / 2)

  if outline_win and vim.api.nvim_win_is_valid(outline_win) then
    -- 更新大纲窗口的内容和尺寸
    local lines = {}
    for _, h in ipairs(headings) do
      table.insert(lines, h.text)
    end
    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, lines)
    vim.api.nvim_win_set_config(outline_win, {
      relative = 'win',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      title = ' Vimwiki Outline ',
      title_pos = 'center',
    })
  else
    -- 创建新的大纲窗口
    outline_buf = vim.api.nvim_create_buf(false, true)
    outline_win = vim.api.nvim_open_win(outline_buf, true, {
      relative = 'win',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      title = ' Vimwiki Outline ',
      title_pos = 'center',
    })
    local lines = {}
    for _, h in ipairs(headings) do
      table.insert(lines, h.text)
    end
    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, lines)

    -- 设置回车键实现跳转功能
    vim.api.nvim_buf_set_keymap(outline_buf, 'n', '<CR>', '', {
      callback = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(outline_win)
        local target_line = headings[cursor_pos[1]].line
        vim.api.nvim_win_close(outline_win, true)
        outline_win = nil
        vim.api.nvim_win_set_cursor(0, { target_line, 0 })
      end,
      noremap = true,
      silent = true,
    })
    -- 设置 q 键关闭大纲窗口
    vim.api.nvim_buf_set_keymap(outline_buf, 'n', 'q', '', {
      callback = function()
        vim.api.nvim_win_close(outline_win, true)
        outline_win = nil
      end,
      noremap = true,
      silent = true,
    })
  end
end

local function smart_outline()
  if vim.bo.filetype == 'vimwiki' then
    -- 如果大纲窗口已存在且当前窗口不是大纲窗口，则切换到大纲窗口
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
      if vim.api.nvim_get_current_win() ~= outline_win then
        vim.api.nvim_set_current_win(outline_win)
        return
      end
    end
    open_or_update_outline()
  else
    if package.loaded['lspsaga'] then
      vim.cmd 'Lspsaga outline'
    else
      vim.notify('Lspsaga 未加载！', vim.log.levels.ERROR)
    end
  end
end

-- 映射快捷键
vim.keymap.set('n', '<leader>o', smart_outline, { desc = 'Toggle Smart Outline' })

-- 当 Vimwiki 内容变化时自动更新大纲
vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
  pattern = '*.wiki',
  callback = function()
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
      open_or_update_outline()
    end
  end,
})
