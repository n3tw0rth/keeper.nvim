rockspec_format = '3.0'
package = "keeper.nvim"
version = "scm-1"
source = {
  url = "git+https://github.com/n3tw0rth/keeper.nvim",
}
dependencies = {
}
test_dependencies = {
  "nlua"
}
build = {
  type = "builtin",
  copy_directories = {
    "doc",
    "plugin",
  },
}
