terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.113.3@sha256:57f95a26b1b28527053fba6316d9d046395d9b4da9d0da486e838384a38fcf37"
  model_container_image = "ollama/ollama:0.12.0@sha256:14def4e0b9ac8c91b3ec6f7fa7684c924ffe244541d5fd827d9b89035cc33310"
}