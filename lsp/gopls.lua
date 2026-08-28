return {
  cmd = { "gopls" },

  filetypes = {
    "go",
    "gomod",
    "gowork",
    "gotmpl",
  },

  root_markers = {
    "go.work",
    "go.mod",
    ".git",
  },

  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
    },
  },
}
