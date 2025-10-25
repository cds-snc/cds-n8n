terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.116.1@sha256:cc32e0790f15e3e66fc6ad51f5511b6a9c474bd2c1d43893cd82fc875c3919f7"
  model_container_image = "ollama/ollama:0.12.5@sha256:e43c26d2d1ebc726bc932166d2979086310b2f9c5ccd64fb06b55d1ea2c4f2cc"
}