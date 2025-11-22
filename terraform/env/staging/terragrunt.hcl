terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.119.1@sha256:4a43ddf853afe3ad44be51379e7ed85c16b974cae26cf732d2fcbf71d0cb16c4"
  model_container_image = "ollama/ollama:0.12.11@sha256:3d8a05e3432d50ea57594fabe971e46cc8fe963a0f9f8c40400bd56cd5388e47"
}