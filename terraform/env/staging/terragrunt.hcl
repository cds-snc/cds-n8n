terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.114.2@sha256:07bd01b531ae173237f0753bda754dca0e2fd69170aa5f353e35da0162c91955"
  model_container_image = "ollama/ollama:0.12.3@sha256:c622a7adec67cf5bd7fe1802b7e26aa583a955a54e91d132889301f50c3e0bd0"
}