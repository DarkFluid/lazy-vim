local function grep_ext_transform(_, filter)
  local query, ext = filter.search:match("^(.-)  (%S+)%s*$")
  if query and ext then
    local glob = ext:match("[*./{}]") and ext or ("*." .. ext)
    filter.search = query .. " -- -g " .. glob
    return true
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer     = { hidden = true, ignored = true },
          files        = { hidden = true, ignored = true },
          grep         = { filter = { transform = grep_ext_transform } },
          grep_buffers = { filter = { transform = grep_ext_transform } },
          grep_word    = { filter = { transform = grep_ext_transform } },
        },
      },
    },
  },
}
