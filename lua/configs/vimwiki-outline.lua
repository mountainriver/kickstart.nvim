-- 全局变量
local outline_win, outline_buf, main_win_id
local ns_id = vim.api.nvim_create_namespace 'vimwiki_outline'

local function get_vimwiki_headings()
  local headings = {}
  -- 通过主窗口 ID获取对应的 buffer ID
  local main_buf = vim.api.nvim_win_get_buf(main_win_id)
  local lines = vim.api.nvim_buf_get_lines(main_buf, 0, -1, false)
  for line_num, line in ipairs(lines) do
    local level_str, title = line:match '^%s*(=+)(.-)=+%s*$'
    if level_str and title then
      title = title:gsub('^%s*(.-)%s*$', '%1')
      local level = #level_str
      table.insert(headings, {
        text = string.rep('  ', level - 1) .. '  ' .. title,
        line = line_num,
      })
    end
  end
  return headings
end

local function find_heading_index_for_line(line, headings)
  local index = 1
  for i, h in ipairs(headings) do
    if h.line <= line then
      index = i
    else
      break
    end
  end
  return index
end

-- main_cursor 参数表示主窗口的当前行号
local function update_outline_cursor(main_cursor)
  if not (outline_win and vim.api.nvim_win_is_valid(outline_win)) then
    return
  end
  local headings = get_vimwiki_headings()
  local index = find_heading_index_for_line(main_cursor, headings)

  -- 同步移动 outline 窗口光标
  vim.api.nvim_win_set_cursor(outline_win, { index, 0 })
  -- 添加视觉高亮
  vim.api.nvim_buf_clear_namespace(outline_buf, ns_id, 0, -1)
  vim.api.nvim_buf_add_highlight(outline_buf, ns_id, 'Visual', index - 1, 0, -1)
end

-- main_cursor 参数是主窗口光标行号
local function open_or_update_outline(main_cursor)
  local headings = get_vimwiki_headings()
  if #headings == 0 then
    vim.notify('未找到 Vimwiki 标题！', vim.log.levels.WARN)
    return
  end

  local win_width = vim.api.nvim_win_get_width(main_win_id)
  local win_height = vim.api.nvim_win_get_height(main_win_id)
  local width = math.floor(win_width * 0.3)
  local height = math.min(#headings + 2, math.floor(win_height * 0.8))

  -- 根据主窗口光标计算 outline 窗口的垂直位置
  local row = math.max(0, math.min(main_cursor - math.floor(height / 2), win_height - height))
  local col = win_width - width - 1

  local lines = {}
  for _, h in ipairs(headings) do
    table.insert(lines, h.text)
  end

  if outline_win and vim.api.nvim_win_is_valid(outline_win) then
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
    outline_buf = vim.api.nvim_create_buf(false, true)
    -- 打开新窗口时将其激活（第二个参数设为 true）
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
    vim.api.nvim_buf_set_lines(outline_buf, 0, -1, false, lines)

    vim.api.nvim_buf_set_keymap(outline_buf, 'n', '<CR>', '', {
      callback = function()
        local cursor = vim.api.nvim_win_get_cursor(outline_win)
        local target = headings[cursor[1]].line
        vim.api.nvim_win_close(outline_win, true)
        outline_win = nil
        vim.api.nvim_win_set_cursor(main_win_id, { target, 0 })
      end,
      noremap = true,
      silent = true,
    })

    vim.api.nvim_buf_set_keymap(outline_buf, 'n', 'q', '', {
      callback = function()
        vim.api.nvim_win_close(outline_win, true)
        outline_win = nil
      end,
      noremap = true,
      silent = true,
    })
  end

  update_outline_cursor(main_cursor)
end

local function smart_outline()
  if vim.bo.filetype == 'vimwiki' then
    -- 在打开 outline 前，先记录主窗口信息
    main_win_id = vim.api.nvim_get_current_win()
    local main_cursor = vim.api.nvim_win_get_cursor(main_win_id)[1]
    open_or_update_outline(main_cursor)
  else
    if package.loaded['lspsaga'] then
      vim.cmd 'Lspsaga outline'
    else
      vim.notify('Lspsaga 未加载！', vim.log.levels.ERROR)
    end
  end
end

vim.keymap.set('n', '<leader>o', smart_outline, { desc = 'Toggle Smart Outline' })

-- 当 Vimwiki 内容变化时更新大纲
vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
  pattern = '*.wiki',
  callback = function()
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
      local main_cursor = vim.api.nvim_win_get_cursor(main_win_id)[1]
      open_or_update_outline(main_cursor)
    end
  end,
})

-- 主窗口光标移动时（注意只监控主窗口所在的 buffer），同步更新大纲高亮
vim.api.nvim_create_autocmd('CursorMoved', {
  pattern = '*.wiki',
  callback = function()
    if outline_win and vim.api.nvim_win_is_valid(outline_win) then
      local main_cursor = vim.api.nvim_win_get_cursor(main_win_id)[1]
      update_outline_cursor(main_cursor)
    end
  end,
})
