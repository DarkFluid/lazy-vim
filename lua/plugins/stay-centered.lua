return {
  {
    "arnamak/stay-centered.nvim",
    opts = function()
      require("stay-centered").setup({
        -- Optional: skip filetypes where centering is unwanted (e.g., lua, typescript)
        -- skip_filetypes = { "lua", "typescript" },
        -- Optional: disable if plugin causes lag
        -- disable_on_mouse = true,
      })
    end,
  },
}
