vim.filetype.add({
  pattern = {
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    ["compose.*%.ya?ml"] = "yaml.docker-compose",
  },
})

return {
  cmd = { "docker-language-server", "start", "--stdio" },

  filetypes = {
    "dockerfile",
    "yaml.docker-compose",
  },

  get_language_id = function(_, filetype)
    if filetype == "yaml.docker-compose" then
      return "dockercompose"
    end

    return filetype
  end,

  root_markers = {
    "Dockerfile",
    "docker-compose.yml",
    "docker-compose.yaml",
    "compose.yml",
    "compose.yaml",
    ".git",
  },
}
