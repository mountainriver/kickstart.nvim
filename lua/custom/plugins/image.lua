return {
  {
    '3rd/image.nvim',
    config = function()
      require('image').setup {
        backend = 'kitty', -- 推荐使用 kitty 后端，若使用 Terminator，kitty 协议无法生效
        max_width = 380,
        max_height = 140,
        show_label = true,
      }
    end,
  },
}
