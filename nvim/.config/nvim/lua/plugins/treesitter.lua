return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  dependencies = {
{ 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
  },
  build = ':TSUpdate',
  config = function()
    -- The new main branch of nvim-treesitter dropped the old configs module
    -- entirely. Parser management now goes through require('nvim-treesitter')
    -- and highlight/indent are handled by Neovim's built-in treesitter support.
    require('nvim-treesitter').setup {
      ensure_installed = {
        'c', 'cpp', 'c_sharp', 'go', 'lua', 'python', 'rust',
        'tsx', 'typescript', 'vimdoc', 'vim', 'bash', 'json',
        'toml', 'yaml', 'markdown',
      },
      auto_install = false,
    }

    -- Textobjects are configured through the textobjects plugin directly
    -- now that the old configs module is gone.
    require('nvim-treesitter-textobjects').setup {
      select = {
        lookahead = true,
        keymaps = {
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        set_jumps = true,
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        swap_next = {
          ['<C-a>'] = '@parameter.inner',
        },
        swap_previous = {
          ['<C-A>'] = '@parameter.inner',
        },
      },
    }
  end,
}
