-- [[ LSP Configuration & Plugins ]]

-- Add/remove language servers here. They are installed automatically via
-- mason. The value of each entry is passed to the `settings` field of the
-- server config; add a `filetypes` key to override the default filetypes.
local servers = {
  clangd = {},
  pyright = {},
  rust_analyzer = {},
  cmake = {},
  jsonls = {},
  bashls = {},
  csharp_ls = {},
  zls = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Keymaps are registered via LspAttach so they only apply to buffers with
-- an active language server. This replaces the old on_attach callback which
-- is not supported by the vim.lsp.config API.
local function on_attach(event)
  local bufnr = event.buf

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', function()
    require('telescope.builtin').lsp_references()
  end, '[G]oto [R]eferences')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', function()
    require('telescope.builtin').lsp_document_symbols()
  end, '[D]ocument [S]ymbols')
  nmap('<leader>ws', function()
    require('telescope.builtin').lsp_dynamic_workspace_symbols()
  end, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',

    -- LSP progress + notification UI. `version = '*'` tracks the latest
    -- release tag rather than `main`, which takes occasional breaking changes.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', version = '*', opts = {} },

    -- Additional lua configuration, makes nvim stuff amazing!
    'folke/neodev.nvim',

    -- Supplies the extra completion capabilities broadcast to each server
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('jmiv_lsp_attach', { clear = true }),
      callback = on_attach,
    })

    -- Setup neovim lua configuration
    require('neodev').setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- Ensure the servers above are installed
    require('mason-lspconfig').setup {
      ensure_installed = vim.tbl_keys(servers),
    }

    -- Configure each server using the Neovim 0.11+ native vim.lsp.config API,
    -- which replaces the deprecated require('lspconfig')[name].setup() pattern.
    for server_name, settings in pairs(servers) do
      vim.lsp.config(server_name, {
        capabilities = capabilities,
        settings = settings,
        filetypes = settings.filetypes,
      })
    end

    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}
