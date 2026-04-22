-- Buffer tabs (VSCode-style strip across the top).
-- Not the same as :tabnew, which opens a separate "tab page" with its own window layout —
-- both work, this just gives you visual + keyboard switching for buffers.
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    opts = {
      options = {
        mode = 'buffers',
        diagnostics = 'nvim_lsp', -- show LSP squigglies in the tab label
        show_buffer_close_icons = true, -- click the "×" to close a buffer
        show_close_icon = false,
        buffer_close_icon = '×', -- compact Unicode × (not the nerd-font one)
        modified_icon = '●',
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        offsets = {
          { filetype = 'neo-tree', text = 'Explorer', highlight = 'Directory', text_align = 'left' },
        },
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)

      -- :q behavior — close current buffer instead of the window, UNLESS it's the last
      -- listed buffer (then fall through to a real quit). Same for :wq / :x via Wq/Xq.
      vim.api.nvim_create_user_command('Q', function(args)
        local listed = vim.fn.getbufinfo({ buflisted = 1 })
        if #listed <= 1 then
          vim.cmd('quit' .. (args.bang and '!' or ''))
        else
          vim.cmd('bdelete' .. (args.bang and '!' or '') .. ' %')
        end
      end, { bang = true, desc = 'Close buffer (or quit if last)' })

      -- Only alias when `q` is the entire command (so `:qa`, `:q!`, `:quit` etc. keep working).
      vim.cmd([[cnoreabbrev <expr> q  (getcmdtype() == ':' && getcmdline() ==# 'q')  ? 'Q'  : 'q']])
      vim.cmd([[cnoreabbrev <expr> q! (getcmdtype() == ':' && getcmdline() ==# 'q!') ? 'Q!' : 'q!']])
    end,
    keys = {
      -- Buffer switching (VSCode-ish; comment these out if you prefer <Tab>/<S-Tab>)
      { '<S-l>',      '<cmd>BufferLineCycleNext<cr>',       desc = 'Next buffer' },
      { '<S-h>',      '<cmd>BufferLineCyclePrev<cr>',       desc = 'Prev buffer' },
      { '<leader>bp', '<cmd>BufferLineTogglePin<cr>',       desc = '[B]uffer: [P]in' },
      { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>',     desc = '[B]uffer: close [O]thers' },
      { '<leader>x',  '<cmd>bdelete<cr>',                   desc = 'Close buffer' },
      -- Jump to buffer N by ordinal (<leader>1 .. <leader>9)
      { '<leader>1',  '<cmd>BufferLineGoToBuffer 1<cr>',    desc = 'Buffer 1' },
      { '<leader>2',  '<cmd>BufferLineGoToBuffer 2<cr>',    desc = 'Buffer 2' },
      { '<leader>3',  '<cmd>BufferLineGoToBuffer 3<cr>',    desc = 'Buffer 3' },
      { '<leader>4',  '<cmd>BufferLineGoToBuffer 4<cr>',    desc = 'Buffer 4' },
      { '<leader>5',  '<cmd>BufferLineGoToBuffer 5<cr>',    desc = 'Buffer 5' },
      { '<leader>6',  '<cmd>BufferLineGoToBuffer 6<cr>',    desc = 'Buffer 6' },
      { '<leader>7',  '<cmd>BufferLineGoToBuffer 7<cr>',    desc = 'Buffer 7' },
      { '<leader>8',  '<cmd>BufferLineGoToBuffer 8<cr>',    desc = 'Buffer 8' },
      { '<leader>9',  '<cmd>BufferLineGoToBuffer 9<cr>',    desc = 'Buffer 9' },
    },
  },
}
