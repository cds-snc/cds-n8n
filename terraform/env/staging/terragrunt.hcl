terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.113.3@sha256:57f95a26b1b28527053fba6316d9d046395d9b4da9d0da486e838384a38fcf37"
  model_container_image = "ollama/ollama:0.12.3@sha256:c622a7adec67cf5bd7fe1802b7e26aa583a955a54e91d132889301f50c3e0bd0"
}