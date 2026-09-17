-- Highlight, edit, and navigate code.
--
-- This tracks nvim-treesitter's `main` branch, which is a full rewrite of the
-- `master` branch: the `configs` module is gone, `ensure_installed` is not a
-- setup option, and the highlight/indent/incremental_selection modules no
-- longer exist. Parser installation is now an explicit call, and highlighting
-- is Neovim's built-in treesitter, started per buffer by hand.

local ensure_installed = {
  'bash', 'c', 'c_sharp', 'cpp', 'go', 'json', 'lua', 'markdown',
  'markdown_inline', 'python', 'query', 'rust', 'toml', 'tsx',
  'typescript', 'vim', 'vimdoc', 'yaml',
}

-- `master`'s incremental_selection module has no equivalent on `main`, so this
-- is a compact reimplementation on top of core vim.treesitter that keeps the
-- old <c-space>/<c-s>/<M-space> bindings working.
local incremental = {}
do
  local stacks = {}

  local function buf_stack()
    local buf = vim.api.nvim_get_current_buf()
    stacks[buf] = stacks[buf] or {}
    return stacks[buf]
  end

  local function same_range(a, b)
    local a1, a2, a3, a4 = a:range()
    local b1, b2, b3, b4 = b:range()
    return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
  end

  local function select_node(node)
    local srow, scol, erow, ecol = node:range()
    -- A node ending at column 0 really ends at the end of the previous line.
    if ecol == 0 and erow > srow then
      erow = erow - 1
      ecol = #(vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or '')
    end
    vim.fn.setpos("'<", { 0, srow + 1, scol + 1, 0 })
    vim.fn.setpos("'>", { 0, erow + 1, math.max(ecol, 1), 0 })
    vim.cmd('normal! gv')
  end

  function incremental.init()
    local node = vim.treesitter.get_node()
    if not node then
      return
    end
    local stack = buf_stack()
    for i = #stack, 1, -1 do
      stack[i] = nil
    end
    stack[1] = node
    select_node(node)
  end

  -- Grow the selection to the next ancestor that actually covers more text.
  function incremental.node_incremental()
    local stack = buf_stack()
    local node = stack[#stack]
    if not node then
      return incremental.init()
    end
    local parent = node:parent()
    while parent and same_range(parent, node) do
      parent = parent:parent()
    end
    if not parent then
      return select_node(node)
    end
    stack[#stack + 1] = parent
    select_node(parent)
  end

  function incremental.node_decremental()
    local stack = buf_stack()
    if #stack > 1 then
      stack[#stack] = nil
    end
    local node = stack[#stack]
    if node then
      select_node(node)
    end
  end

  -- Grow to the nearest ancestor spanning more *lines* -- close enough to the
  -- old module's notion of a scope.
  function incremental.scope_incremental()
    local stack = buf_stack()
    local node = stack[#stack]
    if not node then
      return incremental.init()
    end
    local srow, _, erow, _ = node:range()
    local parent = node:parent()
    while parent do
      local psrow, _, perow, _ = parent:range()
      if psrow < srow or perow > erow then
        break
      end
      parent = parent:parent()
    end
    if not parent then
      return select_node(node)
    end
    stack[#stack + 1] = parent
    select_node(parent)
  end
end

local function select_map(query)
  return function()
    require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
  end
end

local function move_map(dir, query)
  return function()
    require('nvim-treesitter-textobjects.move')[dir](query, 'textobjects')
  end
end

local function swap_map(dir, query)
  return function()
    require('nvim-treesitter-textobjects.swap')[dir](query, 'textobjects')
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    -- Must be loaded before the first buffer so the FileType autocmd below is
    -- in place, and so the install_dir lands on the runtimepath early.
    lazy = false,
    priority = 500,
    config = function()
      local ts = require('nvim-treesitter')

      -- `main`'s setup accepts only `install_dir`. Passing it explicitly is
      -- what prepends it to the runtimepath, which is how locally managed
      -- parsers win over the out-of-sync system ones under /usr/lib.
      ts.setup {
        install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site'),
      }

      -- Replaces `ensure_installed`; no-ops for parsers already present.
      ts.install(ensure_installed)

      -- Replaces the `highlight` and `indent` modules.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('jmiv_treesitter', { clear = true }),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(event.match)
          if not lang then
            return
          end
          -- Filetypes whose parser isn't installed yet must not throw.
          if not pcall(vim.treesitter.start, event.buf, lang) then
            return
          end
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      vim.keymap.set('n', '<c-space>', incremental.init, { desc = 'Init selection' })
      vim.keymap.set('x', '<c-space>', incremental.node_incremental, { desc = 'Increment node' })
      vim.keymap.set('x', '<c-s>', incremental.scope_incremental, { desc = 'Increment scope' })
      vim.keymap.set('x', '<M-space>', incremental.node_decremental, { desc = 'Decrement node' })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    -- On `main` the setup table carries only behaviour flags -- keymaps are
    -- no longer declared there, so they are defined below by hand.
    opts = {
      select = { lookahead = true },
      move = { set_jumps = true },
    },
    keys = {
      { 'aa', select_map '@parameter.outer', mode = { 'x', 'o' }, desc = 'a parameter' },
      { 'ia', select_map '@parameter.inner', mode = { 'x', 'o' }, desc = 'inner parameter' },
      { 'af', select_map '@function.outer', mode = { 'x', 'o' }, desc = 'a function' },
      { 'if', select_map '@function.inner', mode = { 'x', 'o' }, desc = 'inner function' },
      { 'ac', select_map '@class.outer', mode = { 'x', 'o' }, desc = 'a class' },
      { 'ic', select_map '@class.inner', mode = { 'x', 'o' }, desc = 'inner class' },

      { ']m', move_map('goto_next_start', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next function start' },
      { ']]', move_map('goto_next_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next class start' },
      { ']M', move_map('goto_next_end', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next function end' },
      { '][', move_map('goto_next_end', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next class end' },
      { '[m', move_map('goto_previous_start', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Prev function start' },
      { '[[', move_map('goto_previous_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Prev class start' },
      { '[M', move_map('goto_previous_end', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Prev function end' },
      { '[]', move_map('goto_previous_end', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Prev class end' },

      { '<C-a>', swap_map('swap_next', '@parameter.inner'), mode = 'n', desc = 'Swap next parameter' },
      { '<C-A>', swap_map('swap_previous', '@parameter.inner'), mode = 'n', desc = 'Swap previous parameter' },
    },
  },
}
