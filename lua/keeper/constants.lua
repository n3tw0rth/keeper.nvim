local M = {}

--- Name of the buffer showing the buffer list. The URI-style name cannot
--- collide with a real file and lets :edit / :write reach the plugin's
--- BufReadCmd / BufWriteCmd autocmds.
M.KEEPER_BUFFER_NAME = "keeper://buffers"

return M
