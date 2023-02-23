return {
  os_name = vim.loop.os_uname().sysname,
  os_homedir = assert(vim.loop.os_homedir(), "failed to get os homedir"),
  cwd = assert(vim.loop.cwd(), "failed to get current working directory"),
}
