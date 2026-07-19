ignore = {
  "631",    -- max_line_length
}
-- vim is a global with writable fields (vim.bo[buf].x = y is idiomatic)
globals = {
  "vim",
}
files = {
  spec = { std = "+busted" },
}
