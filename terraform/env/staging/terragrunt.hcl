terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.117.2@sha256:c7dae935e8657559bf5b6d9c9e8b074d67a55e90fd7a227bae3e668beec3bb62"
  model_container_image = "ollama/ollama:0.12.6@sha256:a61a8fd395dbb931cc8cb1b5da7a2510746575c87113fdc45b647ee59ef7f808"
}