-- Fuzzy Finder (files, lsp, etc)

-- Telescope live_grep scoped to the git root of the current buffer.
local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  local current_dir
  if current_file == '' then
    current_dir = cwd
  else
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  local git_root =
    vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep { search_dirs = { git_root } }
  end
end

-- Wrap a telescope.builtin picker so the plugin only loads when the key is hit.
local function builtin(name, opts)
  return function()
    require('telescope.builtin')[name](opts)
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    cmd = 'Telescope',
    config = function()
      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')
      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
    end,
    -- See `:help telescope.builtin`
    keys = {
      { '<leader>?', builtin 'oldfiles', desc = '[?] Find recently opened files' },
      { '<leader><space>', builtin 'buffers', desc = '[ ] Find existing buffers' },
      {
        '<leader>/',
        function()
          -- You can pass additional configuration to telescope to change theme, layout, etc.
          require('telescope.builtin').current_buffer_fuzzy_find(
            require('telescope.themes').get_dropdown { winblend = 10, previewer = false }
          )
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      {
        '<leader>s/',
        builtin('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }),
        desc = '[S]earch [/] in Open Files',
      },
      { '<leader>ss', builtin 'builtin', desc = '[S]earch [S]elect Telescope' },
      { '<leader>gf', builtin 'git_files', desc = 'Search [G]it [F]iles' },
      { '<leader>sf', builtin 'find_files', desc = '[S]earch [F]iles' },
      { '<leader>sh', builtin 'help_tags', desc = '[S]earch [H]elp' },
      { '<leader>sw', builtin 'grep_string', desc = '[S]earch current [W]ord' },
      { '<leader>sg', builtin 'live_grep', desc = '[S]earch by [G]rep' },
      { '<leader>sG', live_grep_git_root, desc = '[S]earch by [G]rep on Git Root' },
      { '<leader>sd', builtin 'diagnostics', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', builtin 'resume', desc = '[S]earch [R]esume' },
    },
  },
}
