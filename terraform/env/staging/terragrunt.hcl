terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.119.1@sha256:4a43ddf853afe3ad44be51379e7ed85c16b974cae26cf732d2fcbf71d0cb16c4"
  model_container_image = "ollama/ollama:0.12.10@sha256:e8c3d1f6ad16323bc40dc63eff0701d4fc32113f75a86b54b3e836eef8290de6"
}