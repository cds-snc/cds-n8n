terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.116.1@sha256:cc32e0790f15e3e66fc6ad51f5511b6a9c474bd2c1d43893cd82fc875c3919f7"
  model_container_image = "ollama/ollama:0.12.6@sha256:a61a8fd395dbb931cc8cb1b5da7a2510746575c87113fdc45b647ee59ef7f808"
}