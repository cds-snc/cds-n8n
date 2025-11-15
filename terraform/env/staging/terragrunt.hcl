terraform {
  source = "../..//aws"
}

include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  n8n_container_image   = "n8nio/n8n:1.118.1@sha256:cf74d4ebe7dca858c390ee317b9a4f554ea57f0444b2d760f6d69e4f18d5d312"
  model_container_image = "ollama/ollama:0.12.10@sha256:e8c3d1f6ad16323bc40dc63eff0701d4fc32113f75a86b54b3e836eef8290de6"
}