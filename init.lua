-- ============================================================:
-- INIT.LUA
-- Stable Neovim 0.11+ config
-- Treesitter pinned to master branch (Telescope-compatible)
-- ============================================================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ============================================================
-- Core Options
-- ============================================================

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.signcolumn = 'yes'
vim.o.termguicolors = true
vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'

vim.o.confirm = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.timeoutlen = 400

vim.o.completeopt = 'menu,menuone,noselect'

vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-- ============================================================
-- Diagnostics
-- ============================================================

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
})

-- ============================================================
-- Keymaps
-- ============================================================

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit Terminal Mode' })

-- Window navigation.
-- NOTE: Alt keys may be intercepted by your terminal (GNOME Terminal).
-- If they do not work, enable "Alt sends Escape" or use Kitty/WezTerm.
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')

vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = 'Window Left' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = 'Window Down' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = 'Window Up' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = 'Window Right' })

-- Fallback window navigation (always works in any terminal)
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Window Left' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Window Down' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Window Up' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Window Right' })

vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Previous Diagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next Diagnostic' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
  desc = 'Show Diagnostic Float',
})

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = 'Diagnostics to Location List',
})

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', {
  desc = 'Clear Search Highlight',
})

-- ============================================================
-- Autocommands
-- ============================================================

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  callback = function()
    if vim.hl and vim.hl.on_yank then
      vim.hl.on_yank()
    elseif vim.highlight and vim.highlight.on_yank then
      vim.highlight.on_yank()
    end
  end,
})

-- ============================================================
-- User Commands
-- ============================================================

vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.')
  local filename = vim.api.nvim_buf_get_name(0)

  if filename == '' then
    vim.notify('No file associated with current buffer', vim.log.levels.WARN)
    return
  end

  local out = vim.fn.system({
    'git',
    'blame',
    '-L',
    line_number .. ',+1',
    filename,
  })
  vim.notify(out)
end, { desc = 'Print git blame for current line' })

-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Plugins
-- ============================================================

require('lazy').setup({

  -- Theme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('tokyonight-storm')
    end,
  },

  -- File icons (requires a Nerd Font in your terminal)
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = { default = true },
  },

  -- ----------------------------------------------------------
  -- Telescope
  -- file_ignore_patterns excludes binaries and noise.
  -- Requires: ripgrep (and optionally fd) installed.
  -- ----------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = 'Find Files' },
      { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = 'Live Grep' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>', desc = 'Buffers' },
      { '<leader>fr', '<cmd>Telescope oldfiles<CR>', desc = 'Recent Files' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>', desc = 'Help Tags' },
      { '<leader>fd', '<cmd>Telescope diagnostics<CR>', desc = 'Diagnostics' },
    },
    config = function()
      require('telescope').setup({
        defaults = {
          sorting_strategy = 'ascending',
          layout_config = { prompt_position = 'top' },

          -- Exclude binaries, VCS dirs, and noise from results.
          file_ignore_patterns = {
            '%.git/',
            'node_modules/',
            '%.o$',
            '%.a$',
            '%.so$',
            '%.out$',
            '%.class$',
            '%.pyc$',
            '%.jpg$',
            '%.jpeg$',
            '%.png$',
            '%.gif$',
            '%.pdf$',
            '%.zip$',
            '%.tar$',
            '%.gz$',
            '%.ico$',
            '%.bin$',
            '%.exe$',
            '%.dll$',
          },
        },
        pickers = {
          find_files = {
            -- Respect .gitignore, show hidden, skip .git dir.
            hidden = true,
            no_ignore = false,
          },
        },
      })
    end,
  },

  -- ----------------------------------------------------------
  -- Treesitter
  -- PINNED to master branch: compatible with Telescope 0.1.x.
  -- Fixes the ft_to_lang previewer crash and C highlighting.
  -- Requires gcc to compile parsers (sudo dnf install gcc).
  -- ----------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if not ok then
        vim.notify(
          'nvim-treesitter unavailable. Run :Lazy sync and restart.',
          vim.log.levels.WARN
        )
        return
      end

      configs.setup({
        ensure_installed = {
          'bash',
          'c',
          'cpp',
           -- 'go',
          'json',
          'lua',
          'markdown',
          'markdown_inline',
          'python',
          'query',
          'sql',
          'toml',
          'vim',
          'vimdoc',
          'yaml',
        },
        auto_install = true,
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('n', ']h', function()
          gs.nav_hunk('next')
        end, 'Next Git Hunk')

        map('n', '[h', function()
          gs.nav_hunk('prev')
        end, 'Previous Git Hunk')

        map('n', '<leader>hs', gs.stage_hunk, 'Stage Git Hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset Git Hunk')
        map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo Stage Hunk')
        map('n', '<leader>hp', gs.preview_hunk, 'Preview Git Hunk')
        map('n', '<leader>hb', gs.blame_line, 'Blame Current Line')
      end,
    },
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        }),
      })
    end,
  },

  -- ----------------------------------------------------------
  -- Mason + native LSP (Neovim 0.11+)
  -- Capabilities applied per-server (no '*' wildcard).
  -- ----------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()

      local servers = {
        'pyright',
        -- 'gopls',
        'clangd',
        'lua_ls',
        'bashls',
        'yamlls',
        'jsonls',
      }

      require('mason-lspconfig').setup({
        ensure_installed = servers,
        automatic_enable = false,
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
          end

          -- These ONLY work after a server attaches. Check :LspInfo.
          map('gd', vim.lsp.buf.definition, 'Go to Definition')
          map('gD', vim.lsp.buf.declaration, 'Go to Declaration')
          map('gr', vim.lsp.buf.references, 'References')
          map('gi', vim.lsp.buf.implementation, 'Implementation')
          map('K', vim.lsp.buf.hover, 'Hover Docs')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename Symbol')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type Definition')
        end,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Per-server config (explicit, no unsupported wildcard).
      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            telemetry = { enable = false },
          },
        },
      })

      for _, server in ipairs(servers) do
        if server ~= 'lua_ls' then
          vim.lsp.config(server, { capabilities = capabilities })
        end
        vim.lsp.enable(server)
      end
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true, lsp_format = 'fallback' })
        end,
        mode = { 'n', 'v' },
        desc = 'Format File/Selection',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'black' },
        go = { 'goimports' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        yaml = { 'yamlfmt' },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = 'fallback',
      },
    },
  },

  -- Mini.nvim utilities
  {
    'echasnovski/mini.nvim',
    version = '*',
    config = function()
      require('mini.pairs').setup()
      require('mini.comment').setup()
      require('mini.surround').setup()
      require('mini.files').setup()

      vim.keymap.set('n', '<leader>o', function()
        local path = vim.api.nvim_buf_get_name(0)
        if path == '' then
          path = vim.uv.cwd()
        end
        require('mini.files').open(path, false)
      end, { desc = 'Open File Explorer' })
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'tokyonight',
        icons_enabled = true,
        section_separators = '',
        component_separators = '',
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
            symbols = {
              modified = ' ●',
              readonly = ' ',
              unnamed = '[No Name]',
              newfile = '[New]',
            },
          },
        },
        lualine_x = {
          'encoding',
          'fileformat',
          'filetype',
          {
            function()
              local errors = #vim.diagnostic.get(0, {
                severity = vim.diagnostic.severity.ERROR,
              })
              local warnings = #vim.diagnostic.get(0, {
                severity = vim.diagnostic.severity.WARN,
              })
              local result = ''
              if errors > 0 then
                result = result .. ' E:' .. errors
              end
              if warnings > 0 then
                result = result .. ' W:' .. warnings
              end
              return result
            end,
            color = { fg = '#ff6c6b' },
          },
        },
      },
    },
  },
}, {
  install = { colorscheme = { 'tokyonight' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        'netrwPlugin',
      },
    },
  },
})
