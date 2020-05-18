std = "max"
include_files = {
  "**/*.lua",
  ".busted",
  ".luacheckrc"
}
exclude_files = {
  "lua_modules",
  ".lua",
  ".luarocks",
  ".install"
}
files["spec"] = {
  std = "+busted"
}
globals = {
  "vim",
}
max_line_length = false
