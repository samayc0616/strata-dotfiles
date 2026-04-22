--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- SystemVerilog/Verilog file type detection
vim.filetype.add({
  extension = {
    sv = 'systemverilog',
    svh = 'systemverilog',
    svp = 'systemverilog', -- IEEE 1735 protected SV (VCS)
    v = 'verilog',
    vh = 'verilog',
  },
})


-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Set log level (use 'debug' for troubleshooting, 'info' for normal use)
-- vim.lsp.set_log_level('debug')

-- Suppress position_encoding warning in Neovim 0.11
-- This warning comes from plugins not yet updated for 0.11
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg:find("position_encoding") then
    return
  end
  notify(msg, level, opts)
end

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable OSC52 clipboard using nvim's built-in support
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Fix Home and End keys for kitty/tmux
-- Home sends ^[[1~ and End sends ^[[4~
-- Nvim maps these to <Find> and <Select> by default, so remap them
vim.keymap.set({'n', 'v', 'i', 'c'}, '<Find>', '<Home>', { noremap = true })
vim.keymap.set({'n', 'v', 'i', 'c'}, '<Select>', '<End>', { noremap = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Neutralize native `gr{char}` (replace-char-at-cursor). Without this, typing
-- `grr` / `gra` / `grA` etc. in buffers where LSP hasn't attached falls through
-- to vim's native `gr` command and silently replaces the cursor char.
-- Buffer-local LSP mappings (see LspAttach) still shadow this where LSP is attached.
vim.keymap.set({'n', 'x'}, 'gr', '<Nop>', { desc = 'disabled (native replace-char)' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'powerman/vim-plugin-AnsiEsc', -- :AnsiEsc to render ANSI color codes (patched for monokai-pro)

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- Alternatively, use `config = function() ... end` for full control over the configuration.
  -- If you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- Your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  -- Configure verible for Verilog/SystemVerilog with improved definition finding
  -- Configure verible for Verilog/SystemVerilog with improved definition finding
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  'andymass/vim-matchup',
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>ut', '<cmd>UndotreeToggle<CR>', desc = 'Toggle Undotree' },
    },
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      -- Optional: Add any specific configuration for undotree here
      -- For example:
      -- vim.g.undotree_SetFocusWhenToggle = 1
      -- vim.g.undotree_WindowLayout = 2
    end,
  },
  {
    'ojroques/nvim-osc52',
    config = function()
      require('osc52').setup {
        max_length = 0,
        silent = true,
        trim = false,
        tmux_passthrough = true,
      }

      -- Auto-copy on yank
      vim.api.nvim_create_autocmd('TextYankPost', {
        callback = function()
          if vim.v.event.operator == 'y' then
            require('osc52').copy_register('"')
          end
        end,
      })

      -- Manual copy keybindings
      vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, { expr = true })
      vim.keymap.set('n', '<leader>cc', '<leader>c_', { remap = true })
      vim.keymap.set('x', '<leader>c', require('osc52').copy_visual)
    end,
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Show hover information (documentation) for the symbol under cursor
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          -- Bound as `grr` (not `gr`) to match Nvim 0.11+ defaults (`grr`/`gra`/`grn`/`gri`/`grt`)
          -- and avoid the timeout-ambiguity that was leaking stray keystrokes into telescope.
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Fallback: Search for word under cursor in current buffer (useful for local variables)
          -- This works when LSP doesn't provide references
          map('<leader>sw', function()
            require('telescope.builtin').current_buffer_fuzzy_find({
              default_text = vim.fn.expand('<cword>')
            })
          end, '[S]earch [W]ord in buffer')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      -- Set default position encoding
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { 'utf-16', 'utf-8' }

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {

        -- Python
        pyright = {},
        ruff = {}, -- fast linter / quick-fixes; pyright handles hover/types

        -- JavaScript/TypeScript
        ts_ls = {},

        -- C/C++
        clangd = {},

        -- Rust
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
            },
          },
        },

        -- Bash
        bashls = {},

        -- JSON
        jsonls = {},

        -- YAML
        yamlls = {},

        -- HTML/CSS
        html = {},
        cssls = {},

        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      -- Get all server names except verible (which we configure manually)
      local ensure_installed = {}
      for server_name, config in pairs(servers or {}) do
        if config ~= false then
          table.insert(ensure_installed, server_name)
        end
      end
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'verible', -- Verilog/SystemVerilog language server
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      local lspconfig = require('lspconfig')

      -- Setup mason-lspconfig for all servers
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

            -- Use lspconfig to setup the server
            lspconfig[server_name].setup(server)
          end,
        },
      }

      -- slang-server (Hudson River Trading) — SystemVerilog LSP based on Slang.
      -- Binary installed manually at ~/.local/bin/slang-server.
      -- Config lives in <workspace>/.slang/server.json; see that file for filelist/defines.
      -- Attached to .sv/.svh only (NOT .svp, which is IEEE 1735 encrypted and unparseable).
      local slang_cmd = vim.fn.expand('~/.local/bin/slang-server')
      if vim.fn.executable(slang_cmd) == 1 then
        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'systemverilog',
          callback = function(args)
            local fname = vim.api.nvim_buf_get_name(args.buf)
            if fname:match('%.svp$') then return end
            local root = vim.fs.dirname(vim.fs.find({ '.slang', '.git' }, { upward = true, path = fname })[1] or fname)
            vim.lsp.start({
              name = 'slang-server',
              cmd = { slang_cmd },
              root_dir = root,
              capabilities = capabilities,
              handlers = {
                -- Suppress Info-level chatter ("Using build file: ...", etc.) that
                -- otherwise triggers "Press ENTER to continue". Errors/warnings still show.
                ['window/showMessage'] = function(_, result, ctx)
                  if result.type >= vim.lsp.protocol.MessageType.Info then return end
                  return vim.lsp.handlers['window/showMessage'](_, result, ctx)
                end,
              },
            })
          end,
        })
      end

    end,
  },

  { -- slang-server neovim UI (hierarchy browser, waveform viewer, build switcher)
    'hudson-trading/slang-server.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    ft = 'systemverilog',
    opts = {},
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = false,
      formatters_by_ft = {
        lua = { 'stylua' },
        verilog = { 'verible_verilog_format' },
        systemverilog = { 'verible_verilog_format' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
      formatters = {
        verible_verilog_format = {
          command = 'verible-verilog-format',
          args = { '-' },
          stdin = true,
        },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          -- Covers 150+ SystemVerilog snippets (incl. full UVM phases/ports/macros) and Python.
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      -- Add SystemVerilog/Verilog snippets
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node

      ls.add_snippets("systemverilog", {
        s("module", {
          t("module "), i(1, "module_name"), t("("), i(2, ""), t({");", ""}),
          t({"  ", ""}),
          i(0),
          t({"", "endmodule"}),
        }),
        s("always_ff", {
          t("always_ff @(posedge "), i(1, "clk"), t({") begin", ""}),
          t({"  ", ""}), i(0),
          t({"", "end"}),
        }),
        s("always_comb", {
          t({"always_comb begin", ""}),
          t({"  ", ""}), i(0),
          t({"", "end"}),
        }),
        s("if", {
          t("if ("), i(1, "condition"), t({") begin", ""}),
          t({"  ", ""}), i(0),
          t({"", "end"}),
        }),
        s("case", {
          t("case ("), i(1, "expr"), t({")", ""}),
          t({"  ", ""}), i(2, "value"), t(": "), i(3, "statement"), t({";", ""}),
          t({"  default: ", ""}), i(0),
          t({"", "endcase"}),
        }),
        s("typedef", {
          t("typedef "), i(1, "logic"), t(" ["), i(2, "width-1"), t(":0] "), i(3, "type_name"), t(";"),
        }),
        s("logic", {
          t("logic ["), i(1, "width-1"), t(":0] "), i(2, "signal_name"), t(";"),
        }),
        s("struct", {
          t({"typedef struct packed {", ""}),
          t({"  ", ""}), i(0),
          t({"", "} "}), i(1, "struct_name"), t(";"),
        }),
      })

      -- Add Verilog snippets (mostly same as SystemVerilog but with reg instead of logic)
      ls.add_snippets("verilog", {
        s("module", {
          t("module "), i(1, "module_name"), t("("), i(2, ""), t({");", ""}),
          t({"  ", ""}),
          i(0),
          t({"", "endmodule"}),
        }),
        s("always", {
          t("always @(posedge "), i(1, "clk"), t({") begin", ""}),
          t({"  ", ""}), i(0),
          t({"", "end"}),
        }),
        s("if", {
          t("if ("), i(1, "condition"), t({") begin", ""}),
          t({"  ", ""}), i(0),
          t({"", "end"}),
        }),
        s("case", {
          t("case ("), i(1, "expr"), t({")", ""}),
          t({"  ", ""}), i(2, "value"), t(": "), i(3, "statement"), t({";", ""}),
          t({"  default: ", ""}), i(0),
          t({"", "endcase"}),
        }),
      })

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer', keyword_length = 2 },  -- Add buffer completion for local variables
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }

      -- Enhanced buffer completion for SystemVerilog/Verilog
      -- This provides completion for local variables, signals, etc.
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'verilog', 'systemverilog' },
        callback = function()
          cmp.setup.buffer {
            sources = {
              { name = 'nvim_lsp', priority = 1000 },
              { name = 'buffer', priority = 900, keyword_length = 2,
                option = {
                  -- Get completions from all visible buffers
                  get_bufnrs = function()
                    local bufs = {}
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                      bufs[vim.api.nvim_win_get_buf(win)] = true
                    end
                    return vim.tbl_keys(bufs)
                  end,
                },
              },
              { name = 'luasnip', priority = 800 },
              { name = 'path', priority = 700 },
              { name = 'nvim_lsp_signature_help', priority = 600 },
            },
          }
        end,
      })
    end,
  },

  { -- Linting with nvim-lint
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require('lint')

      -- Configure linters by filetype
      lint.linters_by_ft = {
        systemverilog = { 'verilator' },
        verilog = { 'verilator' },
      }

      -- Customize verilator linter to look for verilator.f
      local verilator = lint.linters.verilator
      verilator.args = function()
        local args = {
          '--lint-only',
          '-Wall',
        }

        -- Look for verilator.f file in project root
        local verilator_f = vim.fs.find('verilator.f', {
          upward = true,
          type = 'file',
          path = vim.fn.expand('%:p:h'),
        })[1]

        if verilator_f then
          table.insert(args, '-f')
          table.insert(args, verilator_f)
        end

        return args
      end

      -- Create autocommand to trigger linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only lint if verilator is available
          if vim.fn.executable('verilator') == 1 then
            lint.try_lint()
          end
        end,
      })

      -- Add keymap to manually trigger linting
      vim.keymap.set('n', '<leader>l', function()
        lint.try_lint()
      end, { desc = '[L]int current file' })
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'loctvl842/monokai-pro.nvim',
    -- priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('monokai-pro').setup {
        -- styles = {
        --   comments = { italic = false }, -- Disable italics in comments
        -- },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'monokai-pro'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
  },
  {
    'sindrets/diffview.nvim',
    cmd = 'DiffviewOpen',
    config = function()
      require('diffview').setup()
    end,
  },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- telescope 0.1.x needs the classic API; main branch dropped it
    lazy = false,
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = {
        'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
        'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
        -- Note: nvim-treesitter master ships only `verilog`; `systemverilog` filetype
        -- is auto-aliased to that parser internally (see parsers.lua: ft_to_lang map).
        'verilog', 'python',
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- Treesitter's SV highlights can conflict with the legacy regex highlights on some files;
        -- add 'systemverilog' here if you want both (e.g. for macros the parser misses).
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    },
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
-- Window resizing with Shift+Arrows
vim.keymap.set('n', '<M--Left>', ':vertical resize -3<CR>', { silent = true })
vim.keymap.set('n', '<M-Down>', ':resize +3<CR>', { silent = true })
vim.keymap.set('n', '<M-Up>', ':resize -3<CR>', { silent = true })
vim.keymap.set('n', '<M-Right>', ':vertical resize +3<CR>', { silent = true })

-- Always use spaces, never tabs
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- SystemVerilog-specific enhancements for finding references
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'verilog', 'systemverilog' },
  callback = function()
    -- Enhanced search for current word in project (useful when LSP doesn't provide references)
    vim.keymap.set('n', '<leader>sr', function()
      require('telescope.builtin').grep_string({
        search = vim.fn.expand('<cword>'),
        additional_args = function() return { '--hidden' } end,
      })
    end, { buffer = true, desc = '[S]earch word under cursor in project [R]eferences' })

    -- Search for current word in current buffer only
    vim.keymap.set('n', '<leader>sb', function()
      local word = vim.fn.expand('<cword>')
      vim.fn.setreg('/', '\\<' .. word .. '\\>')
      vim.cmd('set hlsearch')
      -- Jump to next occurrence
      vim.cmd('normal! n')
    end, { buffer = true, desc = '[S]earch word in [B]uffer and highlight' })
  end,
})

-- Command to generate verible.filelist for the current project
vim.api.nvim_create_user_command('VeribleGenerateFilelist', function(opts)
  local root_dir = vim.fs.root(0, { '.git', 'verible.filelist' }) or vim.fn.getcwd()
  local output_path = opts.args ~= '' and opts.args or root_dir .. '/verible.filelist'

  -- Find all SystemVerilog and Verilog files
  local find_cmd = string.format(
    'cd %s && find . -name "*.sv" -o -name "*.svh" -o -name "*.v" -o -name "*.vh" | sort > %s',
    vim.fn.shellescape(root_dir),
    vim.fn.shellescape(output_path)
  )

  local result = vim.fn.system(find_cmd)
  if vim.v.shell_error == 0 then
    print('Generated verible.filelist at: ' .. output_path)
    print('Restart LSP with :LspRestart to use the new filelist')
  else
    print('Error generating filelist: ' .. result)
  end
end, { nargs = '?', desc = 'Generate verible.filelist for the project' })

-- Command to show verible LSP status and configuration
vim.api.nvim_create_user_command('VeribleStatus', function()
  local fname = vim.api.nvim_buf_get_name(0)
  print("Current file: " .. fname)

  -- Find root directory
  local root = vim.fs.root(0, { 'verible.filelist', '.git' })
  if root then
    print("Project root: " .. root)
  else
    print("No project root found")
  end

  -- Check for verible.filelist
  local filelist = vim.fs.find('verible.filelist', {
    upward = true,
    type = 'file',
    path = vim.fn.expand('%:p:h'),
  })[1]

  if filelist then
    print("Found verible.filelist: " .. filelist)
    -- Count files in filelist
    local count = vim.fn.system('wc -l < ' .. vim.fn.shellescape(filelist))
    print("Files in project: " .. vim.trim(count))
  else
    print("WARNING: No verible.filelist found!")
    print("Run :VeribleGenerateFilelist to create one")
  end

  -- Check LSP status
  local clients = vim.lsp.get_clients({ bufnr = 0, name = 'verible' })
  if #clients > 0 then
    print("✓ Verible LSP is attached")
    for _, client in ipairs(clients) do
      print("  Client ID: " .. client.id)
      print("  Client name: " .. client.name)
      if client.config and client.config.cmd then
        print("  Command: " .. table.concat(client.config.cmd, ' '))
      end
      -- Check capabilities
      if client.server_capabilities then
        print("  Capabilities:")
        print("    Hover: " .. tostring(client.server_capabilities.hoverProvider or false))
        print("    References: " .. tostring(client.server_capabilities.referencesProvider or false))
        print("    Definition: " .. tostring(client.server_capabilities.definitionProvider or false))
      end
    end
  else
    print("✗ Verible LSP is NOT attached")
    -- Show all attached clients
    local all_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #all_clients > 0 then
      print("  Other LSP clients attached:")
      for _, client in ipairs(all_clients) do
        print("    - " .. client.name)
      end
    else
      print("  No LSP clients attached to this buffer")
    end
  end
end, { desc = 'Show verible LSP status and configuration' })
