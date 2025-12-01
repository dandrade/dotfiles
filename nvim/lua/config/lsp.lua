-- Configuración manual de Solargraph 
require('lspconfig').solargraph.setup({
  cmd = { "solargraph", "stdio" }, 
  filetypes = { "ruby" }, 
  root_dir = require('lspconfig').util.root_pattern("Gemfile", ".git"), 
  settings = {
    solargraph = {
      diagnostics = true, 
      formatting = true,
    }
  }
})
