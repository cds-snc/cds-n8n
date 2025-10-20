terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.115.2@sha256:ca7bc6b8de1b4f0f87e66d1fee70ddeafa4cc98989c361f7ec1a6c45bec04c96"
  model_container_image = "ollama/ollama:0.12.5@sha256:e43c26d2d1ebc726bc932166d2979086310b2f9c5ccd64fb06b55d1ea2c4f2cc"
}