return {
  -- ========================================================================== --
  --  إعدادات الـ LSP وخوادم اللغات (يدعم NestJS بالكامل)                       --
  -- ========================================================================== --
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- أداة Mason لإدارة وتثبيت الخوادم تلقائياً
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      
      -- إشعارات بصرية خفيفة لحالة الـ LSP
      { "j-hui/fidget.nvim", opts = {} },
      
      -- تحسين بيئة العمل الخاصة بملفات الـ Lua لـ Neovim
      { "folke/neodev.nvim", opts = {} },

      -- تأمين تحميل إضافة التكميل التلقائي قبل الـ LSP لمنع خطأ الـ module not found
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- إعدادات النوافذ المنبثقة والرموز
      vim.lsp.config('*', {
          root_markers = { '.git' },
      })

      vim.diagnostic.config({
          virtual_text  = true,
          severity_sort = true,
          float         = {
              style  = 'minimal',
              border = 'rounded',
              source = 'if_many',
              header = '',
              prefix = '',
          },
          signs         = {
              text = {
                  [vim.diagnostic.severity.ERROR] = '✘',
                  [vim.diagnostic.severity.WARN]  = '▲',
                  [vim.diagnostic.severity.HINT]  = '⚑',
                  [vim.diagnostic.severity.INFO]  = '»',
              },
          },
      })

      local orig = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
          opts            = opts or {}
          opts.border     = opts.border or 'rounded'
          opts.max_width  = opts.max_width or 80
          opts.max_height = opts.max_height or 24
          opts.wrap       = opts.wrap ~= false
          return orig(contents, syntax, opts, ...)
      end

      -- دالة الاختصارات والأتمتة عند تشغيل خادم اللغة
      vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('my.lsp', {}),
          callback = function(args)
              local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
              local buf    = args.buf
              local map    = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf }) end

              map('n', 'K', vim.lsp.buf.hover)
              map('n', 'gd', vim.lsp.buf.definition)
              map('n', 'gD', vim.lsp.buf.declaration)
              map('n', 'gi', vim.lsp.buf.implementation)
              map('n', 'go', vim.lsp.buf.type_definition)
              map('n', 'gr', vim.lsp.buf.references)
              map('n', 'gs', vim.lsp.buf.signature_help)
              map('n', 'gl', vim.diagnostic.open_float)
              map('n', '<F2>', vim.lsp.buf.rename)
              map({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end)
              map('n', '<F4>', vim.lsp.buf.code_action)

              if client:supports_method('textDocument/documentHighlight') then
                  local highlight_augroup = vim.api.nvim_create_augroup('my.lsp.highlight', { clear = false })
                  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                      buffer = buf,
                      group = highlight_augroup,
                      callback = vim.lsp.buf.document_highlight,
                  })
                  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                      buffer = buf,
                      group = highlight_augroup,
                      callback = vim.lsp.buf.clear_references,
                  })
              end

              local excluded_filetypes = { php = true, c = true, cpp = true }
              if not client:supports_method('textDocument/willSaveWaitUntil')
                  and client:supports_method('textDocument/formatting')
                  and not excluded_filetypes[vim.bo[buf].filetype]
              then
                  vim.api.nvim_create_autocmd('BufWritePre', {
                      group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
                      buffer = buf,
                      callback = function()
                          vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 1000 })
                      end
                  })
              end
          end,
      })

      -- تعريف الـ caps هنا داخل دالة الـ config لضمان تحميل الإضافة أولاً بأمان
      local caps = require("cmp_nvim_lsp").default_capabilities()

      -- خادم Lua (تم تنظيف المسار الغير موجود لجهازك)
      vim.lsp.config['luals'] = {
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
          capabilities = caps,
          settings = {
              Lua = {
                  runtime = { version = 'LuaJIT' },
                  diagnostics = { globals = { 'vim' } },
                  workspace = {
                      checkThirdParty = false,
                      library = vim.api.nvim_get_runtime_file('', true),
                  },
                  telemetry = { enable = false },
              },
          },
      }

      -- خادم TypeScript (لدعم NestJS)
      vim.lsp.config['ts_ls'] = {
          cmd = { 'typescript-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
          root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
          capabilities = caps,
          settings = {
              completions = {
                  completeFunctionCalls = true,
              },
          },
      }

      -- خادم ESLint (لضبط جودة وتنسيق أكواد NestJS)
      vim.lsp.config['eslint'] = {
          cmd = { 'vscode-eslint-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
          root_markers = { '.eslintrc.js', 'eslint.config.js', 'package.json', '.git' },
          capabilities = caps,
          settings = {
              workingDirectories = { mode = 'auto' },
          },
      }

      -- باقي خوادم اللغات الخاصة بك
      vim.lsp.config['cssls'] = {
          cmd = { 'vscode-css-language-server', '--stdio' },
          filetypes = { 'css', 'scss', 'less' },
          root_markers = { 'package.json', '.git' },
          capabilities = caps,
          settings = { css = { validate = true }, scss = { validate = true }, less = { validate = true } },
      }

      vim.lsp.config['phpls'] = {
          cmd = { 'intelephense', '--stdio' },
          filetypes = { 'php' },
          root_markers = { 'composer.json', '.git' },
          capabilities = caps,
          settings = { intelephense = { files = { maxSize = 5000000 } } },
      }

      vim.lsp.config['zls'] = {
          cmd = { 'zls' }, filetypes = { 'zig', 'zir' }, root_markers = { 'zls.json', 'build.zig', '.git' }, capabilities = caps,
          settings = { zls = { enable_build_on_save = true, build_on_save_step = "install", warn_style = false, enable_snippets = true } }
      }

      vim.lsp.config['nil_ls'] = {
          cmd = { 'nil' }, filetypes = { 'nix' }, root_markers = { 'flake.nix', 'default.nix', '.git' }, capabilities = caps,
          settings = { ['nil'] = { formatting = { command = { "alejandra" } } } }
      }

      vim.lsp.config['rust_analyzer'] = {
          cmd = { 'rust-analyzer' }, filetypes = { 'rust' }, root_markers = { 'Cargo.toml', 'rust-project.json', '.git' }, capabilities = caps,
          settings = { ['rust-analyzer'] = { cargo = { allFeatures = true }, formatting = { command = { "rustfmt" } } } }
      }

      vim.lsp.config['clangd'] = {
          cmd = { 'clangd' }, filetypes = { 'c', 'cpp', 'objc', 'objcpp' }, capabilities = caps,
          root_markers = { 'compile_commands.json', '.clangd', 'configure.ac', 'Makefile', '.git' },
      }

      vim.lsp.config['jsonls'] = {
          cmd = { 'vscode-json-languageserver', '--stdio' }, filetypes = { 'json', 'jsonc' }, capabilities = caps,
          root_markers = { 'package.json', '.git', 'config.jsonc' },
      }

      vim.lsp.config['gopls'] = {
          cmd = { 'gopls' }, filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' }, root_markers = { 'go.mod', 'go.work', '.git' }, capabilities = caps,
          settings = { gopls = { analyses = { unusedparams = false, ST1003 = false, ST1000 = false }, staticcheck = true } }
      }

      -- تفعيل كل الخوادم المذكورة أعلاه تلقائياً
      ---@diagnostic disable-next-line: invisible
      for name, _ in pairs(vim.lsp.config._configs) do
          if name ~= '*' then
              vim.lsp.enable(name)
          end
      end
    end,
  },

  -- ========================================================================== --
  --  إعداد محرك التكميل التلقائي (nvim-cmp)                                   --
  -- ========================================================================== --
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-Space>'] = cmp.mapping.complete({}),
          ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      })
    end,
  },
}
