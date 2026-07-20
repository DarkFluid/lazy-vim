-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- When opening an HTML file inside an Angular project, ensure vtsls starts so
-- that angularls has a TypeScript server to pair with. Without this, go-to-
-- definition and other features are broken until a .ts file is opened first.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "htmlangular" },
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name:match("%.cshtml$") or name:match("%.razor$") then
      return
    end

    local angular_root = vim.fs.find("angular.json", {
      upward = true,
      path = vim.fn.expand("%:p:h"),
    })[1]
    if angular_root then
      vim.lsp.start({ name = "vtsls" })
    end
  end,
})

-- cshtml/razor can become very slow when language servers attach.
-- Keep them lightweight unless explicitly re-enabled.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cshtml", "razor" },
  callback = function(args)
    vim.b[args.buf].autoformat = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
      if client.name == "rzls" or client.name == "roslyn" then
        vim.lsp.buf_detach_client(args.buf, client.id)
      end
    end
  end,
})

-- Hard performance guard for Razor buffers: trigger by filename pattern,
-- regardless of whichever filetype detector/plugin sets the ft.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  pattern = { "*.cshtml", "*.razor" },
  callback = function(args)
    vim.b[args.buf].autoformat = false

    -- Detach any LSP that might have attached to this buffer.
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
      if client.name == "rzls" or client.name == "roslyn" or client.name == "vtsls" then
        vim.lsp.buf_detach_client(args.buf, client.id)
      end
    end

    -- If Roslyn is running globally, stop it while working in Razor files.
    -- It can still consume CPU even when not attached to the current buffer.
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.name == "roslyn" or client.name == "rzls" then
        client.stop(true)
      end
    end
  end,
})
