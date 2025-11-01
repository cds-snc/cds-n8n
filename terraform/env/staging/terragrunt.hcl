terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.117.1@sha256:5194c661f0de5543fc02a25a5bb749bb5c93f6b48400c507954ac1d756545053"
  model_container_image = "ollama/ollama:0.12.6@sha256:a61a8fd395dbb931cc8cb1b5da7a2510746575c87113fdc45b647ee59ef7f808"
}