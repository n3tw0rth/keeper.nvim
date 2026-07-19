test:
  nvim --headless --noplugin -u spec/minimal_init.lua -c "PlenaryBustedDirectory spec { minimal_init = './spec/minimal_init.lua' }"
lint:
  luacheck lua spec
changelog:
  git cliff -o CHANGELOG.md
