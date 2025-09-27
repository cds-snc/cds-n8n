terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.112.3@sha256:c5fe3ff0b79f7831dc21f9c709bdb7eee4fff4453a28ce84c8e9fa5b9f562686"
  model_container_image = "ollama/ollama:0.12.0@sha256:14def4e0b9ac8c91b3ec6f7fa7684c924ffe244541d5fd827d9b89035cc33310"
}