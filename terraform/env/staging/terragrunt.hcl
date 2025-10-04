terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.112.3@sha256:c5fe3ff0b79f7831dc21f9c709bdb7eee4fff4453a28ce84c8e9fa5b9f562686"
  model_container_image = "ollama/ollama:0.12.3@sha256:c622a7adec67cf5bd7fe1802b7e26aa583a955a54e91d132889301f50c3e0bd0"
}