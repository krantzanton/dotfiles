-- Treesitter (nvim-treesitter `main` branch): syntax highlighting, indentation, code context.
-- Parsers are compiled with the tree-sitter CLI (installed by Mason, see lsp.lua) and a C compiler.

local TS = require("nvim-treesitter")

local ensure_installed = {
  -- systems
  "bash", "c", "cpp", "cmake", "make", "glsl",
  -- go
  "go", "gomod", "gosum", "gowork",
  -- web / react
  "javascript", "typescript", "tsx", "jsdoc", "html", "css", "json", "graphql",
  -- config / docs
  "lua", "luadoc", "vim", "vimdoc", "query", "yaml", "toml", "fish",
  "markdown", "markdown_inline", "dockerfile", "gitcommit", "diff", "regex",
}

-- Installing needs the tree-sitter CLI; on a fresh machine wait for Mason to provide it
if vim.fn.executable("tree-sitter") == 1 then
  TS.install(ensure_installed)
else
  vim.api.nvim_create_autocmd("User", {
    pattern = "MasonToolsUpdateCompleted",
    once = true,
    callback = function()
      TS.install(ensure_installed)
    end,
  })
end

-- Start highlighting + indentation for every filetype that has a parser.
-- Parsers that aren't installed yet get installed the first time you open such a file.
local group = vim.api.nvim_create_augroup("anton_treesitter", { clear = true })
local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end
    if vim.treesitter.language.add(lang) then
      attach(ev.buf, lang)
    elseif vim.fn.executable("tree-sitter") == 1 and vim.tbl_contains(TS.get_available(), lang) then
      TS.install(lang):await(function()
        vim.schedule(function()
          attach(ev.buf, lang)
        end)
      end)
    end
  end,
})

-- Recompile parsers when nvim-treesitter itself is updated
vim.api.nvim_create_autocmd("PackChanged", {
  group = group,
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
      vim.schedule(function()
        vim.cmd("TSUpdate")
      end)
    end
  end,
})

-- Shows the current function/component at the top when scrolled past it
require("treesitter-context").setup({ max_lines = 3 })
-- Auto close/rename JSX and HTML tags
require("nvim-ts-autotag").setup()
