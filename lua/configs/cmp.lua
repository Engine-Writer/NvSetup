local cmp = require "cmp"
local base = require "nvchad.configs.cmp"

base.mapping["<Up>"] = cmp.mapping(function(fallback)
  fallback()
end, { "i", "s" })

base.mapping["<Down>"] = cmp.mapping(function(fallback)
  fallback()
end, { "i", "s" })

base.mapping["<Esc>"] = cmp.mapping(function(fallback)
  if cmp.visible() then
    cmp.abort()
  else
    fallback()
  end
end, { "i", "s" })

return base
