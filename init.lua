vim = vim or {}

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if not ok then return end

-- Plugins
lazy.setup({
    spec = {
        -- File explorer
        { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
        -- Status l
        { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
        -- Telescope
        { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
        -- Treesitter
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
        -- Git signs
        { "lewis6991/gitsigns.nvim" },
        -- LSP
        { "neovim/nvim-lspconfig" },
        { "williamboman/mason.nvim" },
        { "williamboman/mason-lspconfig.nvim" },
        -- Autocomplete
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-cmdline" },
        -- Snippets
        { "L3MON4D3/LuaSnip" },
        { "saadparwaiz1/cmp_luasnip" },
        -- Coding experience plugins
        { "windwp/nvim-autopairs" },
        { "numToStr/Comment.nvim" },
        -- { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
        { "folke/which-key.nvim" },
        { "lukas-reineke/indent-blankline.nvim", event = "BufReadPost", main = "ibl", opts = {} },
        { "echasnovski/mini.icons", version = false },
        -- Themes
--      { "xiyaowong/transparent.nvim" },
        { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
        -- Copilot
        --[[{ "zbirenbaum/copilot.lua",
            cmd = { "Copilot", "CopilotChat" },
            lazy = true,
            opts = {
                suggestion = { enabled = false },
                panel = { enabled = false },
            },
        },
        { "zbirenbaum/copilot-cmp",
            dependencies = { "zbirenbaum/copilot.lua" },
            config = function()
                require("copilot_cmp").setup()
            end,
        },]]
    },
})

-- nvim-tree setup
require("nvim-tree").setup({
    view = { width = 35, side = "left" },
    renderer = { icons = { show = { file = true, folder = true, folder_arrow = true, git = true } } },
    filters = { dotfiles = false },
    git = { ignore = false },
})
vim.keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>t", ":NvimTreeFocus<CR>", { silent = true, noremap = true })

-- Auto open tree on startup
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    callback = function()
        require("nvim-tree.api").tree.open()
    end,
})

-- Lualine setup
require("lualine").setup({ options = { theme = "auto" } })

-- Treesitter setup
require("nvim-treesitter.configs").setup({
    -- 🌳 Automatically install these parsers
    ensure_installed = {
        "lua", "python", "javascript",
        "c", "cpp", "go",
        "html", "css", "bash"
    },

    auto_install = true,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
        -- disable = { "python" },  -- optional: python indentation is buggy in Treesitter
    },
})

-- Git signs setup
require("gitsigns").setup()

-- Telescope setup
require("telescope").setup({})

vim.keymap.set("n","<leader>ff","<cmd>Telescope find_files<cr>")
vim.keymap.set("n","<leader>fg","<cmd>Telescope live_grep<cr>")
vim.keymap.set("n","<leader>fb","<cmd>Telescope buffers<cr>")
vim.keymap.set("n","<leader>fh","<cmd>Telescope help_tags<cr>")

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

Show = true

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>ee", "<cmd>Telescope diagnostics<CR>", { silent = true, noremap = true, desc = "Show LSP diagnostics" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set("n", "<leader>dd", function()
    Show = not Show
    vim.diagnostic.config({
        virtual_text = Show,
        signs = Show,
        underline = Show,
        severity_sort = Show,
    })
    print("Inline diagnostics: " .. (Show and "ON" or "OFF"))
end, { desc = "Toggle inline diagnostics (virtual text)" })


-- LSP + mason setup

local mason = require("mason")
local mason_lsp = require("mason-lspconfig")
mason.setup()
mason_lsp.setup({
    ensure_installed = {
        "pyright", "clangd", "jdtls", "gopls", "rust_analyzer",
        "lua_ls", "html", "cssls", "phpactor", "bashls",
    },
    handlers = {
        function(server_name)
            local active_servers = { "pyright", "lua_ls", "clangd" }
            if vim.tbl_contains(active_servers, server_name) then
                require("lspconfig")[server_name].setup({})
            end
        end,
    },
})

local opts = { noremap=true, silent=true }
vim.keymap.set("n","gi","<cmd>lua vim.lsp.buf.implementation()<CR>",opts)
vim.keymap.set("n","<leader>rn","<cmd>lua vim.lsp.buf.rename()<CR>",opts)
vim.keymap.set("n","<leader>ca","<cmd>lua vim.lsp.buf.code_action()<CR>",opts)
vim.keymap.set("n","gr","<cmd>lua vim.lsp.buf.references()<CR>",opts)

-- nvim-cmp setup

local cmp = require("cmp")

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
--        { name = "copilot", group_index = 2 },
        { name = "nvim_lsp", group_index = 2 },
        { name = "luasnip", group_index = 2 },
    }, {
            { name = "buffer" },
        }),
    sorting = {
        priority_weight = 2,
        comparators = {
--            require("copilot_cmp.comparators").prioritize,
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})


-- Simple Copilot toggle with on/off status
--[[vim.keymap.set("n", "<leader>co", function()
    local copilot_enabled = vim.g.copilot_enabled

    if copilot_enabled == 1 then
        vim.cmd("Copilot disable")
        vim.g.copilot_enabled = 0
        print("Copilot: OFF")
    else
        vim.cmd("Copilot enable")
        vim.g.copilot_enabled = 1
        print("Copilot: ON")
    end
end, { noremap = true, silent = true, desc = "Toggle Copilot" })

local chat_opts = { silent = true, noremap = true }
vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", chat_opts, { desc = "Open Copilot Chat" })
vim.keymap.set("v", "<leader>cc", ":<C-u>CopilotChat<CR>", chat_opts, { desc = "Chat with selected code" })
vim.keymap.set("n", "<leader>ce", ":CopilotChatExplain<CR>", chat_opts, { desc = "Explain current selection" })
]]

-- Terminal & Window Setup

vim.opt.shell = [["C:\\Program Files\\PowerShell\\7\\pwsh.exe"]]
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

vim.keymap.set("n", "<leader>tb", ":belowright split | terminal<CR>", { silent = true, noremap = true, desc = "Open bottom terminal" })
vim.keymap.set("n", "<leader>tr", ":rightbelow vsplit | terminal<CR>", { silent = true, noremap = true, desc = "Open right terminal" })
vim.keymap.set("n", "<leader>tl", ":leftabove vsplit | terminal<CR>", { silent = true, noremap = true, desc = "Open terminal on the left" })
vim.keymap.set("n", "<leader>ta", ":topleft split | terminal<CR>", { silent = true, noremap = true, desc = "Open terminal above" })

vim.keymap.set("n", "<leader>tw", "<C-w>r", { silent = true, noremap = true, desc = "Swap window with next" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, noremap = true })

-- Move between windows using arrow keys
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Move to window above" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Move to window below" })
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Move to window left" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Move to window right" })
vim.keymap.set("n", "<leader>C", "<C-w>c", { desc = "Close current window" })
vim.keymap.set("n", "<leader>O", "<C-w>o", { desc = "Close all other windows" })

-- Resize windows using arrow keys and Ctrl
vim.keymap.set({"n", "t"}, "<A-Up>", "<C-\\><C-n><cmd>resize +2<CR>", { silent = true })
vim.keymap.set({"n", "t"}, "<A-Down>", "<C-\\><C-n><cmd>resize -2<CR>", { silent = true })
vim.keymap.set({"n", "t"}, "<A-Left>", "<C-\\><C-n><cmd>vertical resize -2<CR>", { silent = true })
vim.keymap.set({"n", "t"}, "<A-Right>", "<C-\\><C-n><cmd>vertical resize +2<CR>", { silent = true })


require("gruvbox").setup({
    terminal_colors = true,
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    inverse = true,
    contrast = "",
    palette_overrides = {},
    overrides = {},
    dim_inactive = false,
    transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")

-- vim.keymap.set('n', '<leader>oft', ':TransparentToggle<CR>', { noremap = true, silent = true })

-- 🧠 Coding Experience Plugins Setup

-- Autopairs
require("nvim-autopairs").setup({
    check_ts = true, -- integrate with Treesitter
})

-- Commenting
require("Comment").setup()

-- Todo comments
--[[require("todo-comments").setup({
    signs = true,
    keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    },
})
]]

-- Which-key
require("which-key").setup({
    plugins = { spelling = true },
    win = { border = "rounded" },
    layout = { align = "center" },
})

-- Indent guides
require("ibl").setup({
    indent = { char = "│" },
    scope = { enabled = true },
})

-- Comment current line or selection
vim.keymap.set("n", "<leader>/", function() require("Comment.api").toggle.linewise.current() end, { desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Toggle comment (visual)" })

-- Search TODOs
vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<CR>", { desc = "Search TODOs" })

-- Which-key manual popup
vim.keymap.set("n", "<leader>?", "<cmd>WhichKey<CR>", { desc = "Show keymaps" })

-- Tab settings
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.softtabstop = 4

vim.cmd("filetype plugin indent on")

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Save with Ctrl+S
vim.keymap.set("n", "<A-s>", "<cmd>w<CR>")
vim.keymap.set("i", "<A-s>", "<Esc>:w<CR>a", { noremap = true, silent = true })

-- Quit all and terminate terminals
vim.keymap.set("n", "<C-q>", function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            local job = vim.b[buf].terminal_job_id
            if job then vim.fn.jobstop(job) end
        end
    end
    vim.cmd("qa")
end, { desc = "Quit all (terminate terminals)" })

-- Copy to system clipboard
vim.keymap.set("v", "<A-y>", '"+y', { desc = "Copy to system clipboard" })

-- Toggle text wrapping
vim.keymap.set("n", "<A-w>", function()
  vim.o.wrap = not vim.o.wrap
  print("Toggled text wrapping")
end, { desc = "Toggle wrap" })
