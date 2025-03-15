-- 绑定 <leader>e 开关文件树
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', {
  desc = 'Toggle Neo-Tree', -- 描述（which-key 会显示）
  silent = true, -- 不显示命令输出
})

-- 切换到下一个/上一个 Buffer
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<S-h>', '<cmd>bprev<cr>', { desc = 'Previous Buffer' })
-- 快速关闭当前 Buffer
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete Buffer' })
